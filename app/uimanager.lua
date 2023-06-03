--- pkg 'uimanager' is responsible for setting up and driving the UI
--- For dev convenience and runtime speed, this package accesses the global namespace,
---     but is not intended to modify any global vars

import 'CoreLibs/crank'
import 'CoreLibs/nineslice'
import 'ui/button'
import 'ui/list'
import 'ui/dial'
import 'ui/textbox'
import 'ui/cursor'
import 'ui/uielement'

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
local newVector <const> = utils.newVector
local newPoint <const> = utils.newPoint
local pairs <const> = pairs
local ipairs <const> = ipairs
local math <const> = math -- TODO rm
local pi <const> = math.pi
local sin <const> = math.sin
local cos <const> = math.cos
local crankhandler <const> = crankhandler
local COLOR_0 <const> = COLOR_0
local COLOR_1 <const> = COLOR_1

local CRANK_UNIT <const> = 60 / 3 -- tune timer-setting dial sensitivity
local BUTTON_WIDTH <const> = 120
local BUTTON_HEIGHT <const> = 34
local BUTTON_TRAVEL_DISTANCE <const> = 60
local LINE_CAP_STYLE <const> = gfx.kLineCapStyleRound
local imgPathPrefix = "assets/ui/"

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
local runInst = nil -- instructions shown in RUN_TIMER state --TODO move to init

local snoozeButton = nil -- invisible snooze button --TODO move to init
local doneInst = nil -- instructions shown in DONE_TIMER state --TODO move to init
local scoreboard = nil -- visualizes pause and snooze scores for this timer session

