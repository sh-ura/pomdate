--- pkg debugger provides a Debugger for drawing and logging debugging messages

local P = {}; local _G = _G

local pd <const> = playdate -- _G.playdate etc
local gfx <const> = pd.graphics
local printTable = printTable
local print = print
local type = type
local pairs = pairs
local fmod = math.fmod -- TODO may be able to replace this w % modulo lua operator?

local W_SCREEN <const> = W_SCREEN
local H_SCREEN <const> = H_SCREEN
local COLOR_CLEAR <const> = COLOR_CLEAR
local W_LEFT_MARGIN <const> = 2
local H_LINE <const> = 16
local NUM_LINES <const> = 15 -- 240/16 (screen height / line height)

local _ENV = P
name = "debugger"

local cMsgs = 0                                                 -- logged message count
local logImg = gfx.image.new(W_SCREEN, H_SCREEN, COLOR_CLEAR)   -- img containing log
local illImg = gfx.image.new(W_SCREEN, H_SCREEN, COLOR_CLEAR)   -- img containing illustrations
local enabled = true                                            -- true by default. true if debugger is enabled

--TODO distinguish logWarn from logDebug + allow dev to disable
--      drawing one or the other log
--- log adds text to the debug log.
--- Messages are prepended by the message count at the time of logging.
--- Returns current message count.
--- Log is drawn upon calling debugger.draw()
---@param msg string message
---@param ... any anything to dump to console.
function log (msg, ...)
    cMsgs = cMsgs + 1

    local logText = cMsgs .. "- " .. msg

    local iLine = fmod(cMsgs - 1, NUM_LINES) -- index of current line to draw
    local xpos = W_LEFT_MARGIN
    local ypos = iLine * H_LINE

    print(logText)
    if ... then
        logText = logText .. " DUMPING"
        for k,v in pairs({...}) do
            print("-- DUMPING ARG " .. k .. " BELOW ; TYPE IS " .. type(v).." --")
            dump(v)
        end
    end

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
function clearLog ()
    gfx.pushContext(logImg)
        gfx.clear()
    gfx.popContext()
end

-- drawLog() draws the debug log image in black pixels.
-- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
--  visualization by pd.debugDraw()
function drawLog ()
    logImg:draw(0,0)
end

--TODO need to rename this to draw..... despite naming clash..
-- Visualizes the rectangular bounds of the sprite.
function illustrateBounds (sprite)
    gfx.pushContext(illImg)
        gfx.drawRect(sprite:getBounds())
    gfx.popContext()
end

--TODO for some reason this makes log messages disappear
-- clearIllustrations() clears the log image of all content.
-- Avoid using if possible. Inconvenient special effects.
function clearIllustrations ()
    gfx.pushContext(illImg)
        gfx.clear()
    gfx.popContext()
end

-- drawIllustrations() draws the debug illustrations image in black pixels.
-- Call gfx.setImageDrawMode(gfx.kDrawModeInverted) prior to this func for
--  visualization by pd.debugDraw()
function drawIllustrations ()
    illImg:draw(0,0)
end

--- Print an object to console.
--- Ignores anything with a nil value.
---@param o any object to dump
function dump(o)
    if type(o) == 'table' then
        printTable(o)
    else
        print(o)
    end
end
 

local _ENV = _G
-- debugger is the package wrapper: a mostly-empty middle layer between
--      P:        the package contents, and
--      mt:       the metatable configuring access to those contents
-- This permits the disabling of all debugger functions.
--TODO when debugger is class-ified: write utils.makeDisableable
debugger = {
    disable = function()
        enabled = false
        print("debugger disabled")
    end
}
local mt = {
    __index = function(t,k)
        if enabled then
            return P[k]
        else
            return function () end -- do nothing but remain callable
        end
    end,
    __newindex = P
}
setmetatable(debugger, mt)

return debugger
