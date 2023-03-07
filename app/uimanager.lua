--- pkg 'uimanager' is responsible for setting up and driving the UI
--- For dev convenience and runtime speed, this package accesses the global namespace,
---     but is not intended to modify any global vars

import 'CoreLibs/crank'
import 'ui/button'
import 'ui/list'
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
local pairs <const> = pairs
local ipairs <const> = ipairs

local CRANK_ROTS_PER_HOUR <const> = 3 -- tune timer-setting dial sensitivity

--TODO most of these are not needed outside of specific funcs
local timersMenu = nil  -- contains the buttons for selecting timers --TODO move to init
local durationDials = {} -- visualize/manipulate timer durations --TODO move to init
-- TODO rm timerSelectButton when addTimerSelector() is implemented
local timerSelectButtons = {} -- select timer to run --TODO move to init
local menuInst = nil -- instructions shown in MENU --TODO move to init

local toMenuButton = nil
local pauseButton = nil
local unpauseButton = nil
local runTimerInst = nil -- instructions shown in RUN_TIMER state --TODO move to init

local snoozeButton = nil -- invisible snooze button --TODO move to init
local doneTimerInst = nil -- instructions shown in DONE_TIMER state --TODO move to init

--TODO much of this no longer needs to be in init
-- ex. a addTimerSelector() could be called by main to add each timer selector
--      the timersMenu.
--- Initializes and returns new UIManager singleton instance.
--- If instance already exists, this func does nothing but returns that instance.
---@param timers table all Timers that the UI should support selecting
local function init(timers)
    --- Add all of the timer-selecting/-configuring UIElements that are
    ---     displayed on the MENU screen.
    ---@param container List to contain the timer-selecting buttons
    ---@param timers table ARRAY all Timers to make selectors for
    local function populateTimersMenu (container, timers)
        if not container then
            d.log("timersMenu container nil; can't config")
            return
        end

        d.log("timers", timers)
        local n = 0
        n = #timers
        d.log("n: " .. n)
        local wButton, hButton = container:getMaxContentDim(n)

        local function makeTimerSelector(t)
            local name = t.name

            local button = Button({name .. "Button", wButton, hButton})
            timerSelectButtons[name] = button
            button:setEnablingCriteria(function() return container:isEnabled() end)
            button.isPressed = function() return pd.buttonJustPressed(A) end

            local dial = Dial({name .. "Dial", 80, 40}, 1, 1, 60)
            durationDials[name] = dial
            dial:setEnablingCriteria(function() return
                button:isEnabled() and
                button.isSelected() end)
            dial.isSelected = function () return button.isSelected() end
            local ticks = 60 / CRANK_ROTS_PER_HOUR
            dial.getDialChange = function ()
                return pd.getCrankTicks(ticks)
            end
            dial:setUnit("min")
            dial:setValue(duration_defaults[name])
            dial:setZIndex(60)

            -- TODO move func def below to be local func more visible at root of this file
            button.pressedAction = function ()
                toRun(t, dial.value)
            end
            
            return button
        end

        for _, timer in pairs(timers) do
            container:addChildren(makeTimerSelector(timer))
        end
    end

    --- Populate a container containing instructions for the user.
    ---@param container List to use as a container
    ---@param instructions table containing name:text pairs
    local function writeInstructions(container, instructions)
        container.isSelected = function() return false end -- no reason for user to select instructions
        
        -- count all instructions to be stacked into container
        local n = 0
        for _, _ in pairs(instructions) do n = n + 1 end
        n = n + #instructions
        local w, h = container:getMaxContentDim(n)

        for name, text in pairs(instructions) do
            local inst = Textbox({name .. "Inst", w, h})
            inst:setEnablingCriteria(function() return container:isEnabled() end)
            inst:setText("_"..text.."_", "dontResize")
            container:addChildren(inst)
        end
    end

    timersMenu = List({"timersMenu", 120, 140})
    timersMenu:setEnablingCriteria(function () return state == STATES.MENU end)
    -- TODO when configmenu + menuList, remove the following line
    timersMenu.isSelected = function() return state == STATES.MENU end
    populateTimersMenu(timersMenu, timers)
    timersMenu:moveTo(250, 60)

    -- TODO rm when addTimerSelector() is implemented
    timerSelectButtons.work:setLabel("work")
    timerSelectButtons.short:setLabel("short break")
    timerSelectButtons.long:setLabel("long break")

    --TODO mv to populateTimersMenu
    for _, dial in pairs(durationDials) do
        dial:moveTo(20, 60)
    end

    --TODO i wanna make timersMenu just the list of buttons again, add the dials seperately

    menuInst = List({"menuInstList", 200, 60})
    menuInst:setEnablingCriteria(function() return state == STATES.MENU end)
    writeInstructions(menuInst, {
        runTimer = "A starts selected timer",
        setTimer = "Crank sets pom duration"
    })
    menuInst:moveTo(20, 140)
    menuInst:setZIndex(60)

    local paused = false

    toMenuButton = Button({"toMenuButton"}, 'invisible')
    toMenuButton:setEnablingCriteria(function() return
        state == STATES.RUN_TIMER or
        state == STATES.DONE_TIMER end)
    toMenuButton.isPressed = function() return pd.buttonJustPressed(B) end
    toMenuButton.pressedAction = function()
        paused = false
        toMenu()
    end
    toMenuButton:forceConfigured()

    pauseButton = Button({"pauseButton"}, 'invisible')
    pauseButton:setEnablingCriteria(function() return
        state == STATES.RUN_TIMER and
        not paused
    end)
    pauseButton.isPressed = function() return pd.buttonJustPressed(A) end
    pauseButton.pressedAction = function()
        pause()
        paused = true
    end
    pauseButton:forceConfigured()

    unpauseButton = Button({"unpauseButton"}, 'invisible')
    unpauseButton:setEnablingCriteria(function() return
        state == STATES.RUN_TIMER and
        paused
    end)
    unpauseButton.isPressed = function() return pd.buttonJustPressed(A) end
    unpauseButton.pressedAction = function()
        unpause()
        paused = false
    end
    unpauseButton:forceConfigured()

    runTimerInst = List({"runTimerInstList", 300, 60})
    runTimerInst:setEnablingCriteria(function() return state == STATES.RUN_TIMER end)
    writeInstructions(runTimerInst, {
        pauseInst = "A toggles timer pause",
        toMenu = "B returns to menu"
    })
    runTimerInst:moveTo(20, 140)
    runTimerInst:setZIndex(60)

    snoozeButton = Button({"snoozeButton"}, 'invisible')
    snoozeButton:setEnablingCriteria(function() return state == STATES.DONE_TIMER end)
    snoozeButton.isPressed = function() return pd.buttonJustPressed(A) end
    snoozeButton.pressedAction = function()
        snooze()
    end
    snoozeButton:forceConfigured()

    doneTimerInst = List({"doneTimerInstList", 300, 60})
    doneTimerInst:setEnablingCriteria(function() return state == STATES.DONE_TIMER end)
    writeInstructions(doneTimerInst, {
        snoozeInst = "A snoozes timer",
        toMenuInst = "B returns to menu"
    })
    doneTimerInst:moveTo(20, 140)
    doneTimerInst:setZIndex(60)
end

--- Drives the UI. Call on pd.update().
local function update()
    switch.update()
end

--- Get the value currently set on a specified dial
---@return integer minutes value on this dial, or -1 if dial is not found
local function getDialValue(name)
    local dial = durationDials[name]
    if not dial then
        d.log("dial '" .. name .. "' not known to uimanager")
        return -1
    end
    return dial.value
end

uimanager = {
    name = "manage_ui",
    init = init,
    update = update,
    getDialValue = getDialValue
}
uimanager = utils.makeReadOnly(uimanager)
return uimanager