--- pkg 'ui' defines a singleton UIManager class
--- For dev convenience, this package accesses the global namespace,
---     but is not intended to modify any global vars other than:
---         - STATE
---         - currentTimer
--- TODO may be nice to encapsulate this env, pass ref to STATE on init

import 'CoreLibs/crank'
import 'ui/group'
import 'ui/button'
import 'ui/panel'
import 'ui/dial'

--[[
    TODO 
    1. move all UI related code (ex button gen) to this file
            go slow; refactor a small part, test, repeat
    2. override key sprite class funcs such as moveTo, add, remove
        to trickle the command down to all buttons, as well as the UI superclass itself
    3. set up the other menu buttons
    4. set up the timer-state "buttons"
    5. add rough transition anims to menu, just to architect how it would work
]]--

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

local CRANK_ROTS_PER_HOUR <const> = 3 -- tune timer-setting dial sensitivity
local DURATION_DEFAULTS <const> = {
    work = 25,
    short = 5,
    long = 20
}
local isApressed = function() return pd.buttonJustPressed(A) end
local isBpressed = function() return pd.buttonJustPressed(B) end

-- TODO UIManager should be a base UIElement rather than a panel
--      later, can parent menuPanel for stacking timersMenu next to configMenu
--- UIManager is the singleton root of all UIElements in the program.
--- It is in charge of defining the specific behaviours and layouts
---     of all UIElements, as well as configuring the UI object heirarchy.
class('UIManager').extends(UIElement)
--local localstatic <const> = val --TODO non-imported statics go here

local instance = nil
local timersMenu = nil  -- seq that timer buttons appear in
local timerDials = {}
local timerButtons = {}

-- TODO once button factory is set up this can be demodularized
local function setTimerDial(d, t)
    d:set(t:getDuration())
end

local function populateTimersMenu ()
    if not timersMenu then
        d.log("timersMenu nil; can't config")
        return
    end

    local function makeTimerSelector(name, t)
        local button = Button(name .. "Button")
        timerButtons[name] = button
        button.isPressed = isApressed

        local dial = Dial(name .. "Dial", "mins", 1, 1, 60)
        timerDials[name] = dial
        local ticks = 60 / CRANK_ROTS_PER_HOUR
        dial.getDialChange = function ()
            return pd.getCrankTicks(ticks)
        end
        dial:set(DURATION_DEFAULTS[name])
        dial:moveTo(20, 60)

        local group = Group(name .. "Group")
        group:addChild(button)
        group:addChild(dial)
        group:configRect(button.x, button.y, button.width, button.height)

        group.isSelected = function()
            return button.isSelected()
        end
        group.selectedAction = function() dial:add() end
        group.notSelectedAction = function() dial:remove() end
        button.pressedAction = function ()
            timersMenu:transitionOut()
            t:setDuration(dial.value) --TODO move this to toRun in main?
            toRun(t)
        end
        
        return group
    end

    --TODO refactor timer buttons:
        -- funtion startTimer(t) sets the duration and runs runTimer
        -- buttons are indexed in the timersmenu as an array/nameless.
        --      Instead they get their names from their assigned timers

    local workGroup = makeTimerSelector("work", timers.work)
    timersMenu:addChild(workGroup)
    local shortGroup = makeTimerSelector("short", timers.short)
    timersMenu:addChild(shortGroup)
    local longGroup = makeTimerSelector("long", timers.long)
    timersMenu:addChild(longGroup)
end

--- Initializes and returns new UIManager singleton instance.
--- If instance already exists, this func does nothing but returns that instance.
function UIManager:init()
    if instance then 
        d.log("UIManager instance exists; not reinstantiating; returning instance")
        return instance
    end

    UIManager.super.init(self, "uimanager", 2, "horizontal")
    self.isSelected = function () return true end

    timersMenu = Panel("timersMenu", 2)
    self:addChild(timersMenu)
    timersMenu:moveTo(250, 60)
    -- TODO when configmenu + menuPanel, remove the following line
    timersMenu.isSelected= function()
        return state == STATES.MENU
    end
    populateTimersMenu()

    for _, dial in pairs(timerDials) do
        dial:moveTo(20, 60)
        dial:setZIndex(20)
    end

    self._isConfigured = true
    instance = self
    self = utils.makeReadOnly(self, "UIManager instance")
end

---TODO desc
function UIManager:update()
    if state == STATES.MENU then
        --TODO once config menu exists, set up L/R selection b/w config menu and timers menu

        --TODO this should probs be done by pause button once set up
        timersMenu:transitionIn()
    end

    UIManager.super.update(self)
    --debugger.bounds(self)
end

--TODO function get() end

uimanager = {name = "uimanager"}
uimanager = utils.makeReadOnly(uimanager)
return uimanager