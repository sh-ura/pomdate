-- timer provides value-based timers, rendered as sprites
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

-- Button:init(label, xpos, ypos, callback) initializes a button sprite.
--      callback is called when the button is pressed.
-- Use button.new instead pls.
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

-- Button:update() updates the button sprite
function Button:update()
    Button.super.update(self)
    --debugger.bounds(self)
end

function Button:press()
    self.callback()
end

-- new(label, xpos, ypos, callback) initializes a button sprite.
--      callback is called when the button is pressed.
function new(label, x, y, callback)
    return Button(label, x, y, callback)
end

local _ENV = _G
button = utils.makeReadOnly(P)
return button