---pkg 'group' provides a minimal UIElement container, whose children may share
---     visibility and selection criteria without parenting one another.
---TODO rename to layer, and ensure that it behaves like one!

import 'ui/uielement'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
group = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local configs <const> = configs
local d <const> = debugger
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

--- Group is a container for packing UIElements together
---     s.t. they share visibility and selection criteria.
--- Akin to 'folder' or 'layer'.
class('Group').extends(UIElement)
local Group <const> = Group
local _ENV = P      -- enter pkg namespace
name = "group"

--- Initializes a new Group instance.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
function Group:init(coreProps)
    Group.super.init(self, coreProps) --should always be at top of init func

    --- Optional behaviours for group selection/deselection
    self.selectedAction = function () end
    self.notSelectedAction = function() end

    self = utils.makeReadOnly(self, "Group instance")
end

--- Group update may be uneventful, unless selectedAction() or notSelectedAction()
---     are set.
function Group:update()
    Group.super.update(self)
    self._checkConfig()
    
    if self.isSelected() then self.selectedAction()
    else self.notSelectedAction() end

    --debugger.bounds(self)
end

--- Set the group container's location and dimensions, for layout purposes.
--- No effect on the locn or dims of its members.
---@param x integer global x-position
---@param y integer global y-position
---@param width integer sprite width
---@param height integer sprite height
---@return integer,integer new coordinates (x1,y1) of the top-left corner
---@return integer,integer new coordinates (x2,y2) of the bottom-right corner
function Group:configRect(x, y, width, height)
    local img = gfx.image.new(width, height)
    self:setImage(img)
    x, y, width, height = self:moveTo(x, y, "don't move children")

    self._isConfigured = true
    return x, y, width, height
end

--- Add UIElement member to the Group.
---@param element UIElement the child element
---@param linkSelection boolean whether to make child's selection criteria depend upon group. Defaults to false
function Group:addChild(element, linkSelection)
    Group.super.addChild(self, element)

    if linkSelection then
        element.isSelected = function()
            return self.isSelected()
        end
    end
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
group = utils.makeReadOnly(P)
return group