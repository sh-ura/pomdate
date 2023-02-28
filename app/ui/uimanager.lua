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
import 'ui/textbox'

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
local pairs = pairs
local ipairs = ipairs

local CRANK_ROTS_PER_HOUR <const> = 3 -- tune timer-setting dial sensitivity
local isApressed = function() return pd.buttonJustPressed(A) end
local isBpressed = function() return pd.buttonJustPressed(B) end

-- TODO UIManager should be a panel and we should use addChild to position its elements on a nice margin
--      later, can parent menuList for stacking timersMenu next to configMenu
--- UIManager is the singleton root of all UIElements in the program.
--- It is in charge of defining the specific behaviours and layouts
---     of all UIElements, as well as configuring the UI object heirarchy.
class('UIManager').extends(List)
--local localstatic <const> = val --TODO non-imported statics go here

local instance = nil
-- TODO all below should be 'private' instance vars
local timersMenu = nil  -- contains the buttons for selecting timers
local timerDials = {} -- visualize/manipulate timer durations
local timerSelectButtons = {} -- select timer to run
local menuInst = nil -- instructions shown in MENU state
local timerInst = nil -- instructions shown in TIMER state

--- Initializes and returns new UIManager singleton instance.
--- If instance already exists, this func does nothing but returns that instance.
---@param timers table all Timers that the UI should support selecting
function UIManager:init(timers)
    if instance then 
        d.log("UIManager instance exists; not reinstantiating; returning instance")
        return instance
    end

    --- Add all of the timer-selecting/-configuring UIElements that are
    ---     displayed on the MENU screen.
    ---@param panel List the panel to contain the timer-selecting buttons
    ---@param timers table all Timers to make selectors for
    local function populateTimersMenu (panel, timers)
        if not timersMenu then
            d.log("timersMenu nil; can't config")
            return
        end

        d.log("timers", timers)
        local n = 0
        for _, _ in pairs(timers) do d.log("timer counted") n = n + 1 end
        n = n + #timers
        d.log("n: " .. n)
        local wButton, hButton = timersMenu:getMaxContentDim(n)

        local function makeTimerSelector(name, t)
            local button = Button({name .. "Button", wButton, hButton})
            timerSelectButtons[name] = button
            button.isPressed = isApressed

            local dial = Dial({name .. "Dial", 80, 40}, 1, 1, 60)
            timerDials[name] = dial
            local ticks = 60 / CRANK_ROTS_PER_HOUR
            dial.getDialChange = function ()
                return pd.getCrankTicks(ticks)
            end
            dial:setUnit("min")
            dial:setValue(duration_defaults[name])
            dial:moveTo(20, 60)

            local group = Group({name .. "Group"})
            group:addChild(button)
            group:addChild(dial)
            group:configRect(button.x, button.y, button.width, button.height)

            group.isSelected = function()
                return button.isSelected()
            end
            group.selectedAction = function() dial:add() end
            group.notSelectedAction = function() dial:remove() end
            -- TODO move func def below to be local func more visible at root of this file
            button.pressedAction = function ()
                panel:transitionOut()
                menuInst:transitionOut()
                t:setDuration(dial.value) --TODO move this to toRun in main?
                toRun(t)
            end
            
            return group
        end

        for name, timer in pairs(timers) do
            panel:addChild(makeTimerSelector(name, timer))
        end
    end

    --- Populate a panel containing instructions for the user.
    ---@param panel List to use as a container
    ---@param instructions table containing name:text pairs
    local function writeInstructions(panel, instructions)
        panel.isSelected = function() return false end -- no reason for user to select instructions
        
        -- count all instructions to be stacked into panel
        local n = 0
        for _, _ in pairs(instructions) do n = n + 1 end
        n = n + #instructions
        local w, h = panel:getMaxContentDim(n)

        for name, text in pairs(instructions) do
            local inst = Textbox({name, w, h})
            inst:setText("_"..text.."_", "dontResize")
            panel:addChild(inst)
        end
    end

    ---TODO actually use UIManager as panel for laying out its elements along the margins?
    UIManager.super.init(self, {"uimanager"})
    self.isSelected = function () return true end

    timersMenu = List({"timersMenu", 120, 140})
    self:addChild(timersMenu)
    -- TODO when configmenu + menuList, remove the following line
    timersMenu.isSelected = function()
        return state == STATES.MENU
    end
    d.log("timersMenu w: " .. timersMenu.width .. " timersMenu h: " .. timersMenu.height)
    populateTimersMenu(timersMenu, timers)
    timersMenu:moveTo(250, 60)

    timerSelectButtons.work:setLabel("work")
    timerSelectButtons.short:setLabel("short break")
    timerSelectButtons.long:setLabel("long break")

    for _, dial in pairs(timerDials) do
        dial:moveTo(20, 60)
        dial:setZIndex(20)
    end

    menuInst = List({"menuInstList", 200, 60})
    writeInstructions(menuInst, {
        runTimerInst = "A starts selected timer",
        setTimerInst = "Crank sets pom duration"
    })
    menuInst:moveTo(20, 140)
    menuInst:setZIndex(90)

    timerInst = List({"timerInstList", 300, 30})
    writeInstructions(timerInst, {
        toMenuInst = "B returns to menu"
    })
    timerInst:moveTo(20, 140)
    timerInst:setZIndex(90)

    self._isConfigured = true
    instance = self
    self = utils.makeReadOnly(self, "UIManager instance")
end

---TODO desc
function UIManager:update()
    if state == STATES.MENU then
        --TODO once config menu exists, set up L/R selection b/w config menu and timers menu

        timerInst:transitionOut()

        --TODO this should probs be done by pause button once set up
        timersMenu:transitionIn()
        menuInst:transitionIn()
    elseif state == STATES.TIMER then
        timerInst:transitionIn()
    end

    UIManager.super.update(self)
    --d.illustrateBounds(self)
end

--- Get the value currently set on a specified dial
---@return integer minutes value on this dial, or -1 if dial is not found
function UIManager:getDialValue(name)
    local dial = timerDials[name]
    if not dial then
        d.log("dial '" .. name .. "' not known to uimanager")
        return -1
    end
    return dial.value
end

--TODO function get() end

uimanager = {name = "uimanager"}
uimanager = utils.makeReadOnly(uimanager)
return uimanager