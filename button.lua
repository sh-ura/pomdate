-- pkg 'timer' provides value-based timers, rendered as sprites
local P = {}; local _G = _G
button = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local debugger <const> = debugger

-- Button is a UI element governing some behaviour if selected
class('Button').extends(gfx.sprite)
local Button <const> = Button

-- local consts go here

local _ENV = P
name = "button"

-- Initializes a button sprite.
--- Call new() *instead of* instantiating directly with Button().
---@param label string text to print on the button graphic
---@param x integer x-position
---@param y integer y-position
---@param callback function is called when the button is pressed.
function Button:init(label, x, y, callback)
    -- TODO give each timer a name
    Button.super.init(self)

    self:setCenter(0, 0)
    self:moveTo(x, y)

    self.callback = callback
    self.img = gfx.image.new(100, 50)
    self:setImage(self.img)
    gfx.lockFocus(self.img)
        gfx.drawRect(self:getBounds())
        gfx.drawText(label, 20, 20)
    gfx.unlockFocus()

    self = utils.makeReadOnly(self, "button instance")
end

--- Updates the button sprite.
function Button:update()
    Button.super.update(self)
    --debugger.bounds(self)
end

--- Triggers the button's callback.
function Button:press()
    self.callback()
end

--- Creates a button sprite.
---@param label string text to print on the button graphic
---@param x integer x-position
---@param y integer y-position
---@param callback function is called when the button is pressed.
---@return Button instance
function new(label, x, y, callback)
    return Button(label, x, y, callback)
end

local _ENV = _G
button = utils.makeReadOnly(P)
return button