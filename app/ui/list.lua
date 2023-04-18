--- pkg 'list' provides a list UIElement, which can list other UIElements within it,
---     and may enable the user to select between items in the list.

import 'ui/uielement'

local P = {}; local _G = _G
list = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local ipairs <const> = ipairs
local abs <const> = math.abs
local type <const> = type

local AXES <const> = configs.AXES
local UP <const> = pd.kButtonUp
local DOWN <const> = pd.kButtonDown
local LEFT <const> = pd.kButtonLeft
local RIGHT <const> = pd.kButtonRight

--- List is a UI element that arranges its children in a
--- sequence that can be navigated with directional buttons.
class('List').extends(UIElement)
local List <const> = List

-- local consts go here

local _ENV = P
name = "list"

--TODO instead of AXES enum, use list.orientations.horizontal and list.orientations.vertical enum, like the modes in dial
--      bug in current app is caused by the text not fitting in the list
--- Initializes a list UIElement.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
---@param axis enum (optional) member of AXES enum; determines list axis (X: hori, Y: vert). Defaults to vert.
---@param spacing integer (optional) number of pixels between UIElements (this list & its children)
function List:init(coreProps, axis, spacing)
    if not spacing or type(spacing) ~= 'number' then spacing = 0 end
    List.super.init(self, coreProps)

    self._spacing = spacing
    self._axis = axis
    self._lastChild = nil -- latest child added to list

    -- axis-based layouts
    -- could be split into axis-specific subclasses,
    --      but atm I don't want to spare the extra __index lookup
    if self._axis == AXES.X then
        self._inputPrev = LEFT
        self._inputNext = RIGHT

        --TODO refactor layout functions to use _lastChild
        --TODO  deduplicate layout funcs as much as possible
        --- Compute a new child's global position
        ---@return x,y the coordinate to place the next child at
        self._layout = function()
            local x = 0 ; local y = 0
            local nPrevChildren = #self._children - 1
            local prevChild = self._children[nPrevChildren]
            if nPrevChildren == 0 then
                x = self.x + spacing
            else
                x = prevChild.x + prevChild.width + spacing
            end
            y = self.y + spacing
            return x, y
        end
    else -- default to vertical layout
        self._axis = AXES.Y -- default vert orientation
        self._inputPrev = UP
        self._inputNext = DOWN

        --- Compute a new child's global position
        ---@return x,y the coordinate to place the next child at
        self._layout = function()
            local x = 0 ; local y = 0
            local nPrevChildren = #self._children - 1
            local prevChild = self._children[nPrevChildren]
            x = self.x + spacing
            if nPrevChildren == 0 then
                y = self.y + spacing
            else
                y = prevChild.y + prevChild.height + spacing
            end
            return x, y
        end
    end

    self._isConfigured = true
    self = utils.makeReadOnly(self, "list instance")
end

--- Updates the list sprite.
--- Cycles through its children on button-press.
--- Not all lists/list-children make use of this functionality.
--- Depends on what the children's isSelected criteria are configured to.
function List:update()
    if self.isSelected() then
        if pd.buttonJustPressed(self._inputPrev) then self:prev()
        elseif pd.buttonJustPressed(self._inputNext) then self:next() end
    end
    List.super.update(self)
    --d.illustrateBounds(self)
end

--- Parents another UIElement, .
--- No option to keep child's global posn,
---     since the list *must* control child layout.
---@param e table of child UIElements, or a single UIElement
function List:addChildren(e)
    local newChildren = List.super.addChildren(self, e)
    --d.log("adding child " .. e.name)
    
    for _, child in ipairs(newChildren) do
        child.isSelected = function ()
            return child == self._children[self._i_selectChild]
        end
        local x1, y1, x, y = child:moveTo(self._layout())
        self._lastChild = child

        if (x > self.x + self.width - self._spacing) or (y > self.y + self.height - self._spacing) then
            d.log("UIElement '" .. child.name .. "' out-of-bounds in layout. Illustrating bounds.")
            d.illustrateBounds(self)
            d.illustrateBounds(child)
        end
    end
end

--TODO this returns floats, want int pixels
--- Get the maximum dimensions of an element that would fit 
---     in this list without triggering the 'out-of-bounds'
---     debug warning.
--- Accounts for space occupied by elements presently in the list.
--- These dimensions are not enforced anywhere; using them is suggested, 
---     but voluntary.
---@param nNewElements integer (optional) the number of identically-sized new children to 'slice' for
---@return integer maximum width
---@return integer maximum height
function List:getMaxContentDim(nNewElements)
    if not nNewElements or nNewElements == 0 then
        nNewElements = 1
    end

    local axis = self._axis
    local spacing = self._spacing
    local lastChild = self._lastChild

    --- Return empty space remaining after accounting for existing children in the list
    ---@return integer remaining pixels
    local function spaceAfterChildren()

        local measure = nil
        if axis == AXES.X then
            measure = "width"
        elseif axis == AXES.Y then
            measure = "height"
        else
            d.log("can't position along '" .. axis .. "' dimension")
            return 0
        end

        local remaining = 0
        if lastChild then
            remaining = (self[axis] + self[measure]) - (lastChild[axis] + lastChild[measure])
        else
            remaining = self[measure]
        end
        return (remaining - spacing * (nNewElements + 1))
    end

    local available = spaceAfterChildren()
    local leftover = available % nNewElements
    if leftover ~= 0 then d.log(leftover .. " pix will be left over within " .. self.name .. " list") end

    local w = 0 ; local h = 0
    if self.axis == AXES.X then
        w = available // nNewElements
        h = self.height - 2 * spacing
    else
        w = self.width - 2 * spacing
        h = available // nNewElements
    end

    return w , h 
end

--- Selects the next child in the list.
function List:prev()
    self._i_selectChild = (self._i_selectChild - 2) % #self._children + 1
end

--- Selects the next child in the list.
function List:next()
    self._i_selectChild = self._i_selectChild % #self._children + 1
end

local _ENV = _G
list = utils.makeReadOnly(P)
return list