import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA

local SEC_PER_MIN <const> = 60

--local font = nil
--local targetSec = nil

-- changing images does change the appearance of sprites using that image
local debugImg = nil
local timerImg = nil
local instructorImg = nil
local notifImg = nil

local debugSprite = nil
local timerSprite = nil
local instructorSprite = nil
local notifSprite = nil

local function countdown()
    return math.max(targetSeconds - pd.getElapsedTime(), 0)
end

-- init sets up our game environment.
local function init()
    targetSeconds = 0.1 * SEC_PER_MIN -- 25 mins

    -- TODO encapsulate all sprites below into classes
    -- incl. the debugger

    debugImg = gfx.image.new(400, 16)
    timerImg = gfx.image.new(400, 16)
    notifImg = gfx.image.new(400, 16)
    instructorImg = gfx.image.new(400, 16)

    gfx.lockFocus(instructorImg)
        gfx.drawText("press A to reset timer", 0, 0)
    gfx.unlockFocus()

    -- need to add smth to sprite list to initialize it prior to drawing anything
    -- sprite must have size to be drawn
    debugSprite = gfx.sprite.new(debugImg)
    instructorSprite = gfx.sprite.new(instructorImg)
    notifSprite = gfx.sprite.new(notifImg)
    timerSprite = gfx.sprite.new(timerImg)

--[[
        :update() is called before :draw is called on all sprites
        Suspected conditions for redrawing a sprite if getAlwaysRedraw() == false
            - associated gfx.image has changed
            - sprite has had some transform applied to it
        So if we need to update a sprite every frame, do something in its :update()
        TODO try setting a class var for timerSprite that we update here and print 
            in :draw(). See if that marks it to be redrawn every frame
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
    debugSprite:setZIndex(100)
    debugSprite:moveTo(200, 224)
    debugSprite:add()
end

init()

-- update is called right before every frame is drawn onscreen.
function pd.update()
    if pd.buttonIsPressed(A) then
        pd.resetElapsedTime()

        gfx.lockFocus(debugImg)
            gfx.clear()
            gfx.drawText("timer reset", 0, 0)
        gfx.unlockFocus()
    else
        gfx.lockFocus(debugImg)
            gfx.clear()
        gfx.unlockFocus()
    end

    -- failing to call timerSprite:draw()
    gfx.sprite.update()
end