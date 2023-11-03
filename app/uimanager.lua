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
import 'ui/animation'
import 'rendering/spinner'
import 'rendering/reel'
import 'rendering/buttonswitch'
import 'rendering/backicon'

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
local snd <const> = pd.sound
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB
local newVector <const> = utils.newVector
local newPoint <const> = utils.newPoint
local pi <const> = math.pi
local sin <const> = math.sin
local cos <const> = math.cos
local SOUND <const> = SOUND
local ICON <const> = GFX.ICON
local fontPathPrefix <const> = FONT.pathPrefix

-- Configure appearance params
local CRANK_DIAL_CIRCUIT <const> = {
    REVOLS_PER_HOUR = 3,
    WIRE = { WIDTH = 13 },
    SWITCH = { LENGTH = 80 },
    LINE_CAP_STYLE = gfx.kLineCapStyleRound
}
local BUTTONS <const> = {
    L = {
        WIDTH = 126,         -- for a Large *horizontal* button. Use as height for vertical button
        HEIGHT = 46          -- for a Large *horizontal* button. Use as width for vertical button
    },
    M = {
        WIDTH = 60,
        HEIGHT = 32
    },
    TRAVEL_DISTANCE = 60
}
local SETTING_DIAL <const> = {
    WIDTH = 220,
    HEIGHT = 130,
    FONT = {
        PATH = fontPathPrefix .. "Blades of Steel",
        SCALE = 10
    }
}
local FACE_DIAL <const> = {
    WIDTH = W_SCREEN - 2 * MARGIN,
    HEIGHT = H_SCREEN - 8 * MARGIN,
    Y = 2 * MARGIN,
    FONT = {
        PATH = fontPathPrefix .. "Ace Attacker",
        SCALE = 20
    }
}
local POM_COUNTER <const> = {
    DIAMETER = 16,
    REEL = {
        DIAMETER = 3 * 15,
        LINE_WIDTH = 4
    }
}

local crankDialSwitchIsClosed = false
--- Get the open/closed status of the crank-dial circuit.
--- If closed, timer duration setting should be settable by cranking.
---@return boolean true iff crank-dial circuit is closed/complete
local function getCrankDialCircuitClosure()
    return crankDialSwitchIsClosed
end

--TODO rm most of these - those that are not needed outside of specific funcs
local timersMenu = nil  -- contains the buttons for selecting timers --TODO move to init
local durationDials = {} -- visualize/manipulate timer durations --TODO move to init
-- TODO rm timerSelectButton when addTimerSelector() is implemented
local timerSelectButtons = {} -- select timer to run --TODO move to init
local menuInst = nil -- instructions shown in MENU --TODO move to init

local backButton = nil -- return to timer-select menu, without completing current timer
local skipButton = nil -- early end to current timer, skip to the next step in the cycle
local nextButton = nil -- return to timer-select menu, having completed current timer
local runInst = nil -- instructions shown in RUN_TIMER state --TODO move to init

local snoozeButton = nil -- invisible snooze button --TODO move to init
local doneInst = nil -- instructions shown in DONE_TIMER state --TODO move to init
local scoreboard = nil -- visualizes snooze score for this timer session

--- Draws the basic shape for a button UI indicator placed above the A or B key on the playdate.
---@param width integer button width
---@param height integer button height
---@param x integer (optional) where to draw shape, defaults to 0
---@param y integer (optional) where to draw shape, defaults to 0
local function drawButtonShapeAB(width, height, x, y)
    if not (x and y) then
        x = 0
        y = 0
    end
    gfx.setColor(COLOR_1)
    gfx.fillRoundRect(x, y, width, height, width/2)
end

