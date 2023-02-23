--- pkg 'uielement' provides an abstract class for interactive
--- UI sprites.
--- TODO may want to add justSelected and justDeselected to
---     improve efficiency and permit custom anims

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
---@param w integer (optional) initial width, defaults to screen width
---@param h integer (optional) initial height, defaults to screen height
function UIElement:init(name, w, h)
    if not w or w == 0 then
        w = configs.W_SCREEN
    end
    if not h or h == 0 then
        h = configs.H_SCREEN
    end
    UIElement.super.init(self)
    
    self.name = name

    self._img = gfx.image.new(w, h)
    self:setImage(self._img)

    --TODO config Z index using constant vals for a set of layers
    self:setZIndex(50)

    self._isConfigured = false
    local configWarningComplete = false
    --- Log, once, that the UIElement not had been configured.
    --- Can optionally call in update(). Or ignore completely. 
    self._checkConfig = function()
        if not self._isConfigured and not configWarningComplete then
            d.log("uielement " .. self.name .. " not configured")
            configWarningComplete = true
        end
    end

    self._parent = "nil" -- this backref should only be used in debugging
    self.children = {} -- list of UIElements this panel parents
    self.i_selectChild = 1 -- index of currently selected child

    --- Determines if this UIElement is selected, ie. "focused on".
    ---@return boolean true if the element's selection criteria are met
    self.isSelected = function ()
        d.log("uielement '" .. self.name .. "' select criteria not set")
        return false
    end
    
    --TODO do I actually need this?
    --- (optional) Additional action to execute when this UIElement is selected.
    --- Executes after other behaviours in the update loop.
    self.addSelectedAction = function ()
        return
    end

    self:setCenter(0, 0) --anchor top-left
end

---TODO desc
function UIElement:update()
    if self:isSelected() then
        self.addSelectedAction()
    end
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

--TODO could be modified to addChildren(...)
--- Parents another UIElement.
---@param element UIElement the child element
---@param keepGlobalPos boolean (option) keep the child's global position as is
---SPEC EFFECT  overrides child's ZIndex, so that it sets 1 above its new parent
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

    element._parent = self
    insert(self.children, element)
    if not keepGlobalPos then
        element:moveTo(self.x + element.x, self.y + element.y)
    end
    element:setZIndex(self:getZIndex() + 1)
end

--- Moves the UIElement and its children
---@param x integer x-position
---@param y integer y-position
---@param dontMoveChildren boolean (optional) false by default, set to true if children should be left in position
---@return integer,integer new coordinates (x1,y1) of the top-left corner
---@return integer,integer new coordinates (x2,y2) of the bottom-right corner
function UIElement:moveTo(x, y, dontMoveChildren)
    local x_o = self.x; local y_o = self.y
    UIElement.super.moveTo(self, x, y)

    if not dontMoveChildren and self.children then
        for _, child in ipairs(self.children) do
            -- globally reposition child, keeping local posn (ie. distance from parent's prev locn)
            child:moveTo(self.x + child.x - x_o, self.y + child.y - y_o)
        end
    end

    return x, y, x + self.width, y + self.height
end

--- Set the Z index for the UIElement and its children. 
--- By default, children will always sit 1 above the parent's Z index.
---@param z integer the value to set Z to
function UIElement:setZIndex(z)
    UIElement.super.setZIndex(self, z)
    if self.children then
        for _, child in ipairs(self.children) do
            child:setZIndex(z + 1)
        end
    end
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
uielement = utils.makeReadOnly(P)
return uielement