--- pkg 'panel' provides a panel UIElement.
--TODO rename panel to "list"?

import 'ui/uielement'

local P = {}; local _G = _G
panel = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local UIElement <const> = UIElement
local abs = math.abs

local UP <const> = pd.kButtonUp
local DOWN <const> = pd.kButtonDown
local LEFT <const> = pd.kButtonLeft
local RIGHT <const> = pd.kButtonRight

--- Panel is a UI element that arranges its children in a
--- sequence that can be navigated with directional buttons.
class('Panel').extends(UIElement)
local Panel <const> = Panel

-- local consts go here

local _ENV = P
name = "panel"

--TODO NEED TO SET DIMENSIONS.
--      bug in current app is caused by the text not fitting in the panel
--- Initializes a panel UIElement.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
---@param spacing integer (optional) number of pixels between UIElements (this panel & its children)
---@param horizontal boolean (optional) lay the panel's children out
---    next to each other in the x dimension.
---    Defaults to vertical layout.
function Panel:init(coreProps, spacing, horizontal)
    if not spacing then spacing = 0 end
    Panel.super.init(self, coreProps)

    self._spacing = spacing
    self._isHorizontal = false
    self._lastChild = nil -- latest child added to panel
    self:setZIndex(10)

    -- orientation-based layouts
    -- could be split into orientation-specific subclasses,
    --      but atm I don't want to spare the extra __index lookup
    if horizontal then
        self._isHorizontal = true
        self._inputPrev = LEFT
        self._inputNext = RIGHT

        --TODO refactor layout functions to use _lastChild
        --- Compute a new child's global position
        ---@return x,y the coordinate to place the next child at
        self._layout = function()
            local x = 0 ; local y = 0
            local nPrevChildren = #self.children - 1
            local prevChild = self.children[nPrevChildren]
            if nPrevChildren == 0 then
                x = self.x + spacing
            else
                x = prevChild.x + prevChild.width + spacing
            end
            y = self.y + spacing
            return x, y
        end
    else
        self._inputPrev = UP
        self._inputNext = DOWN

        --- Compute a new child's global position
        ---@return x,y the coordinate to place the next child at
        self._layout = function()
            local x = 0 ; local y = 0
            local nPrevChildren = #self.children - 1
            local prevChild = self.children[nPrevChildren]
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
    self = utils.makeReadOnly(self, "panel instance")
end

--- Updates the panel sprite.
--- Cycles through its children on button-press.
--- Not all panels/panel-children make use of this functionality.
--- Depends on what the children's isSelected criteria are configured to.
function Panel:update()
    if self.isSelected() then
        if pd.buttonJustPressed(self._inputPrev) then
            self.i_selectChild = (self.i_selectChild - 2) % #self.children + 1
            --d.log(self.name .. " prev button pressed. i: " .. self.i_selectChild)
        elseif pd.buttonJustPressed(self._inputNext) then
            self.i_selectChild = self.i_selectChild % #self.children + 1
            --d.log(self.name .. " next button pressed. i: " .. self.i_selectChild)
        end
    end
    Panel.super.update(self)
    --d.illustrateBounds(self)
end

--- Parents another UIElement, .
--- No option to keep child's global posn,
---     since the panel *must* control child layout.
---@param element UIElement the child element
function Panel:addChild(element)
    Panel.super.addChild(self, element)
    --d.log("adding child " .. element.name)

    element.isSelected = function ()
        return element == self.children[self.i_selectChild]
    end
    local x1, y1, x, y = element:moveTo(self._layout())
    d.log("x " .. x1 .. " y " .. y1)
    self._lastChild = element

    if (x > self.x + self.width - self._spacing) or (y > self.y + self.height - self._spacing) then
        d.log("UIElement '" .. element.name .. "' out-of-bounds in layout. Illustrating bounds.")
        d.illustrateBounds(self)
        d.illustrateBounds(element)
    end
end

--TODO this returns floats, want int pixels
--- Get the maximum dimensions of an element that would fit 
---     in this panel without triggering the 'out-of-bounds'
---     debug warning.
--- Accounts for space occupied by elements presently in the panel.
--- These dimensions are not enforced anywhere; using them is suggested, 
---     but voluntary.
---@param nNewElements integer (optional) the number of identically-sized new children to 'slice' for
---@return integer maximum width
---@return integer maximum height
function Panel:getMaxContentDim(nNewElements)
    if not nNewElements or nNewElements == 0 then
        nNewElements = 1
    end

    local spacing = self._spacing
    local lastChild = self._lastChild

    --- Return empty space remaining after accounting for existing children in the panel
    ---@param dim string target dimension, ie. 'x' or 'y'
    ---@return integer remaining pixels
    local function spaceAfterChildren(dim)
        local measure = nil
        if dim == 'x' then
            measure = "width"
        elseif dim == 'y' then
            measure = "height"
        else
            d.log("can't position along '" .. dim .. "' dimension")
            return 0
        end

        local available = 0
        if lastChild then
            available = (self[dim] + self[measure]) - (lastChild[dim] + lastChild[measure])
        else
            available = self[measure]
        end
        return (available - spacing * (nNewElements + 1))
    end

    local w = 0 ; local h = 0
    if self._isHorizontal then
        w = spaceAfterChildren('x') // nNewElements
        h = self.height - 2 * spacing
    else
        w = self.width - 2 * spacing
        h = spaceAfterChildren('y') // nNewElements
    end

    return w , h 
end

local _ENV = _G
panel = utils.makeReadOnly(P)
return panel