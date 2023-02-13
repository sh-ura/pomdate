--- pkg 'ui' defines a singleton UIManager class
--- For dev convenience, this package accesses the global namespace,
---     but is not intended to modify any global vars other than:
---         - STATE
---         - selectedTimer
--- TODO may be nice to encapsulate this env, pass refs to selectedTimer and STATE on init

import 'ui/button'
import 'ui/panel'

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

local isApressed = function() return pd.buttonJustPressed(A) end
local isBpressed = function() return pd.buttonJustPressed(B) end

--- UIManager is the singleton root of all UIElements in the program.
--- It is in charge of defining the specific behaviours and layouts
---     of all UIElements, as well as configuring the UI object heirarchy.
class('UIManager').extends(Panel)
--local localstatic <const> = val --TODO non-imported statics go here

local instance = nil
local timersMenu = nil -- seq that timer buttons appear in

local function populateTimersMenu ()
    if not timersMenu then
        d.log("timersMenu nil; can't config")
        return
    end

    local function runTimer(t)
        selectedTimer = t
        state = STATES.TIMER
        timersMenu:transitionOut()
        toRun()
    end

    local workButton = Button("work")
    workButton.isPressed = isApressed
    workButton.action = function () runTimer(timers.work) end
    timersMenu:addChild(workButton)

    local shortButton = Button("short")
    shortButton.isPressed = isApressed
    shortButton.action = function () runTimer(timers.short) end
    timersMenu:addChild(shortButton)

    local longButton = Button("long")
    longButton.isPressed = isApressed
    longButton.action = function () runTimer(timers.long) end
    timersMenu:addChild(longButton)
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
    populateTimersMenu()
    self:addChild(timersMenu)
    timersMenu:moveTo(200,20)

    instance = self
    self = utils.makeReadOnly(self, "UIManager instance")
end

---TODO desc
function UIManager:update()
    if state == STATES.MENU then
        --TODO once config menu exists, set up L/R selection b/w config menu and timers menu

        timersMenu:transitionIn()
    -- elseif state == STATES.TIMER then
    --     buttons.pause:add() --TODO we dont wanna do this every frame; figure out how we wanna do transitions
    --     if pd.buttonJustPressed(B) then
    --         buttons.pause:press()
    --         buttons.pause:remove()
    --         state = STATES.MENU
    --     end
    end

    UIManager.super.update(self)
    --debugger.bounds(self)
end

--TODO function get() end

uimanager = {name = "uimanager"}
uimanager = utils.makeReadOnly(uimanager)
return uimanager