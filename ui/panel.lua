--- pkg 'panel' provides a panel UIElement.

import 'ui/uielement'

local P = {}; local _G = _G
panel = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local UIElement <const> = UIElement
local getn <const> = table.getn

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
--- Call new() *instead of* instantiating directly with Panel().
---@param name string panel name for debugging
---@param x integer x-position
---@param y integer y-position
---@param horizontal (option) lay the panel's children out
---    next to each other in the x dimension.
---    Defaults to vertical layout.
function Panel:init(name, x, y, horizontal)
    -- selection buttons depend on layout
    if horizontal then
        Panel.prev = LEFT
        Panel.next = RIGHT
    else
        Panel.prev = UP
        Panel.next = DOWN
    end

    Panel.super.init(self, name, x, y)
    self = utils.makeReadOnly(self, "panel instance")
end

--- Updates the panel sprite.
function Panel:update()
    if self.isSelected() then
        if pd.buttonJustPressed(self.prev) then
            self.i_selected = (self.i_selected - 1) % getn(self)
        elseif pd.buttonJustPressed(self.next) then
            self.i_selected = (self.i_selected + 1) % getn(self)
        end
    end
    Panel.super.update(self)
    --debugger.bounds(self)
end

--- Creates a panel UIElement.
---@param label string text to print on the panel graphic
---@param x integer x-position
---@param y integer y-position
---@param callback function is called when the panel is pressed.
---@return Panel instance
function new(name, x, y)
    return Panel(name, x, y)
end

local _ENV = _G
panel = utils.makeReadOnly(P)
return panel