--- Make and write the frames for the LED animations
---@return gfx.imagetable containing the frames
local function bakeLEDAnimations()
    local period = 60                       -- period in terms of frames, rather than seconds
    local n_spokes = 5
    local w_frame = 60
    local h_frame = 60
    local A = 20                            -- amplitude, scale
    local C = pi/2                          -- phase shift

    local n_frames = (period / 2) // n_spokes  -- only show the front-facing half of the cycle
    local radPerFrame = 2 * pi / period
    local radPerSpoke = pi / n_spokes

    local imagetable = gfx.imagetable.new(n_frames)
    local theta     local x     local y     local i_frame
    for j = 0, n_frames-1 do
        local frame = gfx.image.new(w_frame * 4, h_frame, COLOR_CLEAR)
        
        for k = 0, n_spokes-1 do
            theta = k*radPerSpoke + j*radPerFrame
            x = 6 * cos(theta - C)
            y = A * sin(theta - C) + h_frame//2
            gfx.pushContext(frame)
                gfx.setColor(COLOR_1)
                gfx.setLineWidth(6)
                gfx.setLineCapStyle(gfx.kLineCapStyleRound)
                x = A * cos(theta - C) + w_frame//2
                gfx.drawLine(w_frame//2, h_frame//2, x, y)
                gfx.fillCircleAtPoint(x + w_frame, y, 4)

                x = 6 * cos(theta - C)
                gfx.drawLine(2.5*w_frame - x*1.5, y, 2.5*w_frame + x*1.5, y)
                gfx.setLineWidth(x)
                gfx.drawLine(3.5*w_frame - x*1.5, y, 3.5*w_frame + x*1.5, y)
            gfx.popContext()
        end
        
        i_frame = n_frames - j
        pd.datastore.writeImage(frame, imgPathPrefix .. "preSwitchLED-table-" .. i_frame)
        imagetable:setImage(i_frame, frame)
    end
    return imagetable
end

local function initCrankDialCircuit()
    -- These var names borrow similar-function circuitry vocab,
    --      don't necessarily represent how the sprite looks
    local wire = UIElement({"wire", 420, 140})
    local switch = Button({"switch", 60, 60})
    local preSwitchLED = Button({"preSwitchLED", 40, 80})
    local postSwitchLED = Button({"postSwitchLED", 80, 40})
    local function stateIsMENU() return state == STATES.MENU end --TODO these types of funcs can be declared in main, allowing hidind of state var

    local p = { -- wire junctures to draw, in crank -> dial face order
        {x=410, y=100},
        {x=320},
        {x=270},
        {x=60},
        {x=40, y=80},
        {y=0}
    }
    wire:setForeground(function(x, y, width, height)
        gfx.setColor(COLOR_1)
        gfx.setLineWidth(13)
        gfx.setLineCapStyle(LINE_CAP_STYLE)
        gfx.drawLine(p[1].x, p[1].y, p[2].x, p[1].y)
        gfx.drawLine(p[3].x, p[1].y, p[4].x, p[1].y)
        gfx.drawLine(p[4].x, p[1].y, p[5].x, p[5].y)
        gfx.drawLine(p[5].x, p[5].y, p[5].x, p[6].y)
    end)
    wire:setPosition(0, 100)
    wire:setEnablingCriteria(stateIsMENU)
    wire:forceConfigured()

    -- TODO we're searching for these files in the wrong place.
    -- They'll be saved in the app's folder in Data on the device.
    local imagetable = gfx.imagetable.new(imgPathPrefix .. "preSwitchLED")
    if not imagetable then
        d.log("preSwitchLED images not found; baking")
        imagetable = bakeLEDAnimations()
    end
    preSwitchLED:setForeground(imagetable)
    preSwitchLED:pauseForeground()
    preSwitchLED:setPosition(60, 130)
    preSwitchLED.isPressed = function() return true end
    preSwitchLED.pressedAction = function()
        local ticks = crankhandler.getCrankTicks(CRANK_UNIT)
        if ticks == 0 then
            preSwitchLED:pauseForeground()
            return
        end
        local reverse = false
        if ticks < 0 then reverse = true end -- reverse direction
        preSwitchLED:playForeground(100/ticks, reverse)
    end

    wire:addChildren({switch, preSwitchLED, postSwitchLED}, 'parentEnables')
end

--TODO much of this no longer needs to be in init
-- ex. a addTimerSelector() could be called by main to add each timer selector
--      the timersMenu.
--- Initializes and returns new UIManager singleton instance.
--- If instance already exists, this func does nothing but returns that instance.
---@param timers table all Timers that the UI should support selecting,
---                 in {t, label} k-v tuples,
---                 in the sequence they should appear.
local function init(timers)
    --- Populate timersMenu with the timer-selecting/-configuring UIElements that are
    ---     to be displayed on the MENU screen.
    ---@param list List to contain the timer-selecting buttons
    ---@param timers table all Timers to make selectors for,
    ---                 in {t, label} k-v tuples,
    ---                 in the sequence they should appear.
    ---@param cursor Cursor (optional) to point to the buttons
    local function fillTimersMenu (list, timers, cursor)
        local function makeTimerSelector(t, label)
            local name = t.name

            local button = Button({name .. "Button", BUTTON_WIDTH, BUTTON_HEIGHT})
            timerSelectButtons[name] = button
            button.isPressed = function() return pd.buttonJustPressed(A) end
            button:setBackground(function(width, height)
                local w_line = 8 -- must be even
                gfx.setColor(COLOR_1)
                gfx.fillRoundRect(0, 0, width, height, height//2)
                gfx.setColor(COLOR_0)
                gfx.fillRoundRect(w_line//2, w_line//2, width - w_line, height - w_line, (height - w_line)/2)
            end)
            button:setFont(gfx.getFont())
            button:setText(label)
            button:offsetPositions({selected = newVector(-BUTTON_TRAVEL_DISTANCE, 0)})
            button.justSelectedAction = function()
                button:setImageDrawMode(gfx.kDrawModeInverted)
            end
            button.justDeselectedAction = function()
                button:setImageDrawMode(gfx.kDrawModeCopy)
            end

            if cursor then
                cursor:addTarget(button, function ()
                    return button:getConfiguredPosition("selected") + newVector(button.width + MARGIN, 0)
                end)
            end

            local dial = Dial({name .. "Dial", 80, 40}, 1, 60)
            durationDials[name] = dial
            dial:setEnablingCriteria(function() return
                button:isEnabled()
                and button.isSelected()
            end)
            dial.isSelected = function () return pd.buttonIsPressed(B) end
            dial.getDialChange = function ()
                return crankhandler.getCrankTicks(CRANK_UNIT)
            end
            dial:setUnit("min")
            dial:setValue(initialDurations[name])
            dial:setBackground(function(width, height)
                gfx.setColor(COLOR_1)
                gfx.fillRect(0, 0, width, height)
            end)
            dial:setFont(gfx.getFont(), gfx.kDrawModeInverted)
            dial:setZIndex(60)
            dial:setPosition(MARGIN, 60)

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

    local ntimers = #timers
    timersMenu = List({
        "timersMenu", BUTTON_WIDTH + MARGIN * 2,
        (BUTTON_HEIGHT + MARGIN) * ntimers + MARGIN
    })
    timersMenu:setEnablingCriteria(function () return state == STATES.MENU end)
    -- TODO when configmenu + menuList, remove the following line
    timersMenu.isSelected = function() return state == STATES.MENU end
    timersMenu:setPosition(250, MARGIN)
    timersMenu:offsetPositions({disabled = newVector(BUTTON_TRAVEL_DISTANCE, 0)})

    local cursor = Cursor({"timerSelectCursor", BUTTON_TRAVEL_DISTANCE - MARGIN, BUTTON_HEIGHT})
    cursor:setEnablingCriteria(function () return state == STATES.MENU end)
    cursor:setBackground(function(width, height)
        gfx.setColor(COLOR_1)
        gfx.fillRoundRect(0, 0, width, height, height/2)
    end)
    cursor:setFont(gfx.getFont(), gfx.kDrawModeInverted)
    cursor:setText("A")
    cursor:setPosition(250, MARGIN)
    cursor:offsetPositions({disabled = newVector(BUTTON_TRAVEL_DISTANCE * 2, 0)})
    cursor:setZIndex(timersMenu:getZIndex() + 10)
    cursor:forceConfigured()

    fillTimersMenu(timersMenu, timers, cursor)

    local paused = false --TODO instead of using this local var, access paused state via STATE or currentTimer.isPaused()
    
    toMenuButton = Button({"toMenuButton", BUTTON_HEIGHT, BUTTON_TRAVEL_DISTANCE - MARGIN})
    toMenuButton:setEnablingCriteria(function() return
        state == STATES.RUN_TIMER 
        or state == STATES.DONE_TIMER
    end)
    toMenuButton.isPressed = function() return pd.buttonJustPressed(B) end
    toMenuButton.pressedAction = function()
        paused = false
        toMenu()
    end
    toMenuButton:setBackground( function(width, height)
        gfx.setColor(COLOR_1)
        gfx.fillRoundRect(0, 0, width, height, width/2)
    end)
    toMenuButton:setFont(gfx.getFont(), gfx.kDrawModeInverted)
    toMenuButton:setText("M")
    toMenuButton:setPosition(280,210)
    toMenuButton:offsetPositions({
        disabled = newVector(0,50),
        pressed = newVector(0,50)
    })
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
        and confs.snoozeOn
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
            local display = Dial({unit .. "Score", w, h})
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
    pomCountDisplay:moveTo(MARGIN, MARGIN)
    pomCountDisplay:setZIndex(80)

    initCrankDialCircuit()
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