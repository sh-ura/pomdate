--[[TODO rm
    This is a template class.
    Features a class namespace + pseudo-readonly access control on pkg and instances
    Find+Replace (case-sensitive) 'Class' with the Classname
    Find+Replace 'classinstance' with the classname (lowercase)
    Find+Replace 'package' with the classname (lowercase)
--]]
--TODO this file should not get compiled into main
--  make sure it doesn't go into the src folder

---TODO pkg 'package' DESC

-- pkg header: define pkg namespace
local P = {}; local _G = _G
package = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local configs <const> = configs
local d <const> = debugger
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

---TODO Class desc
class('Class').extends(gfx.sprite)
local Class <const> = Class
local _ENV = P      -- enter pkg namespace
name = "package"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new Class instance.
--- Call new() *instead of* instantiating directly with Class().
---@param x integer: global x-position
---@param y integer: global y-position
function Class:init(x, y)
    Class.super.init(self)

    self:setCenter(0, 0)
    self:moveTo(x, y)

--    self.property = val   -- TODO instance properties. Public

    self = utils.makeReadOnly(self, "Class instance")
end

---TODO desc
function Class:update()
    

    Class.super.update(self)
    --debugger.bounds(self)
end

--- Initializes and returns new Class instance.
--- Call new() *instead of* instantiating directly with Class().
---@param x integer: global x-position
---@param y integer: global y-position
---@return Class instance
function new(x, y)
    return Class()
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
package = utils.makeReadOnly(P)
return package