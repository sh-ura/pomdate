--- pkg 'uielement' provides an abstract class for interactive
--- UI sprites.
--- TODO may want to add justSelected and justDeselected to
---     improve efficiency and permit custom anims

import 'ui/switch'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
uielement = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local Switch <const> = Switch
local type <const> = type
local pairs <const> = pairs
local ipairs <const> = ipairs
local insert <const> = table.insert

local W_SCREEN <const> = W_SCREEN
local H_SCREEN <const> = H_SCREEN

--- UIElement is an interactive sprite that can parent other UIElements.
--- It can be an abstract class for more specialized UI components, or
---     be the template for simple UIElement objects such as groups/"folders".
class('UIElement').extends(gfx.sprite)
local UIElement <const> = UIElement
local _ENV = P      -- enter pkg namespace
name = "uielement"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new UIElement sprite.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
function UIElement:init(coreProps)
    UIElement.super.init(self)

    -- unpack coreProps
    local name, w, h
    if coreProps then
        if coreProps.name then name = coreProps.name
        elseif coreProps[1] then name = coreProps[1] end

        if coreProps.w then w = coreProps.w
        elseif coreProps[2] then w = coreProps[2] end

        if coreProps.h then h = coreProps.h
        elseif coreProps[3] then h = coreProps[3] end
    end
    if not name or name == "" or type(name) ~= 'string'  then
        name = "unnamed-UIElement"
    end
    if not w or w == 0 or type(w) ~= 'number' then
        w = W_SCREEN
    end
    if not h or h == 0 or type(h) ~= 'number' then
        h = H_SCREEN
    end
    w = w // 1 -- ensure int
    h = h // 1
    
    self.name = name
    self._img = gfx.image.new(w, h)
    self:setImage(self._img)

    --TODO _isConfigured should be a table of checks since many things need configuring
    self._isConfigured = false
    local configWarningComplete = false
    --- Log, once, that the UIElement not had been configured.
    --- Can optionally call in update(). Or ignore completely. 
    self._checkConfig = function()
        if not self._isConfigured and not configWarningComplete then
            d.log("uielement '" .. self.name .. "'' not configured")
            configWarningComplete = true
        end
    end

    self._parent = "nil" -- this backref should only be used in debugging
    self._children = {} -- list of UIElements this panel parents
    self._i_selectChild = 1 -- index of currently selected child

    --- Determines if this UIElement is selected, ie. "focused on".
    ---@return boolean true if the element's selection criteria are met
    self.isSelected = function ()
        if not self._isConfigured then d.log("uielement '" .. self.name .. "' select criteria not set") end
        return true
    end

    --- Enables/disables this UIElement.
    --- If setEnablingCriteria() is not called on this element, it will remain disabled by default.
    self._switch = Switch(self)
    self._switch.shouldClose = function ()
        if not self._isConfigured then d.log("uielement '" .. self.name .. "' disabled! Set enabling conditions.") end
        return false
    end
    self._switch:add()

    self:setCenter(0, 0) --anchor top-left
end

---TODO desc
function UIElement:update()
    UIElement.super.update(self)
    --debugger.bounds(self)
end

--- Transitions the element into visibility/position.
function UIElement:transitionIn()
    --if not self._isConfigured then d.log("uielement '" .. self.name .. "' transition-in anim not set") end
    for _, child in ipairs(self._children) do
        -- add special additional child tranforms here
    end
    self:add()
end

--- Transitions the element out of visibility.
function UIElement:transitionOut()
    --if not self._isConfigured then d.log("uielement '" .. self.name .. "' transition-out anim not set") end
    for _, child in ipairs(self._children) do
        -- add special additional child tranforms here
    end
    self:remove()
end

--- Parents another UIElement.
---@param e table of child UIElements, or a single UIElement
---@param keepGlobalPos boolean (option) keep the children's global position as is
---@return table of successfully added child UIElements
---SPEC EFFECT  overrides each child's ZIndex to be relative to parent above its new parent
function UIElement:addChildren(e, keepGlobalPos)
    --TODO want to check e:isa(UIElement) but isa seems to be unstable in 1.12.3?
    if not (e and type(e) == 'table') then
        d.log("no children to add to " .. self.name)
        return
    end

    local newChildren = {}
    local function addChild(element)
        if not element:isa(UIElement) then
            local name = element.name 
            if not name then name = 'no_name' end
            d.log("element " .. name .. " is not a UIElement; can't be child to " .. self.name)
            return
        end

        element._parent = self
        insert(self._children, element)
        insert(newChildren, element)
        if not keepGlobalPos then
            element:moveTo(self.x + element.x, self.y + element.y)
        end
        element:setZIndex(element:getZIndex() + self:getZIndex())    
    end

    if e.isa then addChild(e)
    else
        for _, element in ipairs(e) do
            addChild(element)
        end
        for _, element in pairs(e) do
            addChild(element)
        end
    end
    return newChildren
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

    if not dontMoveChildren and self._children then
        for _, child in ipairs(self._children) do
            -- globally reposition child, keeping local posn (ie. distance from parent's prev locn)
            child:moveTo(self.x + child.x - x_o, self.y + child.y - y_o)
        end
    end

    return x, y, x + self.width, y + self.height
end

--- Set the Z index for the UIElement.
--- Its children will also be re-indexed,
---     but they will retain their zIndex *relative to* this parent element
---     and one another.
---@param z integer the value to set Z to
function UIElement:setZIndex(z)
    UIElement.super.setZIndex(self, z)
    if self._children then
        for _, child in ipairs(self._children) do
            child:setZIndex(child:getZIndex() + z)
        end
    end
end

--- Forcefully flag the UIElement as having been configured, supressing related warnings.
function UIElement:forceConfigured()
    self._isConfigured = true
end

--- Set the conditions under which this UIElement should be visible and enabled
---@param conditions function that returns a boolean if the conditions have been met
function UIElement:setEnablingCriteria(conditions)
    if type(conditions) ~= 'function' then
        d.log(self.name .. "-enabling conditions must be func", conditions)
        return
    end

    -- existing switch will be garbage-collected
    if self._switch then self._switch:remove() end
    self._switch = Switch(self)
    self._switch.shouldClose = conditions
    self._switch:add()
end

function UIElement:isEnabled()
    --if self._switch.isClosed then d.log(self.name .. " is enabled.") end
    return self._switch.isClosed
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
uielement = utils.makeReadOnly(P)
return uielement