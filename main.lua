-- if multiple packages need the same import, put that import here
-- todo write or install a tool to verify that there are no redundant imports in the proj
-- todo replace all func comments w the template generated when --- is typed
-- todo replace type-checking or similar if statements with assert()
-- todo name private fields on objects _var like in the pd sdk
-- todo for all classes, add @property docs to @class doc
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/ui"

import "utils"; --utils.disableReadOnly()
import "configs"
import "debugger"
import "timer"
import "ui/uimanager"

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

-- TODO can states be a set of update funcs, or do we need the enum?
STATES = configs.STATES
state = STATES.LOADING

local ui = nil
local workMinutes = 0.1
local splashSprite = nil
timers = {
    work = 'nil',
    short = 'nil',
    long = 'nil'
}
currentTimer = nil

-- init() sets up our game environment.
local function init()
    --debugger.disable()

    ui = UIManager()

    timers.work = Timer("work")
    timers.short = Timer("short")
    timers.long = Timer("long")
    timers = utils.makeReadOnly(timers, "timers")
    currentTimer = timers.work
end

local function splash()
    -- TODO maybe the configs really should just be globals in main. or in configs.lua w/o namespacing
    local splashImg = gfx.image.new(configs.W_SCREEN, configs.H_SCREEN)
    gfx.pushContext(splashImg)
        gfx.drawText("*POMDATE*", 50, 90)
        gfx.drawText("press A to continue", 50, 140)
    gfx.popContext()
    splashSprite = gfx.sprite.new(splashImg)
    splashSprite:setCenter(0, 0) --anchor top-left
    splashSprite:setZIndex(100)
    splashSprite:add()
    pd.ui.crankIndicator:start()
end

-- 2 funcs below can be moved to ui

-- performs done -> select transition
-- then inits select
-- then switches update func
-- TODO need to transition run -> select sometimes; refactor
-- TODO align semantics of menu w pause
function toMenu()
    currentTimer:stop()
    currentTimer:remove() -- DEBUG dont actually want to do exactly this
    pd.setAutoLockDisabled(false)
    state = STATES.MENU
end

function toRun()
    d.log(currentTimer.name)
    currentTimer:moveTo(50, 85)
    currentTimer:add()
    currentTimer:start(workMinutes)
    pd.setAutoLockDisabled(true)
    state = STATES.TIMER
end

-- pd.update() is called right before every frame is drawn onscreen.
function pd.update()
    if state == STATES.LOADING then
        pd.ui.crankIndicator:update() --TODO why isnt this working??
        if pd.buttonJustPressed(A) then
            splashSprite:remove()
            ui:add()
            toMenu()
        end
    elseif state == STATES.TIMER then --TODO we are doing way too many STATES lookups
        if pd.buttonJustPressed(B) then
            toMenu()
        end
    end

    pd.timer.updateTimers()
    gfx.sprite.update()
end

-- debugDraw() is called immediately after update()
-- Only white pixels are drawn; black transparent
function pd.debugDraw()
    gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        d.drawLog()
        d.drawIllustrations()
    gfx.popContext()
end

------- APP START -------

splash()
init()