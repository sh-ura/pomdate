---pkg Spinner can render a spinner animation in various orientations and directions of motion.
-- pkg header: define pkg namespace
spinner = {}
local _G = _G

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local Render <const> = Render
local COLOR = GFX.COLOR
local pathPrefix = GFX.GEN.pathPrefix
local pi <const> = math.pi
local sin <const> = math.sin
local cos <const> = math.cos

---TODO Spinner desc
class('Spinner').extends(Render)
local Spinner <const> = Spinner
local _ENV = spinner      -- enter pkg namespace
name = "spinner"

orientations = {
    vertical = 0,
    horizontal = 90
}

motions = {
    cw = 1,
    ccw = -1
}

function Spinner:init(name, orientation, motion)
    if not orientation then
        d.log("Spinner " .. name .. " orientation not valid. Defaulting to vert")
        orientation = orientations.vertical
    end
    self._orientation = orientation

    if not motion then
        d.log("Spinner " .. name .. " motion dir not valid. Defaulting to cw")
        motion = motions.cw
    end
    self._motion = motion

    Spinner.super.init(self, name)
end

function Spinner:bake()
    local period = 60                       -- period in terms of frames, rather than seconds
    local n_spokes = 5
    local w_frame = 60
    local h_frame = 60
    local lineWidth = 1.3                   -- scales the lineWidth
    local Amp = 22                            -- amplitude/scale of the graphic
    local C = pi/2                          -- phase shift

    local n_frames = (period / 2) // n_spokes  -- only show the front-facing half of the cycle
    local radPerFrame = 2 * pi / period
    local radPerSpoke = pi / n_spokes

    local imagetable = gfx.imagetable.new(n_frames)
    local theta     local x     local y     local i_frame
    for j = 0, n_frames-1 do
        local frame = gfx.image.new(w_frame, h_frame, COLOR.clear)
        
        for k = 0, n_spokes-1 do
            theta = k*radPerSpoke + j*radPerFrame
            x = 6 * cos(theta - C)
            y = Amp * sin(theta - C) + h_frame//2
            gfx.pushContext(frame)
                gfx.setColor(COLOR.pos)
                gfx.setLineCapStyle(gfx.kLineCapStyleRound)
                gfx.setLineWidth(x * lineWidth)
                gfx.drawLine((w_frame - x*3)/2, y, (w_frame + x*3)/2, y)
                -- Other unit circle-visualizers below
                --gfx.setLineWidth(6)
                --gfx.drawLine(2.5*w_frame - x*1.5, y, 2.5*w_frame + x*1.5, y)
                --x = Amp * cos(theta - C) + w_frame//2
                --gfx.drawLine(w_frame//2, h_frame//2, x, y)
                --gfx.fillCircleAtPoint(x + w_frame, y, 4)
            gfx.popContext()
        end
        frame = frame:rotatedImage(self._orientation)

        --TODO which direction should be forward?? reconfigure all dials if needed
        -- frames are saved in backwards order to match CW forwards motion
        if self._motion == motions.cw then
            -- frames saved in backwards order
            i_frame = n_frames - j
        else
            i_frame = j + 1
        end
        imagetable:setImage(i_frame, frame)
    end
    self.imagetable = imagetable

    Spinner.super.bake(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return spinner