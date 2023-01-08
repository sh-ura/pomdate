import "CoreLibs/timer"

local pd <const> = playdate
local gfx = pd.graphics

-- TODO test scope of these vars by attempting to mod them from another file
local W_SCREEN = 400
local H_SCREEN = 240
local W_LEFT_MARGIN <const> = 2
local H_LINE <const> = 16
local NUM_LINES <const> = 15 -- 240/16 (screen height / line height)

-- Debugger generates and draws a message log image
class('Debugger').extends()

-- Debugger:init() initializes a new Debugger
function Debugger:init()
    -- TODO test scope of these vars by attempting to mod them from another file
    self.img = playdate.graphics.image.new(400, 240)    -- img containing debug log
    self.cMsgs = 0                                       -- logged message count

    print("debugger init")
end

-- Debugger:log(message) adds text to the debug log
-- Messages are prepended by the message count at the time of logging
-- Returns current message count
-- Log is drawn upon calling Debugger:draw()
function Debugger:log(msg)
    self.cMsgs = self.cMsgs + 1

    local iLine = math.fmod(self.cMsgs - 1, NUM_LINES) -- index of current line to draw
    local xpos = W_LEFT_MARGIN
    local ypos = iLine * H_LINE

    gfx.pushContext(self.img) -- not sure if this is needed
        gfx.setColor(gfx.kColorClear)
        gfx.fillRect(xpos, ypos, W_SCREEN, H_LINE) -- clear the current line
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText(self.cMsgs .. ": " .. msg, xpos, ypos)
    gfx.popContext()

    return self.cMsgs
end

-- Debugger:draw() draws the log image in white pixels, for ease of use in debugDraw
function Debugger:draw()
    gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        self.img:draw(0,0)
    gfx.popContext()
end

-- Debugger:clear() clears the log image of all content
-- Avoid using if possible. Inconvenient special effects.
-- TODO could modify to clear message at a specific index
function Debugger:clear(iMsg)
    gfx.pushContext(self.img)
        gfx.clear()
    gfx.popContext()
end
