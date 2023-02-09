---TODO pkg 'uielement' DESC

-- pkg header: define pkg namespace
local P = {}; local _G = _G
uielement = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local configs <const> = configs
local d <const> = debugger
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

---TODO UIElement desc
class('UIElement').extends(gfx.sprite)
local UIElement <const> = UIElement
local _ENV = P      -- enter pkg namespace
name = "uielement"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new uielement sprite.
--- Call new() *instead of* instantiating directly with UIElement().
---@param name string button name for debugging
---@param x integer x-position relative to parent
---@param y integer y-position relative to parent
function UIElement:init(name, x, y)
    UIElement.super.init(self)

    self:setCenter(0, 0)
    self:moveTo(x, y)

    self.name = name
    self.isSelected = function ()
        d.log("uielement '" .. self.name .. "' select criteria not set")
        return false
    end

    self = utils.makeReadOnly(self, "UIElement instance")
end

---TODO desc
function UIElement:update()
    UIElement.super.update(self)
    --debugger.bounds(self)
end

--- Transitions the element into visibility/x-position.
--- Likely to be overridden by extending class
function UIElement:transitionIn()
    --d.log("uielement '" .. self.name .. "' transition-in anim not set")
    self:add()
end

--- Transitions the element out of visibility.
--- Likely to be overridden by extending class
function UIElement:transitionOut()
    --d.log("uielement '" .. self.name .. "' transition-out anim not set")
    self:remove()
end

--- Initializes and returns new UIElement instance.
--- Call new() *instead of* instantiating directly with UIElement().
---@param x integer: global x-position
---@param y integer: global y-position
---@return UIElement instance
function new(x, y)
    return UIElement()
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
uielement = utils.makeReadOnly(P)
return uielement