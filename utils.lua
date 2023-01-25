-- pkgs decorators such as access control
local P = {}; local _G = _G
utils = {}

------ package contents and logic, within the package env ------
local _ENV = P
name = "utils"

local enabled = true

-- disableReadOnly() disables the readonly feature
--      for all tables after this function is called.
-- Tables previously declared as read-only are unaffected.
function disableReadOnly()
    enabled = false
end

-- makeReadOnly() uses metamethods to prevent adding new keys.
-- Not true readonly, as k-v reassignment is unfortunately still permitted.
-- Can use on tables such as class instances, but not on Playdate classes directly,
--      due to Classes needing to be callable for Classname()-style instantiation.
--  t                   target table
--  tname               table name
--  SPECIAL EFFECTS     1. overwrites metatable's \_\_index and \_\_newindex
function makeReadOnly(t0, tname, indexMetaBehaviour)
    if not enabled then
        return t0
    end

    local proxy = {}
    local mt = { __index = t0 }
    _G.setmetatable(proxy, mt)

    if not tname then 
        if t0.name then tname = t0.name
        elseif t0.className then
            tname = t0.className
        else tname = "<unknown table name>" end
    end
    local msg = tname .. " read-only; forbidden to write to it directly. Rejected key: "
    
    mt.__newindex = function(t,k,v)
        _G.error(msg .. k)
    end

    return proxy
end

-- prepare package for export, in the global env --
local _ENV = _G
utils = P.makeReadOnly(P)
return utils