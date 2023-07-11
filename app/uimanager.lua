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

local imgPathPrefix <const> = "assets/ui/"
local fontPathPrefix <const> = "assets/fonts/"

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
    HEIGHT = H_SCREEN - 4 * MARGIN,
    Y = 2 * MARGIN,
    FONT = {
        PATH = fontPathPrefix .. "Ace Attacker",
        SCALE = 24
    }
}
local POM_COUNTER <const> = {
    DIAMETER = 15
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
local pomCountDisplay = nil
local menuInst = nil -- instructions shown in MENU --TODO move to init

local toMenuButton = nil -- return to timer-select menu
local runInst = nil -- instructions shown in RUN_TIMER state --TODO move to init

local snoozeButton = nil -- invisible snooze button --TODO move to init
local doneInst = nil -- instructions shown in DONE_TIMER state --TODO move to init
local scoreboard = nil -- visualizes snooze score for this timer session

local function bakeSwitchAnimation()
    local len_switch = CRANK_DIAL_CIRCUIT.SWITCH.LENGTH
    local w_frame = len_switch + 10
    local h_frame = len_switch + MARGIN + BUTTONS.M.WIDTH/2
    local n_frames = 10
    local C = 3/4 * pi                  -- phase shift
    local x_button = 0.1 * len_switch
    local y_button = len_switch + MARGIN + 2

    local Amp = 0.8 * len_switch       -- amplitude
    local radPerFrame = pi/4 / (n_frames - 1)
    local buttonTravelPerFrame = BUTTONS.TRAVEL_DISTANCE / n_frames

    local switchImagetable = gfx.imagetable.new(n_frames)
    local theta     local x     local y     local i_frame
    for j = 0, n_frames - 1 do
        local frame = gfx.image.new(w_frame, h_frame, COLOR_CLEAR)
        theta = j * radPerFrame
        x = Amp * cos(-theta - C)
        y = Amp * sin(-theta - C)
        gfx.pushContext(frame)
            gfx.setColor(COLOR_1)
            gfx.setLineWidth(CRANK_DIAL_CIRCUIT.WIRE.WIDTH)
            gfx.setLineCapStyle(gfx.kLineCapStyleRound)
            -- draw wire from (x,y) to the unit-circle origin, transposed by (len_switch, len_switch)
            gfx.drawLine(x + len_switch, y + len_switch, len_switch, len_switch)
            gfx.setLineWidth(4)
            -- draw tether from the switch wire to the B button
            x = x_button + BUTTONS.L.HEIGHT/2
            y = y + len_switch + 5
            gfx.drawLine(x, y, x, 242)
            -- draw B button
            x = x_button
            y = y_button + j*buttonTravelPerFrame
            gfx.fillRoundRect(x, y, BUTTONS.L.HEIGHT, BUTTONS.M.WIDTH, BUTTONS.L.HEIGHT/2)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            gfx.drawTextAligned("B", x + BUTTONS.L.HEIGHT/2, y + 10, kTextAlignment.center)
        gfx.popContext()

        i_frame = j + 1
        pd.datastore.writeImage(frame, imgPathPrefix .. "switch-table-" .. i_frame)
        switchImagetable:setImage(i_frame, frame)
    end
    

    return switchImagetable
end

--- Make and write the frames for the LED animations
---@return gfx.imagetable containing the preSwitchLED frames
---@return gfx.imagetable containing the postSwitchLED frames
local function bakeLEDAnimations()
    local period = 60                       -- period in terms of frames, rather than seconds
    local n_spokes = 5
    local w_frame = 60
    local h_frame = 60
    local lineWidth = 1.3                   -- scales the lineWidth
    local Amp = 22                            -- amplitude/scale of the graphic
    local C = pi/2                          -- phase shift

    local n_frames = (period / 2) // n_spokes  -- only show the front-facing half of the cycle
    local radPerFrame = 2 * pi / period
    local radPerSpoke = pi / n_spokes

    local preSwitchLEDImagetable = gfx.imagetable.new(n_frames)
    local postSwitchLEDImagetable = gfx.imagetable.new(n_frames)
    local theta     local x     local y     local i_frame
    for j = 0, n_frames-1 do
        local frame = gfx.image.new(w_frame, h_frame, COLOR_CLEAR)
        
        for k = 0, n_spokes-1 do
            theta = k*radPerSpoke + j*radPerFrame
            x = 6 * cos(theta - C)
            y = Amp * sin(theta - C) + h_frame//2
            gfx.pushContext(frame)
                gfx.setColor(COLOR_1)
                gfx.setLineCapStyle(gfx.kLineCapStyleRound)
                gfx.setLineWidth(x * lineWidth)
                gfx.drawLine((w_frame - x*3)/2, y, (w_frame + x*3)/2, y)
                -- Other unit circle-visualizers below
                --gfx.setLineWidth(6)
                --gfx.drawLine(2.5*w_frame - x*1.5, y, 2.5*w_frame + x*1.5, y)
                --x = Amp * cos(theta - C) + w_frame//2
                --gfx.drawLine(w_frame//2, h_frame//2, x, y)
                --gfx.fillCircleAtPoint(x + w_frame, y, 4)
            gfx.popContext()
        end
        
        local rotatedFrame = frame:rotatedImage(90)
        --TODO which direction should be forward?? reconfigure all dials if needed
        -- frames are saved in backwards order to match CW forwards motion
        i_frame = n_frames - j
        pd.datastore.writeImage(frame, imgPathPrefix .. "preSwitchLED-table-" .. i_frame)
        preSwitchLEDImagetable:setImage(i_frame, frame)
        pd.datastore.writeImage(rotatedFrame, imgPathPrefix .. "postSwitchLED-table-" .. i_frame)
        postSwitchLEDImagetable:setImage(i_frame, rotatedFrame)
    end
    return preSwitchLEDImagetable, postSwitchLEDImagetable
end

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
    wire:setEnablingCriteria(stateIsMENU)
    wire:forceConfigured()

    -- TODO we're searching for these files in the wrong place.
    -- They'll be saved in the app's folder in Data on the device.
    local switchImagetable = gfx.imagetable.new(imgPathPrefix .. "switch")
    if not switchImagetable then
        d.log("switch images not found; baking")
        switchImagetable = bakeSwitchAnimation()
    end
    switch:setForeground(switchImagetable)
    switch:setPosition(X_B_BUTTON - BUTTONS.L.HEIGHT/4, h_circuit - switch.height)
    switch.isPressed = function() return pd.buttonIsPressed(B) end
    switch.justReleasedAction = function ()
        switch.fg_anim:play(-1, 1, animation.bookmarks.first)
        crankDialSwitchIsClosed = false
    end
    switch:setSound("held", snd.sampleplayer.new(SOUND.crankDialSwitch.closing.path), SOUND.crankDialSwitch.closing.volume)
    switch:setSound("locked", snd.sampleplayer.new(SOUND.crankDialSwitch.closed.path), SOUND.crankDialSwitch.closed.volume)
    switch.pressedAction = function ()
        switch.fg_anim:play(1, 0, animation.bookmarks.last,
        function ()
            if not crankDialSwitchIsClosed then switch.sounds.locked:play(1) end -- play click sound iff switch was previously open
            crankDialSwitchIsClosed = true
        end)
    end

    local preSwitchLEDImagetable = gfx.imagetable.new(imgPathPrefix .. "preSwitchLED")
    local postSwitchLEDImagetable = gfx.imagetable.new(imgPathPrefix .. "postSwitchLED")
    if not preSwitchLEDImagetable or not postSwitchLEDImagetable then
        d.log("pre- or postSwitchLED images not found; baking")
        preSwitchLEDImagetable, postSwitchLEDImagetable = bakeLEDAnimations()
    end
    preSwitchLED:setForeground(preSwitchLEDImagetable, 16)
    preSwitchLED:setPosition(w_circuit - 50, h_circuit - 70)
    preSwitchLED.isSelected = function() return true end
    preSwitchLED.getDialChange = crankhandler.subscribe()
    preSwitchLED:setMode(dial.visualizers.animation)
    preSwitchLED:setSound("dialing", snd.fileplayer.new(SOUND.preSwitchLED.path), SOUND.preSwitchLED.volume) --would prefer a sampleplayer here
    postSwitchLED:setForeground(postSwitchLEDImagetable, 16)
    postSwitchLED:setPosition(10, 34)
    postSwitchLED.isSelected = getCrankDialCircuitClosure
    postSwitchLED.getDialChange = crankhandler.subscribe()
    postSwitchLED:setMode(dial.visualizers.animation)

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
    local function makeTimerUI (list, timers, cursor)
        local font_settingDial = gfx.font.new(SETTING_DIAL.FONT.PATH)
        local font_faceDial = gfx.font.new(FACE_DIAL.FONT.PATH)
        local function makeTimerSelector(t, label)
            local name = t.name

            -- timer-selecting button
            local button = Button({name .. "Button", BUTTONS.L.WIDTH, BUTTONS.M.HEIGHT})
            timerSelectButtons[name] = button
            button:setSound("touched", snd.sampleplayer.new(SOUND.timerButtonPressed.paths[name]), SOUND.timerButtonPressed.volume)
            button:setSound("selected", snd.sampleplayer.new(SOUND.timerButtonSelected.paths[name]), SOUND.timerButtonSelected.volume)
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
            local dial = Dial({name .. "SettingDial", SETTING_DIAL.WIDTH/SETTING_DIAL.FONT.SCALE, SETTING_DIAL.HEIGHT/SETTING_DIAL.FONT.SCALE}, 1, 60)
            durationDials[name] = dial
            dial:setEnablingCriteria(function() return
                button:isEnabled()
                and button.isSelected()
            end)
            dial.isSelected = getCrankDialCircuitClosure
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

            -- timer's clock face
            local face = Dial({name .. "FaceDial", FACE_DIAL.WIDTH // FACE_DIAL.FONT.SCALE, FACE_DIAL.HEIGHT // FACE_DIAL.FONT.SCALE})
            face.getDialValue = function () return t:getClockTime() end
            face:setEnablingCriteria(function () return t:isActive() end)
            face.isSelected(function () return true end)
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
            button.pressedAction = function ()
                face:setValue(dial.value)
                toRun(t, dial.value)
            end
            return button
        end

        for _, timer in pairs(timers) do
            list:addChildren(makeTimerSelector(timer.t, timer.label), 'parentEnables')
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
    timersMenu:setEnablingCriteria(stateIsMENU)
    timersMenu.isSelected = stateIsMENU
    timersMenu:setPosition(W_SCREEN - (BUTTONS.L.WIDTH + MARGIN*2), MARGIN)
    timersMenu:offsetPositions({disabled = newVector(BUTTONS.TRAVEL_DISTANCE, 0)})

    local cursor = nil
    --[[ -- toggle timers-menu-navigating cursor
    cursor = Cursor({"timerSelectCursor", BUTTONS.TRAVEL_DISTANCE - MARGIN, BUTTONS.M.HEIGHT})
    cursor:setEnablingCriteria(stateIsMENU)
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
    timerDoneSign:setEnablingCriteria(stateIsDONE_TIMER)
    timerDoneSign:forceConfigured()

    --- Initialize a button that sits directly above the A or B buttons
    ---@param name string button name
    ---@param input A or B from the global namespace
    ---@return Button
    local function makeABButton (name, input)
        local button = Button({name .. "Button", BUTTONS.L.HEIGHT, BUTTONS.TRAVEL_DISTANCE - MARGIN})
        
        button.isPressed = function () return pd.buttonIsPressed(input) end
        button:setBackground(function(width, height)
            gfx.setColor(COLOR_1)
            gfx.fillRoundRect(0, 0, width, height, width/2)
        end)
        button:setFont(gfx.getFont(), gfx.kDrawModeInverted)
        button:setText(string.sub(name, 1, 1))
        if input == A then
            button:setPosition(X_A_BUTTON, H_SCREEN - button.height * 2/3)
        elseif input == B then
            button:setPosition(X_B_BUTTON, H_SCREEN - button.height * 2/3)
        end
        button:offsetPositions({ disabled = newVector(0,50),
                            pressed = newVector(0, BUTTONS.TRAVEL_DISTANCE)})
        button:forceConfigured()
        return button
    end
    
    toMenuButton = makeABButton("toMenu", B)
    toMenuButton.pressedAction = function ()
        toMenu()
    end
    toMenuButton:setEnablingCriteria(function() return
        stateIsRUN_TIMER()
        or stateIsDONE_TIMER()
    end)
    toMenuButton:offsetPositions({}, { pressed = { reverses = true }})

    snoozeButton = makeABButton("snooze", A)
    snoozeButton.pressedAction = snooze
    snoozeButton:setEnablingCriteria(function() return
        stateIsDONE_TIMER()
        and confs.snoozeOn
    end)
    snoozeButton:offsetPositions({}, { pressed = { reverses = true }})


    --- Initialize a score display.
    ---@param scoringFunc function that returns the score when called
    ---@return Dial new display dial
    local function makeScoreDisplay(unit, scoringFunc, width, height)
        local display = Dial({unit .. "Score", width, height})
        display.isSelected = function() return true end
        display:setUnit(unit)

        local prevScore = 0
        display.getDialValue = scoringFunc
        return display
    end

    --[[
    --TODO redesign, then remake these score displays
    scoreboard = List({"scoreboard", 100, 80})
    scoreboard:setEnablingCriteria(stateIsDONE_TIMER)
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
    pomCountDisplay = makeScoreDisplay("pom", getPomCount,
        confs.pomsPerCycle * (POM_COUNTER.DIAMETER + spacing), POM_COUNTER.DIAMETER)
    pomCountDisplay:setEnablingCriteria(function () return
        stateIsMENU()
        and getPomCount() ~= 0
    end)
    d.log("setting mode")
    pomCountDisplay:setMode(dial.visualizers.horiCounter) -- visualize poms as counters
    pomCountDisplay:setCounter(pomCounter, spacing)
    pomCountDisplay:setPosition(MARGIN + SETTING_DIAL.WIDTH - pomCountDisplay.width, MARGIN*2 + SETTING_DIAL.HEIGHT)
    pomCountDisplay:setZIndex(80)

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
uimanager = utils.makeReadOnly(uimanager)
return uimanager