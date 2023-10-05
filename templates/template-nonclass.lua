--[[TODO rm
    This is a template non-class entity.
    Unlike template-class, the namespace being worked in is global.
    Find+Replace 'package' with the classname (lowercase)
--]]

---TODO pkg 'package' DESC
-- pkg header: define pkg namespace
local pd <const> = playdate
local d <const> = debugger
local utils <const> = utils
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

--local localstatic <const> = val --TODO non-imported statics go here

local persistentData = nil
--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initialize package data and behaviours
local function init()
    persistentData = {}
end

--- Update package data and behaviours
local function update()

end

-- pkg footer: pack and export package members that should be published.
package = {
    init = init,
    update = update
}
return package