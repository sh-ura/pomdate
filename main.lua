import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "debugger"

local pd <const> = playdate
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA

local SEC_PER_MIN <const> = 60

--local font = nil
local targetSeconds = nil
local debugger = nil

-- changing images does change the appearance of sprites using that image
local timerImg = nil
local instructorImg = nil
local notifImg = nil

local timerSprite = nil
local instructorSprite = nil
local notifSprite = nil

local function countdown()
    return math.max(targetSeconds - pd.getElapsedTime(), 0)
end

-- init() sets up our game environment.
local function init()
    debugger = Debugger()

    targetSeconds = 0.1 * SEC_PER_MIN -- 25 mins

    -- TODO encapsulate all sprites below into classes

    timerImg = gfx.image.new(400, 16)
    notifImg = gfx.image.new(400, 16)
    instructorImg = gfx.image.new(400, 16)

    gfx.lockFocus(instructorImg)
        gfx.drawText("press A to reset timer", 0, 0)
    gfx.unlockFocus()

    -- need to add smth to sprite list to initialize it prior to drawing anything
    -- sprite must have size to be drawn
    instructorSprite = gfx.sprite.new(instructorImg)
    notifSprite = gfx.sprite.new(notifImg)
    timerSprite = gfx.sprite.new(timerImg)

--[[
        :update() is called before :draw is called on all sprites
        Suspected conditions for redrawing a sprite if getAlwaysRedraw() == false
            - associated gfx.image has changed
            - sprite has had some transform applied to it
        So if we need to update a sprite every frame, do something in its :update()
--]]
    function timerSprite:update()
        gfx.lockFocus(timerImg)
            gfx.clear()
            gfx.drawText(countdown(), 160, 0)
        gfx.unlockFocus()
    end

    -- moveTo moves sprite by its anchor point, defaulted to centre of sprite size
    instructorSprite:moveTo(200, 16)
    instructorSprite:add()
    timerSprite:moveTo(200, 120)
    timerSprite:add()
    notifSprite:moveTo(200, 150)
    notifSprite:add()
end

init()

-- update() is called right before every frame is drawn onscreen.
function pd.update()
    if pd.buttonJustPressed(A) then
        pd.resetElapsedTime()
        debugger:log("timer reset")
    end

    gfx.sprite.update()
end

-- debugDraw() is called immediately after update()
-- Only white pixels are drawn; black transparent
function pd.debugDraw()
    debugger:draw()
end