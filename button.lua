-- pkg 'timer' provides value-based timers, rendered as sprites
local P = {}; local _G = _G
button = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger

-- Button is a UI element governing some behaviour if selected
-- A button, when pressed, may modify global state indicators and animate itself.
-- The scope of what it knows should otherwise be limited.
class('Button').extends(gfx.sprite)
local Button <const> = Button

-- local consts go here

local _ENV = P
name = "button"

--- Initializes a button sprite.
--- Call new() *instead of* instantiating directly with Button().
---@param name string button name for debugging
---@param x integer x-position relative to parent
---@param y integer y-position relative to parent
function Button:init(name, x, y)
    -- TODO give each timer a name
    Button.super.init(self)

    self:setCenter(0, 0) --TODO rm if unnecessary
    self:moveTo(x, y)


    self.img = gfx.image.new(100, 50)
    self:setImage(self.img)
    gfx.lockFocus(self.img)
        gfx.drawRect(self:getBounds())
        gfx.drawText(name, 20, 20) -- TODO refactor
    gfx.unlockFocus()

    -- declare button behaviours
    self.action = function ()
        d.log("button '" .. name .. "' action not set")
    end
    self.isSelected = function ()
        d.log("button '" .. name .. "' select criteria not set")
        return false
    end
    self.isPressed = function ()
        d.log("button '" .. name .. "' press criteria not set")
        return false
    end

    self = utils.makeReadOnly(self, "button instance")
end

--- Updates the button sprite.
function Button:update()
    if self.isSelected() then
        -- do selected visual
        if self.isPressed() then
            self.action()
        end 
    end
    Button.super.update(self)
    --debugger.bounds(self)
end


--- Creates a button sprite.
---@param label string text to print on the button graphic
---@param x integer x-position
---@param y integer y-position
---@param callback function is called when the button is pressed.
---@return Button instance
function new(name, x, y)
    return Button(name, x, y)
end

local _ENV = _G
button = utils.makeReadOnly(P)
return button