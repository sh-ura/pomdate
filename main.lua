-- if multiple packages need the same import, put that import here
-- todo write or install a tool to verify that there are no redundant imports in the proj
-- todo replace all func comments w the template generated when --- is typed
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

import "utils"; --utils.disableReadOnly()
import "configs"
import "debugger"
import "timer"
import "button"

local pd <const> = playdate
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

-- TODO can states be a set of update funcs, or do we need the enum?
STATES = configs.STATES
state = STATES.loadApp -- should be loadApp
local update = nil
local initComplete = false

local selectedTimer = nil
local workTimer = nil; local workMinutes = nil
local splashImg = nil; local splashSprite = nil
local workButton = nil

-- debugDraw() is called immediately after update()
-- Only white pixels are drawn; black transparent
function pd.debugDraw()
    gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        debugger.drawLog()
        debugger.drawIllustrations()
    gfx.popContext()
end

-- init() sets up our game environment.
local function init()
    debugger.disable()
    
    workMinutes = 0.1
    workTimer = timer.new(0, 0)

    workButton = button.new(
        "work",
        0,
        0,
        function ()
            selectedTimer = workTimer
            toRun()
        end
    )
    
    selectedTimer = workTimer
    initComplete = true
end


function toLoadApp()
    -- TODO maybe the configs really should just be globals in main. or in configs.lua w/o namespacing
    splashImg = gfx.image.new(configs.W_SCREEN, configs.H_SCREEN)
    gfx.lockFocus(splashImg)
        gfx.drawText("POMDATE", configs.W_CENTRE, configs.H_CENTRE)
    gfx.unlockFocus()
    splashSprite = gfx.sprite.new(splashImg)
    splashSprite:moveTo(configs.W_CENTRE, configs.H_CENTRE)
    splashSprite:add()
    update = loadAppUpdate
end

-- performs done -> select transition
-- then inits select
-- then switches update func
-- TODO need to transition run -> select sometimes; refactor
function toSelect()
    selectedTimer:stop()
    selectedTimer:remove() -- DEBUG dont actually want to do exactly this
    
    workButton:add()

    update = selectUpdate
end

function toRun()
    workButton:remove()

    selectedTimer:moveTo(50, 50)
    selectedTimer:add()
    selectedTimer:start(workMinutes)
    update = runUpdate
end

function loadAppUpdate()
    local playerReady = false
    if pd.buttonJustPressed(A) then
        playerReady = true
    end
    if initComplete and playerReady then
        splashSprite:remove()
        toSelect()
    end
end

function selectUpdate ()
    -- check inputs; select buttons accordingly
    -- if a pressed, transition to run state
    if pd.buttonJustPressed(A) then
        workButton:press()
    end
end

function runUpdate()
    if pd.buttonJustPressed(B) then
        toSelect()
    end
    pd.timer.updateTimers() -- DEBUG does having this here cause issues with starting timers?
end

-- update() is called right before every frame is drawn onscreen.
function pd.update()
    update()

    gfx.sprite.update()
end

toLoadApp()
init()