---pkg 'cursor' provides a cursor UIElement that points to target UIElements when they are selected.
cursor = {}
local _G = _G

import 'ui/uielement' --TODO needed?

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local insert <const> = table.insert
local ipairs <const> = ipairs

--- Cursor reads the isSelected status of its target UIElements and points to the positive result
class('Cursor').extends(UIElement)
local Cursor <const> = Cursor
local _ENV = cursor     -- enter pkg namespace
name = "cursor"

--- Initializes a new Cursor instance.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
function Cursor:init(coreProps)
    Cursor.super.init(self, coreProps)

    self._targetWas = nil -- what's currently being pointed to
    self._targets = {} -- array-indexed
    self.position.getTargetPoints = {} -- functions for getting target cursor-anchoring points. uses same array indices as self._targets
end

--- Add an element to this cursor's list of prospective targets, so that the cursor
---     moves to the desired location when the element isSelected()
---@param element UIElement
---@param getCursorAnchorPoint function that outputs the gfx.geometry.point to relocate the cursor to
function Cursor:addTarget(element, getCursorAnchorPoint)
    if not (element.isSelected and element.x and element.y) then
        d.log("cannot add non-UIElement target to cursor " .. self.name)
    end
    insert(self._targets, element)
    insert(self.position.getTargetPoints, getCursorAnchorPoint)
end

---TODO desc
function Cursor:update()
    Cursor.super.update(self)
    --if not Cursor.super.update(self) then return end

    local selectedTargets = 0

    for i, element in ipairs(self._targets) do
        if element.isSelected() then
            selectedTargets = selectedTargets + 1
            if self._targetWas ~= element then
                local posn = self.position.getTargetPoints[i]()
                self:reposition(self:getPointPosition(), posn)
                self:setPosition(posn) -- return to this location after scene change
            end
            self._targetWas = element
        end
    end

    if selectedTargets > 1 then
        d.log("cursor " .. self.name .. " observed " .. selectedTargets .. " selected targets this frame")
    end

    --d.illustrateBounds(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return cursor