---pkg BackIcon renders an icon of the back/restart button on a CD player. NOT IN USE.
--TODO rm this file
-- pkg header: define pkg namespace
backicon = {}
local _G = _G

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local Render <const> = Render
local COLOR = GFX.COLOR
local pathPrefix = GFX.GEN.pathPrefix

--- BackIcon renders an icon akin to that on the back/restart button on a CD player.
class('BackIcon').extends(Render)
local BackIcon <const> = BackIcon
local _ENV = backicon      -- enter pkg namespace
name = "backicon"

--- Creates a render of a backicon.
---@param name string
---@param width number
---@param height number
---@param color enum one of gfx.kColor
function BackIcon:init(name, width, height, color)
    if not (width and height) then
        d.log("defaulting dimensions for " .. name .. " icon")
        width = 20
        height = 20
    end
    self._width = width
    self._height = height

    if not color then
        d.log("defaulting color for " .. name .. " icon")
        color = COLOR.pos
    end
    self._color = color

    BackIcon.super.init(self, name)
end

--- (Re)bakes the back icon
function BackIcon:bake()
    local w = self._width
    local h = self._height

    local img = gfx.image.new(w, h)
    gfx.pushContext(img)
        gfx.setColor(self._color)
        local r = w//4
        gfx.setLineWidth(r)
        gfx.setLineCapStyle(gfx.kLineCapStyleRound)
        gfx.drawLine(r//2, 0, r//2, h)
        gfx.fillTriangle(w//4, h//2, w, 0, w, h)
    gfx.popContext()

    local imagetable = gfx.imagetable.new(1)
    imagetable:setImage(1, img)
    self.imagetable = imagetable

    BackIcon.super.bake(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return backicon