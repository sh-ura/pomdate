---pkg 'switch' provides a Switch UI component, which can decorate a UIElement to
---     to turn it on and off according to some criteria.
switch = {}
local _G = _G

import 'ui/uielement'

local d <const> = debugger
local Object <const> = Object
local pairs <const> = pairs
local UIElement <const> = UIElement

--- Switches can turn the UIElement they attach to on and off.
--- They enable UIElement behaviour that gfx.sprite:remove() otherwise
---     inhibits: making a UIElement disappear and reappear under specific conditions,
---     *independently* of the UIManager or other UIElement parents.
class('Switch').extends(Object)
local Switch <const> = Switch
local _ENV = switch      -- enter pkg namespace
name = "switch"

local activeSwitches = {}

--- Initializes a new Switch instance.
---@param uielement UIElement the element to switch
function Switch:init(uielement)
    --TODO want to check element:isa(UIElement) but isa seems to be unstable in 1.12.3?
    if not uielement then 
        d.log("no UIElement to switch", uielement)
        return
    end
    self.name = uielement.name .. "Switch"
    self._attachedTo = uielement

    self.isClosed = false
    --- The conditions under which to 'close the switch' and enable the attached UIElement
    self.shouldClose = function ()
        if not self._isConfigured then
            d.log(self.name .. " switch-close conditions not set")
        end
    end
end

function Switch:update()
    local uielement = self._attachedTo

    if uielement._isOnScreen then

        if not self.shouldBeOnScreen() then
            uielement:remove()
        end

        if self.shouldUpdate then
            if uielement._isUpdating and not self.shouldUpdate() then
                uielement._isUpdating = false
            elseif not uielement._isUpdating and self.shouldUpdate() then
                uielement._isUpdating = true
            end
        end

        if self.shouldBeInteractable then --TODO first implement it like this, then with locks in a later commit
            if uielement._isInteractable and not self.shouldBeInteractable() then
                uielement._isInteractable = false
            elseif not uielement._isInteractable and self.shouldBeInteractable() then
                uielement._isInteractable = true
            end
        end

    elseif self.shouldBeOnScreen() then
        uielement:add()
    end
end

--- Add this Switch to the set of switches to be updated each frame
function Switch:add()
    activeSwitches[self.name] = self
end

--- Remove this Switch to the set of switches to be updated each frame.
function Switch:remove()
    activeSwitches[self.name] = nil
end

--- Drive updates for all active switches.
function update()
    for _, switch in pairs(activeSwitches) do switch:update() end
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return switch