import "CoreLibs/object"
import "CoreLibs/graphics"

import "config"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- TODO test scope of these vars by attempting to mod them from another file
local W_LEFT_MARGIN <const> = 2
local H_LINE <const> = 16
local NUM_LINES <const> = 15 -- 240/16 (screen height / line height)

-- TODO disableDebugger flag

local logImg = gfx.image.new(W_SCREEN, H_SCREEN)     -- img containing debug log
local cMsgs = 0                                      -- logged message count
local illImg = gfx.image.new(W_SCREEN, H_SCREEN)     -- img containing illustrations

debugger = {
    -- log(message) adds text to the debug log.
    -- Messages are prepended by the message count at the time of logging.
    -- Returns current message count.
    -- Log is drawn upon calling debugger.draw()
    log = function (msg)
        cMsgs = cMsgs + 1
        local logText = cMsgs .. ": " .. msg

        local iLine = math.fmod(cMsgs - 1, NUM_LINES) -- index of current line to draw
        local xpos = W_LEFT_MARGIN
        local ypos = iLine * H_LINE

        print(logText)
        gfx.pushContext(logImg)
            gfx.setColor(gfx.kColorClear)
            gfx.fillRect(xpos, ypos, W_SCREEN, H_LINE) -- clear the current line
            gfx.setColor(gfx.kColorBlack)
            gfx.drawText(logText, xpos, ypos)
        gfx.popContext()

        return cMsgs
    end,

    -- draw() draws the debug log image in black pixels.
    -- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
    --  visualization by pd.debugDraw()
    drawLog = function ()
        logImg:draw(0,0)
    end,
    
    -- clearLog() clears the log image of all content.
    -- Avoid using if possible. Inconvenient special effects.
    -- TODO could modify to clear message at a specific index
    clearLog = function ()
        gfx.pushContext(logImg)
            gfx.clear()
        gfx.popContext()
    end,

    -- bounds(sprite) visualizes the rectangular bounds of the sprite
    bounds = function (sprite)
        gfx.pushContext(illImg)
            gfx.drawRect(sprite:getBounds())
        gfx.popContext()
    end,

    -- drawIllustrations() draws the debug illustrations image in black pixels.
    -- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
    --  visualization by pd.debugDraw()
    drawIllustrations = function ()
        illImg:draw(0,0)
    end,

    -- clearIllustrations() clears the log image of all content.
    -- Avoid using if possible. Inconvenient special effects.
    -- TODO could modify to clear message at a specific index
    clearIllustrations = function ()
        gfx.pushContext(logImg)
            gfx.clear()
        gfx.popContext()
    end
}








