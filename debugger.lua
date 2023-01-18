local pd <const> = playdate -- _G.playdate etc
local gfx <const> = pd.graphics
local W_SCREEN = configs.W_SCREEN
local H_SCREEN = configs.H_SCREEN

local W_LEFT_MARGIN <const> = 2
local H_LINE <const> = 16
local NUM_LINES <const> = 15 -- 240/16 (screen height / line height)

local cMsgs = 0                                      -- logged message count
local logImg = gfx.image.new(W_SCREEN, H_SCREEN)     -- img containing log
local illImg = gfx.image.new(W_SCREEN, H_SCREEN)     -- img containing illustrations
local enabled = true                                 -- true by default. true if debugger is enabled


-- log(message) adds text to the debug log.
-- Messages are prepended by the message count at the time of logging.
-- Returns current message count.
-- Log is drawn upon calling debugger.draw()
local function log (msg)
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
end

-- clearLog() clears the log image of all content.
-- Avoid using if possible. Inconvenient special effects.
-- TODO could modify to clear message at a specific index
local function clearLog ()
    gfx.pushContext(logImg)
        gfx.clear()
    gfx.popContext()
end

-- drawLog() draws the debug log image in black pixels.
-- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
--  visualization by pd.debugDraw()
local function drawLog ()
    logImg:draw(0,0)
end

-- bounds(sprite) visualizes the rectangular bounds of the sprite
local function bounds (sprite)
    gfx.pushContext(illImg)
        gfx.drawRect(sprite:getBounds())
    gfx.popContext()
end

-- clearIllustrations() clears the log image of all content.
-- Avoid using if possible. Inconvenient special effects.
-- TODO could modify to clear message at a specific index
local function clearIllustrations ()
    gfx.pushContext(logImg)
        gfx.clear()
    gfx.popContext()
end

-- drawIllustrations() draws the debug illustrations image in black pixels.
-- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
--  visualization by pd.debugDraw()
local function drawIllustrations ()
    illImg:draw(0,0)
end


-- debugger is actually a mostly-empty middle layer between
--      - mt: the access metatable, and 
--      - exported: the table of exported functions and values
local exported = {
    name = "debugger",
    log = log,
    clearLog = clearLog,
    drawLog = drawLog,
    bounds = bounds,
    clearIllustrations = clearIllustrations,
    drawIllustrations = drawIllustrations
}
local readonly = utils.makeReadOnly(exported)
debugger = {
    disable = function()
        enabled = false
        print("debugger disabled")
    end
}
local mt = {
    __index = function(t,k)
        if enabled then
            return readonly[k]
        else 
            -- TODO try removing ... below
            return function (...) end -- do nothing but remain callable
        end
    end,
    __newindex = readonly
}
setmetatable(debugger, mt)

return debugger
