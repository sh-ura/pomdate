--- pkg 'button' provides a button UIElement that
--- triggers an action when selected and pressed.

import 'ui/uielement'

local P = {}; local _G = _G
button = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger

-- Button is a UI element governing some behaviour if selected
-- A button, when pressed, may modify global state indicators and animate itself.
-- The scope of what it knows should otherwise be limited.
class('Button').extends(UIElement)
local Button <const> = Button

-- local consts go here

local _ENV = P
name = "button"

--- Initializes a button UIElement.
---@param name string button name for debugging
function Button:init(name)
    -- TODO give each timer a name
    Button.super.init(self, name)

    self.img = gfx.image.new(70, 40)
    self:setImage(self.img)
    gfx.lockFocus(self.img)
        gfx.drawRect(self:getBounds())
        gfx.drawText(name, 2, 2) -- TODO refactor
    gfx.unlockFocus()

    -- declare button behaviours, to be configured elsewhere
    self.isPressed = function ()
        d.log("button '" .. self.name .. "' press criteria not set")
        return false
    end
    self.action = function ()
        d.log("button '" .. self.name .. "' action not set")
    end

    self = utils.makeReadOnly(self, "button instance")
end

--- Updates the button UIElement.
function Button:update()
    if self.isSelected() then
        -- do selected visual
        if self.isPressed() then
            --d.log(self.name .. " is pressed")
            self.action()
        end 
    end
    Button.super.update(self)
    --debugger.bounds(self)
end

local _ENV = _G
button = utils.makeReadOnly(P)
return button