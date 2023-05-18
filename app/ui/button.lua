--- pkg 'button' provides a button UIElement that
--- triggers an action when selected and pressed.

import 'ui/uielement'

local P = {}; local _G = _G
button = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local newVector <const> = utils.newVector
local centered = kTextAlignment.center
local COLOR_0 <const> = COLOR_0
local COLOR_1 <const> = COLOR_1
local COLOR_CLEAR <const> = COLOR_CLEAR

---@class Button is a UI element governing some behaviour if selected.
--- A button, when pressed, may modify global state indicators and animate itself.
--- The scope of what it knows should otherwise be limited.
class('Button').extends(UIElement)
local Button <const> = Button

-- local consts go here

local _ENV = P
name = "button"

--- Initializes a button UIElement.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
---@param invisible boolean whether to make the button invisible. Defaults to false, ie. visible
function Button:init(coreProps, invisible)
    -- TODO give each timer a name
    Button.super.init(self, coreProps)

    self._isVisible = true
    if invisible then
        self._isVisible = false
        self._img = gfx.image.new(1, 1, COLOR_CLEAR)
        self:setImage(self._img)
    end

    -- declare button behaviours, to be configured elsewhere, prob by UI Manager
    self.isPressed = function ()
        if not self._isConfigured then d.log("button '" .. self.name .. "' press criteria not set") end
        return false
    end
    self.pressedAction = function ()
        if not self._isConfigured then d.log("button '" .. self.name .. "' pressedAction not set") end
    end
    self._posn.offsets.pressed = newVector(0,0)

    --- Prepare the text, to later be drawn onto the element with redraw().
    self.renderText = function()
        if not self._text then d.log("no text to render on " .. self.name) return end
        local w, h = self:getSize()
        if not self._fg_text then
            self._fg_text = gfx.image.new(w, h, COLOR_CLEAR)
        end
        
        gfx.pushContext(self._fg_text)
            gfx.setColor(COLOR_CLEAR)
            gfx.fillRect(0, 0, w, h) --TODO would be nice to call gfx.clear() instead
            gfx.setFont(self._font)
            gfx.drawTextAligned(self._text, w/2, (h - self._font:getHeight())/2, centered)
        gfx.popContext()
    end

    if self._isVisible then
        self._text = self.name
    end
    self._isConfigured = true
    self = utils.makeReadOnly(self, "button instance")
end

--- Updates the button UIElement.
function Button:update()
    if not Button.super.update(self) then return end
    
    if self.isSelected() then
        if self._isVisible then
            self:setImage(self._img:invertedImage()) --invert img when button is selected
        end
        if self.isPressed() then
            --d.log(self.name .. " is pressed")
            self:reposition(self._posn.default + self._posn.offsets.pressed)
            self._posn.animator.reverses = true
            self._posn.arrivalCallback = self.pressedAction
        end 
    else
        self:setImage(self._img) --revert img when button is not selected
    end
    d.illustrateBounds(self)
end

--- Set the label to show on the button
---@param label string
function Button:setLabel(label)
    self._text = label
    self:redraw()
end

local _ENV = _G
button = utils.makeReadOnly(P)
return button