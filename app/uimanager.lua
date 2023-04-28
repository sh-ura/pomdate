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
local crankhandler <const> = crankhandler

local CRANK_ROTS_PER_HOUR <const> = 3 -- tune timer-setting dial sensitivity

--TODO rm most of these - those that are not needed outside of specific funcs
local timersMenu = nil  -- contains the buttons for selecting timers --TODO move to init
local durationDials = {} -- visualize/manipulate timer durations --TODO move to init
-- TODO rm timerSelectButton when addTimerSelector() is implemented
local timerSelectButtons = {} -- select timer to run --TODO move to init
local pomCountDisplay = nil
local menuInst = nil -- instructions shown in MENU --TODO move to init

local toMenuButton = nil -- return to timer-select menu
local pauseButton = nil -- pause active timer
local unpauseButton = nil -- unpause active timer
local runTimerInst = nil -- instructions shown in RUN_TIMER state --TODO move to init

local snoozeButton = nil -- invisible snooze button --TODO move to init
local doneTimerInst = nil -- instructions shown in DONE_TIMER state --TODO move to init
local scoreboard = nil -- visualizes pause and snooze scores for this timer session

--TODO much of this no longer needs to be in init
-- ex. a addTimerSelector() could be called by main to add each timer selector
--      the timersMenu.
--- Initializes and returns new UIManager singleton instance.
--- If instance already exists, this func does nothing but returns that instance.
---@param timers table all Timers that the UI should support selecting,
---                 in {t, label} k-v tuples,
---                 in the sequence they should appear.
local function init(timers)
    --- Add all of the timer-selecting/-configuring UIElements that are
    ---     displayed on the MENU screen.
    ---@param list List to contain the timer-selecting buttons
    ---@param timers table all Timers to make selectors for,
    ---                 in {t, label} k-v tuples,
    ---                 in the sequence they should appear.
    local function populateTimersMenu (list, timers)
        local n = 0
        n = #timers
        local wButton, hButton = list:getMaxContentDim(n)

        local function makeTimerSelector(t, label)
            local name = t.name

            local button = Button({name .. "Button", wButton, hButton})
            timerSelectButtons[name] = button
            button.isPressed = function() return pd.buttonJustPressed(A) end
            button:setLabel(label)

            local dial = Dial({name .. "Dial", 80, 40}, 1, 1, 60)
            durationDials[name] = dial
            dial:setEnablingCriteria(function() return
                button:isEnabled()
                and button.isSelected()
            end)
            dial.isSelected = function () return pd.buttonIsPressed(B) end
            dial.getDialChange = function ()
                return crankhandler.getCrankTicks(60 / CRANK_ROTS_PER_HOUR)
            end
            dial:setUnit("min")
            dial:setValue(initialDurations[name])
            dial:setZIndex(60)

            -- TODO move func def below to be local func more visible at root of this file
            button.pressedAction = function ()
                toRun(t, dial.value)
            end
            
            return button
        end

        for _, timer in pairs(timers) do
            list:addChildren(makeTimerSelector(timer.t, timer.label), 'parentEnables')
        end
    end

    timersMenu = List({"timersMenu", 120, 150})
    timersMenu:setEnablingCriteria(function () return state == STATES.MENU end)
    -- TODO when configmenu + menuList, remove the following line
    timersMenu.isSelected = function() return state == STATES.MENU end
    populateTimersMenu(timersMenu, timers)
    timersMenu:moveTo(250, 60)

    --TODO mv to populateTimersMenu
    for _, dial in pairs(durationDials) do
        dial:moveTo(20, 60)
    end


    local paused = false --TODO instead of using this local var, access paused state via STATE or currentTimer.isPaused()
    
    toMenuButton = Button({"toMenuButton"}, 'invisible')
    toMenuButton:setEnablingCriteria(function() return
        state == STATES.RUN_TIMER 
        or state == STATES.DONE_TIMER
    end)
    toMenuButton.isPressed = function() return pd.buttonJustPressed(B) end
    toMenuButton.pressedAction = function()
        paused = false
        toMenu()
    end
    toMenuButton:forceConfigured()

    pauseButton = Button({"pauseButton"}, 'invisible')
    pauseButton:setEnablingCriteria(function() return
        state == STATES.RUN_TIMER
        and not paused
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

    snoozeButton = Button({"snoozeButton"}, 'invisible')
    snoozeButton:setEnablingCriteria(function()
        return state == STATES.DONE_TIMER
        and confs.snooze
    end)
    snoozeButton.isPressed = function() return pd.buttonJustPressed(A) end
    snoozeButton.pressedAction = function()
        snooze()
    end
    snoozeButton:forceConfigured()


    --- Populate a scoreboard.
    ---@param list List to use as a container
    ---@param instructions table containing unit:scoringFunction pairs
    ---@return table name:display pairs of the new score display objects
    local function makeScoreDisplays(list, scoringFuncs)
        list.isSelected = function() return false end -- no reason for user to select instructions
        
        -- count all instructions to be stacked into list
        local n = 0
        for _, _ in pairs(scoringFuncs) do n = n + 1 end
        local w, h = list:getMaxContentDim(n)

        local created = {}
        for unit, score in pairs(scoringFuncs) do
            local display = Dial({unit .. "Score", w, h}, 1)
            list:addChildren(display)
            display:setEnablingCriteria(function() return
                list:isEnabled() 
                and score() ~= 0
            end)
            display.isSelected = function() return true end
            display:setUnit(unit)

            local prevScore = 0
            display.getDialChange = function()
                local currentScore = score()
                local scoreDiff = currentScore - prevScore
                prevScore = currentScore
                return scoreDiff
            end

            --TODO can collide on units; use numbered or name indices instead
            created[unit] = display
        end
        return created
    end

    --TODO DEBUG sometimes this appears chopped in half.
    --      I think it has to do with the image canvas being a bit too small for the text
    scoreboard = List({"scoreboard", 100, 80})
    scoreboard:setEnablingCriteria(function() return state == STATES.DONE_TIMER end)
    makeScoreDisplays(scoreboard, {
        pause = getPauseCount,
        snooze = getSnoozeCount
    })
    scoreboard:moveTo(300, 60)
    scoreboard:setZIndex(80)

    pomCountDisplay = List({"pomCountDisplay", 100, 25})
    pomCountDisplay:setEnablingCriteria(function() return state == STATES.MENU end)
    makeScoreDisplays(pomCountDisplay, { pom = getPomCount })
        .pom:setMode(dial.visualizers.horiCounter) -- visualize poms as counters
    pomCountDisplay:moveTo(20, 20)
    pomCountDisplay:setZIndex(80)

    --- Populate a list containing instructions for the user.
    ---@param list List to use as a container
    ---@param instructions table containing name:text pairs
    ---@return table name:instruction pairs of the new instruction objects
    local function writeInstructions(list, instructions)
        list.isSelected = function() return false end -- no reason for user to select instructions
        
        -- count all instructions to be stacked into list
        local n = 0
        for _, _ in pairs(instructions) do n = n + 1 end
        local w, h = list:getMaxContentDim(n)

        local created = {}
        for name, text in pairs(instructions) do
            local inst = Textbox({name .. "Inst", w, h}, "_"..text.."_")
            list:addChildren(inst, 'parentEnables')
            created[name] = inst
        end
        return created
    end

    --TODO DEBUG only 2/3 (or 1/2) instructions showing up per state
    menuInst = List({"menuInstList", 230, 90})
    menuInst:setEnablingCriteria(function() return state == STATES.MENU end)
    writeInstructions(menuInst, {
        runTimer = "A starts selected timer", --TODO DEBUG not appearing onscreen
        setTimer = "Held B + Crank sets duration",
        confApp = "System menu has config options"
    })
    menuInst:moveTo(20, 140)
    menuInst:setZIndex(60)

    runTimerInst = List({"runTimerInst", 300, 60})
    runTimerInst:setEnablingCriteria(function() return state == STATES.RUN_TIMER end)
    writeInstructions(runTimerInst, {
        pause = "A toggles timer pause",
        toMenu = "B returns to menu"
    })
    runTimerInst:moveTo(20, 140)
    runTimerInst:setZIndex(60)

    doneTimerInst = List({"doneTimerInst", 300, 60})
    doneTimerInst:setEnablingCriteria(function() return state == STATES.DONE_TIMER end)
    writeInstructions(doneTimerInst, {
        snooze = "A snoozes timer", --TODO need this to not appear if snooze disabled
        toMenu = "B returns to menu"
    })
    .snooze:setEnablingCriteria(function() return
        confs.snooze
        and doneTimerInst:isEnabled() 
    end)
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

--- Force the selection of the next timer button
local function selectPrevTimer()
    timersMenu:prev()
end

--- Force the selection of the previous timer button
local function selectNextTimer()
    timersMenu:next()
end

uimanager = {
    name = "uimanager",
    init = init,
    update = update,
    getDialValue = getDialValue,
    selectPrevTimer = selectPrevTimer,
    selectNextTimer = selectNextTimer
}
uimanager = utils.makeReadOnly(uimanager)
return uimanager