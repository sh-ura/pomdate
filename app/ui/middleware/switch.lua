---pkg 'switch' provides a Switch UI component, which can decorate a UIElement to
---     to turn it on and off according to some criteria.
switch = {}
local _G = _G

import 'ui/uielement'

local d <const> = debugger
local Object <const> = Object
local pairs <const> = pairs
local UIElement <const> = UIElement
local insert <const> = table.insert

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

--- Check that all conditions return true.
---@param conditions table containing functions that return a boolean value
---@return boolean true iff all conditions return true
local function allConditionsMet(conditions)
    if not conditions then d.log("no conditions to check") return nil end

    for _, condition in conditions do
        if condition() ~= true then
            return false
        end
    end
    return true
end

function Switch:update()
    local uielement = self._attachedTo

    if uielement._isOnScreen then

        if not allConditionsMet(self.onScreenConditions) then
            uielement:remove()
        end

        if self.updateConditions then
            if uielement._isUpdating and not allConditionsMet(self.updateConditions) then
                uielement._isUpdating = false
            elseif not uielement._isUpdating and allConditionsMet(self.updateConditions) then
                uielement._isUpdating = true
            end
        end

        if self.interactivityConditions then
            if uielement._isInteractable and not allConditionsMet(self.interactivityConditions) then
                uielement._isInteractable = false
            elseif not uielement._isInteractable and allConditionsMet(self.interactivityConditions) then
                uielement._isInteractable = true
            end
        end

    elseif allConditionsMet(self.onScreenConditions) then
        uielement:add()
    end
end

conditionalStatus = {
    onscreen = "onscreen",
    updating = "update",
    interactable = "interactivity"
}
---Check if an action is possible conditional status, ie. member of switch.conditionalStatus
---@param str string
---@return boolean true iff member
local function isaConditionalStatus(str)
    for _, v in pairs(conditionalStatus) do
        if v == str then return true end
    end
    return false
end

function Switch:addCondition(conditionalStatus, condition)
    if not isaConditionalStatus(conditionalStatus) then
        d.log("not a valid member of switch.conditionalStatus")
        return
    end

    local conditionsTable = conditionalStatus .. "Conditions"
    if not self[conditionsTable] then self[conditionsTable] = {} end
    insert(self[conditionsTable], condition)
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