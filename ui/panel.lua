--- pkg 'panel' provides a panel UIElement that
--- triggers an action when selected and pressed.

import 'ui/uielement'

local P = {}; local _G = _G
panel = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local UIElement <const> = UIElement
local insert <const> = table.insert
local getn <const> = table.getn
local ipairs = ipairs

local UP <const> = pd.kButtonUp
local DOWN <const> = pd.kButtonDown

-- Panel is a UI element governing some behaviour if selected
-- A panel, when pressed, may modify global state indicators and animate itself.
-- The scope of what it knows should otherwise be limited.
class('Panel').extends(UIElement)
local Panel <const> = Panel

-- local consts go here

local _ENV = P
name = "panel"

--- Initializes a panel UIElement.
--- Call new() *instead of* instantiating directly with Panel().
---@param name string panel name for debugging
---@param x integer x-position relative to parent
---@param y integer y-position relative to parent
function Panel:init(name, x, y)
    -- TODO give each timer a name
    Panel.super.init(self, name, x, y)

    self.children = {} -- list of UIElements this panel parents
    self.i_selected = 1 -- index of currently selected child

    self = utils.makeReadOnly(self, "panel instance")
end

--- Updates the panel sprite.
function Panel:update()
    if self.isSelected() then
        if pd.buttonJustPressed(UP) then
            self.i_selected = (self.i_selected - 1) % getn(self)
        elseif pd.buttonJustPressed(DOWN) then
            self.i_selected = (self.i_selected + 1) % getn(self)
        end
    end
    Panel.super.update(self)
    --debugger.bounds(self)
end

function Panel:transitionIn()
    for _, child in ipairs(self.children) do
        child:transitionIn()
    end
    Panel.super.transitionIn(self)
end

function Panel:transitionOut()
    for _, child in ipairs(self.children) do
        child:transitionOut()
    end
    Panel.super.transitionIn(self)
end

function Panel:addChild(element)
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