--- Draws the crank-dial circuit UI for setting the pomodoro timer with the crank.
--- The purpose of this UI is to show the user that they should hold B while cranking to modify the timer dial face.
--- The purpose of holding B is to prevent unintentional time-changing when the crank is bumped.
local function initCrankDialCircuit()
    local w_circuit = 400
    local h_circuit = 140

    -- These var names borrow similar-function circuitry vocab,
    --      don't necessarily represent how the sprite looks
    local wire = UIElement({"wire", w_circuit, h_circuit})
    local switch = Button({"switch", 60, 60})
    local preSwitchLED = Dial({"preSwitchLED", 40, 80})
    local postSwitchLED = Dial({"postSwitchLED", 80, 40})
    
    local p = { -- wire junctures to draw, in crank -> dial face order
        {x=410, y=100},
        {x = X_B_BUTTON + CRANK_DIAL_CIRCUIT.SWITCH.LENGTH - 8},
        {x = X_B_BUTTON},
        {x=54},
        {x=40, y=86},
        {y=0}
    }
    wire:setForeground(function(x, y, width, height)
        gfx.setColor(COLOR_1)
        gfx.setLineWidth(CRANK_DIAL_CIRCUIT.WIRE.WIDTH)
        gfx.setLineCapStyle(CRANK_DIAL_CIRCUIT.LINE_CAP_STYLE)
        gfx.drawLine(p[1].x, p[1].y, p[2].x, p[1].y)
        gfx.drawLine(p[3].x, p[1].y, p[4].x, p[1].y)
        gfx.drawLine(p[4].x, p[1].y, p[5].x, p[5].y)
        gfx.drawLine(p[5].x, p[5].y, p[5].x, p[6].y)
    end)
    wire:setPosition(0, 100)
    wire:setOnScreenCriteria(stateIsMENU)
    wire:forceConfigured()

    -- TODO we're searching for these files in the wrong place.
    -- They'll be saved in the app's folder in Data on the device.
    local switchRender = ButtonSwitch("crankDialCircuitSwitch",
        drawButtonShapeAB,
        BUTTONS.L.HEIGHT,
        BUTTONS.M.WIDTH,
        "B",
        BUTTONS.TRAVEL_DISTANCE,
        CRANK_DIAL_CIRCUIT.SWITCH.LENGTH,
        CRANK_DIAL_CIRCUIT.WIRE.WIDTH,
        MARGIN
    )
    switch:setInteractivityCriteria(stateIsMENU)
    switch:setForeground(switchRender.imagetable)
    switch:setPosition(X_B_BUTTON - BUTTONS.L.HEIGHT/4, h_circuit - switch.height)
    switch.isPressed = function() return pd.buttonIsPressed(B) end
    switch.justReleasedAction = function ()
        switch.fg_anim:play(-1, 1, animation.bookmarks.first)
        crankDialSwitchIsClosed = false
    end
    switch:setSound("touched", snd.sampleplayer.new(SOUND.crankDialSwitch.closing.path), SOUND.crankDialSwitch.closing.volume)
    switch:setSound("locked", snd.sampleplayer.new(SOUND.crankDialSwitch.closed.path), SOUND.crankDialSwitch.closed.volume)
    switch.pressedAction = function ()
        switch.fg_anim:play(1, 0, animation.bookmarks.last,
        function ()
            if not crankDialSwitchIsClosed then switch.sounds.locked:play(1) end -- play click sound iff switch was previously open
            crankDialSwitchIsClosed = true
        end)
    end

    local preSwitchLEDRender = Spinner("preSwitchLED", spinner.orientations.vertical, spinner.motions.cw)
    local postSwitchLEDRender = Spinner("postSwitchLED", spinner.orientations.horizontal, spinner.motions.cw)
    preSwitchLED:setForeground(preSwitchLEDRender.imagetable, 16)
    preSwitchLED:setPosition(w_circuit - 50, h_circuit - 70)
    preSwitchLED.getDialChange = crankhandler.subscribe()
    preSwitchLED:setMode(dial.visualizers.animation)
    preSwitchLED:setSound("dialing", snd.fileplayer.new(SOUND.preSwitchLED.path), SOUND.preSwitchLED.volume) --would prefer a sampleplayer here
    postSwitchLED:setForeground(postSwitchLEDRender.imagetable, 16)
    postSwitchLED:setPosition(10, 34)
    postSwitchLED:setUpdatingCriteria(getCrankDialCircuitClosure)
    postSwitchLED.getDialChange = crankhandler.subscribe()
    postSwitchLED:setMode(dial.visualizers.animation)

    wire:addChildren({switch, preSwitchLED, postSwitchLED}, 'alwaysOnScreenWithParent')
end

