---pkg 'switch' provides a Switch UI component, which can decorate a UIElement to
---     to turn it on and off according to some criteria.

import 'ui/uielement'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
switch = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local insert <const> = table.insert
local Object <const> = Object
local pairs <const> = pairs
local UIElement <const> = UIElement

--- Switches can turn the UIElement they attach to on and off.
--- They enable UIElement behaviour that gfx.sprite:remove() otherwise
---     inhibits: making a UIElement disappear and reappear under specific conditions,
---     *independently* of the UIManager or other UIElement parents.
class('Switch').extends(Object)
local Switch <const> = Switch
local _ENV = P      -- enter pkg namespace
name = "switch"

local activeSwitches = {}

--- For all active switches,
---     turns the attached UIElement on or off
---     by adding/removing it from the global sprite list.
function update()
    for _, switch in pairs(activeSwitches) do
        if not switch.isClosed and switch.shouldClose() then
            --d.log("closing switch " .. switch.name)
            switch._attachedTo:transitionIn()
            switch.isClosed = true
        elseif switch.isClosed and not switch.shouldClose() then
            --d.log("opening switch " .. switch.name)
            switch._attachedTo:transitionOut()
            switch.isClosed = false
        end
    end
end

--- Initializes a new Switch instance.
---@param element UIElement the element to switch
function Switch:init(element)
    --TODO want to check element:isa(UIElement) but isa seems to be unstable in 1.12.3?
    if not element then 
        d.log("no UIElement to switch", element)
        return
    end
    self.name = element.name .. "Switch"
    self._attachedTo = element

    self.isClosed = false
    --- The conditions under which to 'close the switch' and enable the attached UIElement
    self.shouldClose = function ()
        if not self._isConfigured then
            d.log(self.name .. " switch-close conditions not set")
        end
    end

    self = utils.makeReadOnly(self, "Switch instance")
end

--- Add this Switch to the set of switches to be updated each frame
function Switch:add()
    activeSwitches[self.name] = self
end

--- Remove this Switch to the set of switches to be updated each frame.
function Switch:remove()
    activeSwitches[self.name] = nil
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
switch = utils.makeReadOnly(P)
return switch