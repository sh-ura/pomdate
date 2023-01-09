import "CoreLibs/object"
import "CoreLibs/graphics"

import "config"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- TODO test scope of these vars by attempting to mod them from another file
local W_LEFT_MARGIN <const> = 2
local H_LINE <const> = 16
local NUM_LINES <const> = 15 -- 240/16 (screen height / line height)

-- TODO set disableDebugger flag

-- Debugger generates and draws a message log image.
class('Debugger').extends()

-- Debugger:init() initializes a new Debugger
function Debugger:init()
    -- TODO test scope of these vars by attempting to mod them from another file
    self.logImg = gfx.image.new(W_SCREEN, H_SCREEN)     -- img containing debug log
    self.cMsgs = 0                                      -- logged message count
    self.illImg = gfx.image.new(W_SCREEN, H_SCREEN)     -- img containing illustrations

    print("debugger init")
end

-- Debugger:log(message) adds text to the debug log.
-- Messages are prepended by the message count at the time of logging.
-- Returns current message count.
-- Log is drawn upon calling Debugger:draw()
function Debugger:log(msg)
    self.cMsgs = self.cMsgs + 1
    local logText = self.cMsgs .. ": " .. msg

    local iLine = math.fmod(self.cMsgs - 1, NUM_LINES) -- index of current line to draw
    local xpos = W_LEFT_MARGIN
    local ypos = iLine * H_LINE

    print(logText)
    gfx.pushContext(self.logImg)
        gfx.setColor(gfx.kColorClear)
        gfx.fillRect(xpos, ypos, W_SCREEN, H_LINE) -- clear the current line
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText(logText, xpos, ypos)
    gfx.popContext()

    return self.cMsgs
end

-- Debugger:draw() draws the debug log image in black pixels.
-- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
--  visualization by pd.debugDraw()
function Debugger:drawLog()
    self.logImg:draw(0,0)
end

-- Debugger:draw() draws the debug illustrations image in black pixels.
-- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
--  visualization by pd.debugDraw()
function Debugger:drawIllustrations()
    self.illImg:draw(0,0)
end


-- Debugger:clear() clears the log image of all content.
-- Avoid using if possible. Inconvenient special effects.
-- TODO could modify to clear message at a specific index
function Debugger:clear()
    gfx.pushContext(self.img)
        gfx.clear()
    gfx.popContext()
end


function Debugger:bounds(sprite)
    gfx.pushContext(self.illImg)
        gfx.drawRect(sprite:getBounds())
    gfx.popContext()
end
