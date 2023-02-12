--- pkg 'uielement' provides an abstract class for interactive
--- UI sprites.

-- pkg header: define pkg namespace
local P = {}; local _G = _G
uielement = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local configs <const> = configs
local d <const> = debugger
local ipairs <const> = ipairs
local insert <const> = table.insert

--- UIElement is an interactive sprite that can parent other UIElements.
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
---@param x integer x-position
---@param y integer y-position
function UIElement:init(name, x, y)
    self.children = {} -- list of UIElements this panel parents
    self.i_selected = 1 -- index of currently selected child

    self:setCenter(0, 0)
    self:moveTo(x, y)

    self.name = name
    self.isSelected = function ()
        d.log("uielement '" .. self.name .. "' select criteria not set")
        return false
    end

    UIElement.super.init(self)
    self = utils.makeReadOnly(self, "UIElement instance '" .. self.name .. "'")
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
    for _, child in ipairs(self.children) do
        child:transitionIn()
    end
    self:add()
end

--- Transitions the element out of visibility.
--- Likely to be overridden by extending class
function UIElement:transitionOut()
    --d.log("uielement '" .. self.name .. "' transition-out anim not set")
    for _, child in ipairs(self.children) do
        child:transitionOut()
    end
    self:remove()
end

--- Parents another UIElement.
---@param element UIElement the child element
---@param keepGlobalPos boolean (option) keep the child's global positios as is
function UIElement:addChild(element, keepGlobalPos)
    if not element:isa(UIElement) then
        local name = ""
        if element.name then name = element.name
        else name = "no_name" end
        d.log("element " .. name .. " is not a UIElement; can't be child to " .. self.name)
        return
    end

    insert(self.children, element)
    element.isSelected = function ()
        return element == self.children[self.i_selected]
    end
    if not keepGlobalPos then
        element:moveTo(self.x + element.x, self.y + element.y)
    end
end

--- Moves the UIElement and its children
---@param x integer x-position
---@param y integer y-position
function UIElement:moveTo(x, y)
    for _, child in ipairs(self.children) do
        -- globally reposition child, keeping local posn (ie. distance from parent)
        child:moveTo(x + child.x - self.x, y + child.y - self.y)
    end
    UIElement.super.moveTo(self, x, y)
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