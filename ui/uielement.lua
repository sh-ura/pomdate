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
---@param name string button name for debugging
function UIElement:init(name)
    UIElement.super.init(self)
    self.name = name

    self.children = {} -- list of UIElements this panel parents
    self.i_selectChild = 1 -- index of currently selected child

    self.isSelected = function ()
        d.log("uielement '" .. self.name .. "' select criteria not set")
        return false
    end

    self:setCenter(0, 0) --anchor top-left
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
    --TODO move this check into children metatable.__newindex
    --so that other class implementations can override this func safely
    if not element:isa(UIElement) then
        local name = ""
        if element.name then name = element.name
        else name = "no_name" end
        d.log("element " .. name .. " is not a UIElement; can't be child to " .. self.name)
        return
    end

    insert(self.children, element)
    if not keepGlobalPos then
        element:moveTo(self.x + element.x, self.y + element.y)
    end
end

--- Moves the UIElement and its children
---@param x integer x-position
---@param y integer y-position
---@return integer,integer new coordinates (x1,y1) of the top-left corner
---@return integer,integer new coordinates (x2,y2) of the bottom-left corner
function UIElement:moveTo(x, y)
    local x_o = self.x; local y_o = self.y
    UIElement.super.moveTo(self, x, y)

    if not self.children then return end -- needed for gfx.sprite.init()
    for _, child in ipairs(self.children) do
        -- globally reposition child, keeping local posn (ie. distance from parent's prev locn)
        child:moveTo(self.x + child.x - x_o, self.y + child.y - y_o)
    end

    return x, y, x + self.width, y + self.height
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
uielement = utils.makeReadOnly(P)
return uielement