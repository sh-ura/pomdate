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

--TODO this may not be needed, due to parent
--- Initializes a panel UIElement.
---@param name string panel name for debugging
---@param spacing integer number of pixels between UIElements (this panel & its children)
---@param horizontal (option) lay the panel's children out
---    next to each other in the x dimension.
---    Defaults to vertical layout.
function Panel:init(name, spacing, horizontal)
    Panel.super.init(self, name)
    self.img = gfx.image.new(100, 200)
    self:setImage(self.img)

    -- orientation-based layouts
    -- could be split into orientation-specific subclasses,
    --      but atm I don't want to spare the extra __index lookup
    if horizontal then
        self.prevButton = LEFT
        self.nextButton = RIGHT

        --- Compute a new child's global position
        ---@return x,y the coordinate to place the next child at
        self.layout = function()
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
        self.prevButton = UP
        self.nextButton = DOWN

        --- Compute a new child's global position
        ---@return x,y the coordinate to place the next child at
        self.layout = function()
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

    self = utils.makeReadOnly(self, "panel instance")
end

--- Updates the panel sprite.
--- Cycles through its children on button-press.
--- Not all panels/panel-children make use of this functionality.
--- Depends on what the children's isSelected criteria are configured to.
function Panel:update()
    if self.isSelected() then
        if pd.buttonJustPressed(self.prevButton) then
            self.i_selectChild = (self.i_selectChild - 2) % #self.children + 1
            d.log(self.name .. " prev button pressed. i: " .. self.i_selectChild)
        elseif pd.buttonJustPressed(self.nextButton) then
            self.i_selectChild = self.i_selectChild % #self.children + 1
            d.log(self.name .. " next button pressed. i: " .. self.i_selectChild)
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
    d.log("adding child " .. element.name)

    element.isSelected = function ()
        return element == self.children[self.i_selectChild]
    end
    _, _, x, y = element:moveTo(self.layout())
    if (x >= self.x + self.width) or (y >= self.y + self.height) then
        d.log("UIElement '" .. element.name .. "' out-of-bounds in layout. Illustrating bounds.")
        d.illustrateBounds(self)
        d.illustrateBounds(element)
    end
end

local _ENV = _G
panel = utils.makeReadOnly(P)
return panel