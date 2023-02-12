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
import "ui/ui"

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local uilib <const> = ui
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

-- TODO can states be a set of update funcs, or do we need the enum?
STATES = configs.STATES
state = STATES.LOADING
local initComplete = false

local ui = nil
local selectedTimer = nil
local workMinutes = 0.1
local splashImg;    local splashSprite = nil
timers = {
    work = 'nil',
    short = 'nil',
    long = 'nil'
}

-- debugDraw() is called immediately after update()
-- Only white pixels are drawn; black transparent
function pd.debugDraw()
    gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        d.drawLog()
        d.drawIllustrations()
    gfx.popContext()
end

-- init() sets up our game environment.
local function init()
    --debugger.disable()

    ui = UI()
    
    timers.work = Timer()
    selectedTimer = timers.work

    initComplete = true
end


local function splash()
    -- TODO maybe the configs really should just be globals in main. or in configs.lua w/o namespacing
    splashImg = gfx.image.new(configs.W_SCREEN, configs.H_SCREEN)
    gfx.lockFocus(splashImg)
        gfx.drawText("POMDATE", configs.W_CENTRE, configs.H_CENTRE)
        gfx.drawText("press A to continue", configs.W_CENTRE, configs.H_CENTRE + 50)
    gfx.unlockFocus()
    splashSprite = gfx.sprite.new(splashImg)
    splashSprite:moveTo(configs.W_CENTRE, configs.H_CENTRE)
    splashSprite:setZIndex(100)
    splashSprite:add()
end

-- 2 funcs below can be moved to ui

-- performs done -> select transition
-- then inits select
-- then switches update func
-- TODO need to transition run -> select sometimes; refactor
-- TODO align semantics of menu w pause
function toMenu()
    selectedTimer:stop()
    selectedTimer:remove() -- DEBUG dont actually want to do exactly this
    state = STATES.MENU
end

function toRun()
    selectedTimer:moveTo(50, 50)
    selectedTimer:add()
    selectedTimer:start(workMinutes)
    state = STATES.TIMER
end




-- pd.update() is called right before every frame is drawn onscreen.
function pd.update()
    if state == STATES.LOADING then
        if pd.buttonJustPressed(A) then
            splashSprite:remove()
            ui:add()
            toMenu()
        end
    elseif state == STATES.TIMER then --TODO we are doing way too many STATES lookups
        if pd.buttonJustPressed(B) then
            toMenu()
        end
        pd.timer.updateTimers() -- DEBUG does having this here cause issues with starting timers?    
    end

    gfx.sprite.update()
end

------- APP START -------

splash()
init()