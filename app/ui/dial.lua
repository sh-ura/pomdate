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
local d <const> = debugger
local COLOR_0 <const> = COLOR_0
local COLOR_1 <const> = COLOR_1
local COLOR_CLEAR <const> = COLOR_CLEAR

---TODO Dial desc
class('Dial').extends(UIElement)
local Dial <const> = Dial
local _ENV = P      -- enter pkg namespace
name = "dial"

visualizers = {
    numeral = 1,
    horiCounter = 2,
    vertCounter = 3,
    animation = 4
}

--- Initializes a new Dial instance.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
---@param lowerLimit integer (optional) cease dialing back past this value
---@param upperLimit integer (optional) cease dialing forward past this value
---@param step integer (optional) step to inc/decrement the value on the dial by. Defaults to 1
function Dial:init(coreProps, lowerLimit, upperLimit, step)
    if not step then step = 1 end
    Dial.super.init(self, coreProps) --should always be at top of init func

    self._spacing = 2
    self._step = step    -- step to inc/decrement value by
    self._lowLimit = nil
    self._uppLimit = nil
    self._prevValue = nil

    -- set the initial value. use limits if provided, else set to 0.
    if lowerLimit and upperLimit then
        self._lowLimit = lowerLimit
        self._uppLimit = upperLimit
        self.value = (lowerLimit + upperLimit) // 2
    elseif lowerLimit then
        self._lowLimit = lowerLimit
        self.value = lowerLimit
    elseif upperLimit then
        self._uppLimit = upperLimit
        self.value = upperLimit
    end
    if not self.value then self:setValue(0) end

    self._unit = nil
    self._counter = gfx.image.new(20, 20, COLOR_CLEAR)
    gfx.pushContext(self._counter)
        gfx.setColor(COLOR_1)
        gfx.fillCircleAtPoint(9, 9, 9)
    gfx.popContext(self._counter)

    --- Declare dial behaviour, to be configured elsewhere, prob by UI Manager
    ---@return integer amount to dial. pos for forward, neg for backward, 0 for no change
    self.getDialChange = function ()
        d.log("dial '" .. self.name .. "' dial-change measures not configured")
        return 0
    end
    
    --- Mode for visualizing value defaults to numeral.
    self:setMode(visualizers.numeral)

    self._isConfigured = true
    self = utils.makeReadOnly(self, "Dial instance")
end

---TODO desc
function Dial:update()
    if not Dial.super.update(self) then return end
    
    local val = self.value
    -- only redraw if val has changed
    if val ~= self._prevValue then self._renderValue() end

    if self.isSelected() then
        local low = self._lowLimit
        local upp = self._uppLimit

        self._prevValue = val
        self.value = val + self.getDialChange() * self._step
        if low and self.value <= low then
            self.value = low
        elseif upp and self.value >= upp then
            self.value = upp
        end
    end
    --d.illustrateBounds(self)
end

--- Set the visualizer to use.
---@param mode enum one of the dial.visualizers options
function Dial:setMode(mode)
    local w, h = self:getSize()
    if mode == visualizers.horiCounter then
        self._renderValue = function()
            local counter = self._counter
            local w_counter, _ = counter:getSize() --TODO can call width?
            local spacing = self._spacing
            local x = 0
            gfx.pushContext(self._fg_anim)
                gfx.clear(COLOR_CLEAR)
                for i = 0, self.value - 1 do
                    counter:draw(x, 0)
                    x = x + w_counter + spacing
                end
            gfx.popContext()
        end
    elseif mode == visualizers.vertCounter then
        self._renderValue = function()
            local counter = self._counter
            local _, h_counter = counter:getSize()
            local spacing = self._spacing
            local y = 0
            gfx.pushContext(self._fg_anim)
                gfx.clear(COLOR_CLEAR)
                for i = 0, self.value - 1 do
                    counter:draw(0, y)
                    y = y + h_counter + spacing
                end
            gfx.popContext()
        end
    elseif mode == visualizers.numeral then --TODO refactor to use self._text instead
        self._renderValue = function ()
            local text = "" .. self.value
            if self._unit then text = text .. " " .. self._unit 
                if self.value ~= 1 then text = text .. "s" end
            end
            self._text = text
            self:redraw()
        end
    elseif mode == visualizers.animation then
        self._renderValue = function ()
            
            -- TODO set self.value or prevVal to ensure that img is redrawn
        end
    end
end

--- Set the unit on the dial,
---     visualized when in numeral mode.
---@param unit string unit being enumerated, singular, ex. "min"
function Dial:setUnit(unit)
    self._unit = unit
end

--- Set the counter to represent each incrementing step,
---     visualized when in counter mode.
---@param img playdate.graphics.image image to use as counter.
---@param spacing integer (optional) number of pixels between each counter.
---         Defaults to 2.
function Dial:setCounter(img, spacing)
    self._counter = img
    if spacing then self._spacing = spacing end
end

--- Set the value on the dial.
---@param value integer
function Dial:setValue(value)
    local low = self._lowLimit
    local upp = self._uppLimit
    if low and value < low then
        self.value = low
    elseif upp and value > upp then
        self.value = upp
    else
        self.value = value
    end
    --d.log(self.name .. " duration set to " .. value)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
dial = utils.makeReadOnly(P)
return dial