--TODO much of this no longer needs to be in init
-- ex. a addTimerSelector() could be called by main to add each timer selector
--      the timersMenu.
--- Initializes and returns new UIManager singleton instance.
--- If instance already exists, this func does nothing but returns that instance.
---@param timers table all Timers that the UI should support selecting,
---                 in {t, label} k-v tuples,
---                 in the sequence they should appear.
---                 param   t       Timer
---                 param   label   string  to set to selector button. If not provided, timer is not selectable (ex. snooze)
local function init(timers)
    --- Populate timersMenu with the timer-selecting/-configuring UIElements that are
    ---     to be displayed on the MENU screen.
    ---@param list List to contain the timer-selecting buttons
    ---@param timers table all Timers to make selectors for,
    ---                 in {t, label} k-v tuples,
    ---                 in the sequence they should appear.
    ---@param cursor Cursor (optional) to point to the buttons
    local function makeTimerUI (list, timers, cursor)
        local font_settingDial = gfx.font.new(SETTING_DIAL.FONT.PATH)
        local font_faceDial = gfx.font.new(FACE_DIAL.FONT.PATH)
        local function makeOneTimerUI(t, label)
            local name = t.name
            local isSelectable = false
            if label then isSelectable = true end       -- timer can be selected from menu
            local button = nil          -- timer-selecting button, if any
            local dial = nil            -- timer-duration-setting dial, if any
            local face = nil            -- timer clock-face

            if isSelectable then       -- selectable timer
                -- timer-selecting button
                button = Button({name .. "Button", BUTTONS.L.WIDTH, BUTTONS.M.HEIGHT})
                timerSelectButtons[name] = button
                button:setSound("touched", snd.sampleplayer.new(SOUND.timerButtonPressed.paths[name]), SOUND.timerButtonPressed.volume)
                button:setSound("selected", snd.sampleplayer.new(SOUND.timerButtonSelected.paths[name]), SOUND.timerButtonSelected.volume)
                button:setInteractivityCriteria(stateIsMENU)
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
                button:offsetPositions({selected = newVector(-BUTTONS.TRAVEL_DISTANCE, 0)})

                ---[[ -- Toggle color inversion on selected button
                button.justSelectedAction = function()
                    button.sounds.selected:play(1)
                    button:setImageDrawMode(gfx.kDrawModeInverted)
                end
                button.justDeselectedAction = function()
                    button:setImageDrawMode(gfx.kDrawModeCopy)
                end
                --]]

                if cursor then
                    cursor:addTarget(button, function ()
                        return button:getConfiguredPosition("selected") + newVector(button.width + MARGIN, 0)
                    end)
                end

                -- timer-setting dial
                dial = Dial({name .. "SettingDial", SETTING_DIAL.WIDTH/SETTING_DIAL.FONT.SCALE, SETTING_DIAL.HEIGHT/SETTING_DIAL.FONT.SCALE}, 1, 60)
                durationDials[name] = dial
                dial:setOnScreenCriteria(function() return
                    button:isOnScreen()
                    and button.isSelected()
                end)
                dial:setUpdatingCriteria(getCrankDialCircuitClosure)
                dial.getDialChange = crankhandler.subscribe(60//CRANK_DIAL_CIRCUIT.REVOLS_PER_HOUR)
                --dial:setUnit("min")
                dial:setValue(initialDurations[name])
                dial:setBackground(function(width, height)
                    gfx.setColor(COLOR_1)
                    gfx.fillRect(0, 0, width, height)
                end)
                dial:setFont(font_settingDial, gfx.kDrawModeInverted)
                dial:setScale(SETTING_DIAL.FONT.SCALE)
                dial:setPosition(MARGIN, MARGIN)
                local renderText = dial.renderText
                dial.renderText = function () -- render 1-digit values with a space in the tens position
                    if string.len(dial.text) == 1 then dial.text = " " .. dial.text end
                    renderText()
                end
                dial:setZIndex(timersMenu:getZIndex() - 10)
            end

            -- timer's clock face
            face = Dial({name .. "FaceDial", FACE_DIAL.WIDTH // FACE_DIAL.FONT.SCALE, FACE_DIAL.HEIGHT // FACE_DIAL.FONT.SCALE})
            face.getDialValue = function () return t:getClockTime() end
            face:setOnScreenCriteria(function () return t:isActive() end)
            face:setFont(font_faceDial)
            face:setScale(FACE_DIAL.FONT.SCALE)
            face:setPosition(W_CENTRE - face.width / 2, FACE_DIAL.Y)
            --[[ -- Check timer face sprite location
            local update = face.update
            face.update = function (self)
                d.illustrateBounds(self)
                update(self)
            end
            --]]

            -- TODO move func def below to be local func more visible at root of this file
            if isSelectable then           -- selectable timer
                button.pressedAction = function ()
                    face:setValue(dial.value)
                    toRun(t, dial.value)
                end
            end
            return button
        end

        for _, timer in pairs(timers) do
            local button = makeOneTimerUI(timer.t, timer.label)
            if button then list:addChildren(button, 'alwaysOnScreenWithParent') end
        end
    end

    local ntimers = #timers
    timersMenu = List(
        {"timersMenu",
        BUTTONS.L.WIDTH + MARGIN * 2,
        (BUTTONS.L.HEIGHT + MARGIN) * ntimers + MARGIN},
        list.orientations.vertical,
        MARGIN
    )
    timersMenu:setOnScreenCriteria(stateIsMENU)
    timersMenu:setInteractivityCriteria(stateIsMENU) --TODO lock this until elements have completed transition
    timersMenu:setPosition(W_SCREEN - (BUTTONS.L.WIDTH + MARGIN*2), MARGIN)
    timersMenu:offsetPositions({disabled = newVector(BUTTONS.TRAVEL_DISTANCE, 0)})

    local cursor = nil
    --[[ -- toggle timers-menu-navigating cursor
    cursor = Cursor({"timerSelectCursor", BUTTONS.TRAVEL_DISTANCE - MARGIN, BUTTONS.M.HEIGHT})
    cursor:setOnScreenCriteria(stateIsMENU)
    cursor:setBackground(function(width, height)
        gfx.setColor(COLOR_1)
        gfx.fillRoundRect(0, 0, width, height, height/2)
    end)
    cursor:setFont(gfx.getFont(), gfx.kDrawModeInverted)
    cursor:setText("A")
    cursor:setPosition(250, MARGIN)
    cursor:offsetPositions({disabled = newVector(BUTTONS.TRAVEL_DISTANCE * 2, 0)})
    cursor:setZIndex(timersMenu:getZIndex() + 10)
    cursor:forceConfigured()
    --]]

    makeTimerUI(timersMenu, timers, cursor)

    local timerDoneSign = UIElement({"timerDoneSign", 300, 100}) -- simple textbox
    timerDoneSign:setText("NEXT")
    timerDoneSign:setPosition(MARGIN, MARGIN)
    timerDoneSign:setOnScreenCriteria(stateIsDONE_TIMER)
    timerDoneSign:forceConfigured()

    --- Initialize a button that sits directly above the A or B buttons
    ---@param name string button name
    ---@param input A or B from the global namespace
    ---@param invisible boolean true iff button should be invisible
    ---@return Button
    local function makeABButton (name, input, invisible)
        local button = Button({name .. "Button", BUTTONS.L.HEIGHT, BUTTONS.TRAVEL_DISTANCE - MARGIN})
        
        button.isPressed = function () return pd.buttonIsPressed(input) end
        if not invisible then
            button:setBackground(drawButtonShapeAB)
            button:setFont(gfx.getFont(), gfx.kDrawModeInverted)
        end
        if input == A then
            button:setPosition(X_A_BUTTON, H_SCREEN - button.height * 2/3)
        elseif input == B then
            button:setPosition(X_B_BUTTON, H_SCREEN - button.height * 2/3)
        end
        button:offsetPositions({
                disabled = newVector(0,50),
                pressed = newVector(0, BUTTONS.TRAVEL_DISTANCE)
            },
            { pressed = { reverses = true } })
        button:repositionForeground(0.5, 0.4)
        button:forceConfigured()
        return button
    end
    
    backButton = makeABButton("back", B)
    backButton.pressedAction = function ()
        toMenu()
    end
    backButton:setOnScreenCriteria(function() return
        stateIsRUN_TIMER()
        or stateIsDONE_TIMER()
    end)
    backButton:setInteractivityCriteria(function() return
        stateIsRUN_TIMER()
        or stateIsDONE_TIMER()
    end)
    --local backIconRender = BackIcon("backButtonIcon", 14, 14, COLOR_0)
    --backButton:setForeground(backIconRender.imagetable)
    backButton:setForeground(gfx.image.new(ICON.backPath))

    skipButton = makeABButton("skip", A)
    skipButton.pressedAction = function ()
        toDone() --TODO should be a distinct function in main
    end
    skipButton:setOnScreenCriteria(stateIsRUN_TIMER)
    skipButton:setInteractivityCriteria(stateIsRUN_TIMER)
    skipButton:setForeground(gfx.image.new(ICON.skipPath))

    snoozeButton = makeABButton("snooze", B)
    snoozeButton.pressedAction = snooze
    snoozeButton:setOnScreenCriteria(function() return
        stateIsDONE_TIMER()
        and confs.snoozeOn
    end)
    snoozeButton:setInteractivityCriteria(stateIsDONE_TIMER)
    snoozeButton:setForeground(gfx.image.new(ICON.snoozePath))

    -- The next button is an invisible button parenting a dial that makes up the appearance of the button.
    -- This dial-button grows in size as the user snoozes, encouraging the user to press it instead of continuing to snooze.
    nextButton = makeABButton("next", A) --TODO "invisible"
    nextButton.pressedAction = function ()
        toMenu()
    end
    nextButton:setOnScreenCriteria(stateIsDONE_TIMER)
    nextButton:setInteractivityCriteria(stateIsDONE_TIMER)
    nextButton:setForeground(gfx.image.new(ICON.nextPath)) --TODO rm
    local nextButtonVisualizer = Dial({"nextButtonVisualizer", BUTTONS.L.HEIGHT,BUTTONS.TRAVEL_DISTANCE - MARGIN})
    nextButton:addChildren(nextButtonVisualizer, "alwaysOnScreenWithParent")
    nextButtonVisualizer.getDialValue = getSnoozeCount

    --- Initialize a score display.
    ---@param scoringFunc function that returns the score when called
    ---@return Dial new display dial
    local function makeScoreDisplay(unit, scoringFunc, width, height)
        local display = Dial({unit .. "Score", width, height})
        display:setUnit(unit)

        local prevScore = 0
        display.getDialValue = scoringFunc
        return display
    end

    --[[
    --TODO redesign, then remake these score displays
    scoreboard = List({"scoreboard", 100, 80})
    scoreboard:setOnScreenCriteria(stateIsDONE_TIMER)
    makeScoreDisplays(scoreboard, {
        snooze = getSnoozeCount
    })
    scoreboard:moveTo(300, 60)
    scoreboard:setZIndex(80)
    --]]

    local spacing = 4
    local pomCounter = gfx.image.new(POM_COUNTER.DIAMETER, POM_COUNTER.DIAMETER, COLOR_CLEAR)
    gfx.pushContext(pomCounter)
        gfx.setColor(COLOR_1)
        gfx.fillCircleAtPoint(POM_COUNTER.DIAMETER//2, POM_COUNTER.DIAMETER//2, POM_COUNTER.DIAMETER//2)
    gfx.popContext()

    local pomCountDisplay_menu = makeScoreDisplay("pomMenu", getPomCount,
        confs.pomsPerCycle * (POM_COUNTER.DIAMETER + spacing), POM_COUNTER.DIAMETER)
    pomCountDisplay_menu:setOnScreenCriteria(function () return
        stateIsMENU()
        and getPomCount() ~= 0
    end)
    pomCountDisplay_menu:setMode(dial.visualizers.horiCounter) -- visualize poms as counters
    pomCountDisplay_menu:setCounter(pomCounter, spacing)
    pomCountDisplay_menu:setPosition(MARGIN + SETTING_DIAL.WIDTH - pomCountDisplay_menu.width, MARGIN*2 + SETTING_DIAL.HEIGHT)
    pomCountDisplay_menu:setZIndex(400)

    local pomReel = UIElement({"pomReel", POM_COUNTER.REEL.DIAMETER + 2, POM_COUNTER.REEL.DIAMETER + 2})
    local pomReelRender = Reel("pomReel", reel.motions.cw, POM_COUNTER.REEL.DIAMETER, POM_COUNTER.REEL.LINE_WIDTH)
    pomReel:setForeground(pomReelRender.imagetable)
    pomReel:setPosition(MARGIN * 2, H_SCREEN - pomReel.height - MARGIN)
    pomReel:setOnScreenCriteria(stateIsRUN_TIMER)
    pomReel:setZIndex(120)
    pomReel.fg_anim:play(1, 0)
    pomReel:forceConfigured()
    local x_pomReel, y_pomReel = pomReel:getConfiguredPosition():unpack()

    -- TODO refactor (or at least rename) duplicate pomCountDisplay
    local pomCountDisplay_run = makeScoreDisplay("pomRun", getPomCount,
        confs.pomsPerCycle * (POM_COUNTER.DIAMETER + spacing), POM_COUNTER.DIAMETER)
    pomCountDisplay_run:setOnScreenCriteria(function () return
        stateIsRUN_TIMER()
        and getPomCount() ~= 0
    end)
    pomCountDisplay_run:setMode(dial.visualizers.horiCounter) -- visualize poms as counters
    pomCountDisplay_run:setCounter(pomCounter, spacing)
    pomCountDisplay_run:setPosition(x_pomReel + pomReel.width + spacing, y_pomReel + (pomReel.height/2 - pomCountDisplay_run.height/2))
    pomCountDisplay_run:setZIndex(80)

    initCrankDialCircuit()
end

--- Drives the UI. Call on pd.update().
local function update()
    switch.update()
    animation.update()
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
return uimanager