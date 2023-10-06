---pkg Reel can render a cassette reel animation.
-- pkg header: define pkg namespace
reel = {}
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

---TODO Reel desc
class('Reel').extends(Render)
local Reel <const> = Reel
local _ENV = reel      -- enter pkg namespace
name = "reel"

motions = {
    cw = 1,
    ccw = -1
}

--- Creates a reel render
---@param motion enum, one of spinner.motions
function Reel:init(name, motion, diameter, lineWidth)
    if not motion then
        d.log("Reel " .. name .. " motion dir not valid. Defaulting to cw")
        motion = motions.cw
    end
    self._motion = motion

    if not diameter then diameter = 3 * 15 end
    self._diameter = diameter

    if not lineWidth then lineWidth = 4 end
    self._lineWidth = lineWidth

    Reel.super.init(self, name)
end

--- (Re)bakes the reel animation
function Reel:bake()
    local n_frames = 20
    local n_spokes = 6
    local diameter_out = self._diameter
    local dim_frame = diameter_out + 2

    local center = dim_frame / 2
    local lineWidth = self._lineWidth
    local radPerSpoke = 2 * pi / n_spokes
    local radPerFrame = radPerSpoke / n_frames

    local imagetable = gfx.imagetable.new(n_frames)
    local theta     local x     local y      local i_frame
    for j = 0, n_frames - 1 do
        local frame = gfx.image.new(dim_frame, dim_frame)
        gfx.pushContext(frame)
            gfx.setColor(COLOR.pos)
            gfx.fillCircleAtPoint(center, center, diameter_out / 2)
            gfx.setColor(COLOR.clear)
            gfx.fillCircleAtPoint(center, center, (diameter_out - lineWidth*2) / 2)
            gfx.setColor(COLOR.pos)
        
            for k = 0, (n_spokes - 1)/2 do
                theta = k*radPerSpoke + j*radPerFrame
                x = (diameter_out - lineWidth)/2 * cos(theta)
                y = (diameter_out - lineWidth)/2 * sin(theta)
                gfx.setLineWidth(lineWidth)
                gfx.drawLine(center - x, center - y, center + x, center + y)
            end

            gfx.setColor(COLOR.clear)
            gfx.fillCircleAtPoint(center, center, (diameter_out - lineWidth * 4) / 2)
            gfx.setColor(COLOR.pos)
        gfx.popContext()

        if self._motion == motions.cw then
            -- frames saved in backwards order
            i_frame = j + 1
        else
            i_frame = n_frames - j
        end
        imagetable:setImage(i_frame, frame)
    end

    self.imagetable = imagetable

    Reel.super.bake(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return reel