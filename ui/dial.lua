--- pkg 'dial' provides a dial UIElement that
--- visualizes a continuous value for the user to configure.

import 'ui/uielement'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
dial = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local configs <const> = configs
local d <const> = debugger
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

---TODO Dial desc
class('Dial').extends(UIElement)
local Dial <const> = Dial
local _ENV = P      -- enter pkg namespace
name = "dial"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new Dial instance.
---@param name string instance name for debugging
---@param unit string unit being enumerated, ex. "min"
---@param step integer step to inc/decrement the value on the dial by
function Dial:init(name, unit, step)
    Dial.super.init(self, name) --should always be at top of init func
    
    self._prevValue = 0
    self._img = gfx.image.new(200, 150)
    self:setImage(self._img)

    self.value = 0      -- value shown on dial 'face'
    self.step = step    -- step to inc/decrement value by
    self.unit = unit    -- unit being enumerated

    -- declare dial behaviour, to be configured elsewhere, prob by UI Manager
    self.isDialingForth = function ()
        d.log("dial '" .. self.name .. "' dialing-forth criteria not set")
        return false
    end
    self.isDialingBack = function ()
        d.log("dial '" .. self.name .. "' dialing-back criteria not set")
        return false
    end

    self:setCenter(0, 0) --anchor top-left
    self = utils.makeReadOnly(self, "Dial instance")
end

---TODO desc
function Dial:update()
    if self.isSelected() then
        if self.isDialingForth then
            self._prevValue = self.value
            self.value = self.value + self.step
        elseif self.isDialingBack then 
            self._prevValue = self.value
            self.value = self.value - self.step
        end
    -- only redraw if val has changed
        if self.value ~= self._prevValue then
            gfx.pushContext(self._img)
                gfx.clear()
                gfx.drawText("*".. self.value .. " " .. self.unit .."*", 2, 2)
            gfx.popContext()
        end  
    end

    Dial.super.update(self)
    --debugger.bounds(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
dial = utils.makeReadOnly(P)
return dial