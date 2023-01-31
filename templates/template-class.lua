--[[TODO rm
    This is a template class.
    Features a class namespace + pseudo-readonly access control on pkg and instances
    Find+Replace (case-sensitive) 'Class' with the Classname
    Find+Replace 'classinstance' with the classname (lowercase)
    Find+Replace 'pkg' with the classname (lowercase)
--]]

--- Pkg TODO DESC

local P = {}; local _G = _G
pkg = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local configs <const> = configs
local debugger <const> = debugger
--local externalfunc <const> = somepkg.func -- TODO rm

-- Class TODO DESC
class('Class').extends(gfx.sprite)
local Class <const> = Class
local _ENV = P
name = "Class"

--local localstatic <const> = val -- TODO rm

--local function localfunc() end -- TODO rm

--- init initializes a new Class instance.
--- TODO DESC
--- Call new() *instead of* initializing directly with Class().
---@param x integer: global x-position
---@param y integer: global y-position
function Class:init(x, y)
    Class.super.init(self)

    self:setCenter(0, 0)
    self:moveTo(x, y)

    self = utils.makeReadOnly(self, "Class instance")
end

--- update DESC
function Class:update()
    

    Class.super.update(self)
    --debugger.bounds(self)
end

--- new initializes and returns new instance.
--- Call new() *instead of* initializing directly with Class().
---@param x integer: global x-position
---@param y integer: global y-position
function new(x, y)
    return Class()
end

local _ENV = _G
pkg = utils.makeReadOnly(P)
return pkg