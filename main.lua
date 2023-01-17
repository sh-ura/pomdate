-- if multiple packages need the same import, put that import here
-- todo write or install a tool to verify that there are no redundant imports in the proj
import "CoreLibs/object"
import "CoreLibs/graphics"

import "config"
import "utils"
import "debugger"
import "timer"

-- TODO move to config??
local pd <const> = playdate
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA

local workTimer = nil; local workMinutes = nil

-- changing images does change the appearance of sprites using that image
local instructorImg = nil; local instructorSprite = nil

debugger.setEnabled(true)

-- init() sets up our game environment.
local function init()
    workMinutes = 0.1
    workTimer = Timer(50, 50)
    workTimer:add()

    -- TODO encapsulate all sprites below into classes

    instructorImg = gfx.image.new(W_SCREEN, 16)

    gfx.lockFocus(instructorImg)
        gfx.drawText("press A to reset timer", 0, 0)
    gfx.unlockFocus()

    -- need to add smth to sprite list to initialize it prior to gfx.draw()ing anything
    -- sprite must have size to be drawn
    -- moveTo moves sprite by its anchor point, defaulted to centre of sprite size
    instructorSprite = gfx.sprite.new(instructorImg)
    instructorSprite:setCenter(0, 0)
    instructorSprite:add()

    workTimer:start(workMinutes)
end

init()

-- update() is called right before every frame is drawn onscreen.
function pd.update()
    if pd.buttonJustPressed(A) then
        workTimer:reset()
    end

    pd.timer.updateTimers()
    gfx.sprite.update()
end

-- debugDraw() is called immediately after update()
-- Only white pixels are drawn; black transparent
function pd.debugDraw()
    gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        debugger.drawLog()
        debugger.drawIllustrations()
    gfx.popContext()
end