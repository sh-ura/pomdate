--[[TODO rm
    This is a template class.
    Features a class namespace
    Find+Replace (case-sensitive) 'Class' with the Classname
    Find+Replace 'package' with the classname (lowercase)
--]]

---TODO pkg 'package' DESC
-- pkg header: define pkg namespace
package = {}
local _G = _G

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

---TODO Class desc
class('Class').extends()
local Class <const> = Class
local _ENV = package      -- enter pkg namespace
name = "package"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new Class instance.
---@param name string instance name for debugging
function Class:init(name)
    Class.super.init(self) --should always be at top of init func
    
    self.name = name
--    self.property = val   -- TODO instance properties. Public

    self:setCenter(0, 0) --anchor top-left
end

---TODO desc
function Class:update()
    Class.super.update(self)
    --d.illustrateBounds(self)

    
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return package