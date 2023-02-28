local getmetatable = getmetatable
local setmetatable = setmetatable
local error = error
local next = next

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

---TODO DEBUG
---     1. when no proxy is used (ie. setmetatable(t, mt)), class instances become readonly
---TODO dont need to return a table if we dont use a proxy here; refactor in all files that use this func
--- Prevents adding new keys.
--- Not true readonly, as k-v reassignment is unfortunately still permitted.
---@param t table to make read-only
---@param name string (optional) table name to use
function makeReadOnly(t, name)
    if not enabled then
        return t
    end

    local proxy = {}
    local mt = {
        __index = t,
        __len = function()
            return #t
        end,
        __pairs = function()
            return next, t, nil
        end,
        __ipairs = function()
            return function(t, i)
                i = i + 1
                local v = t[i]
                if v ~= nil then return i, v end
            end, t, 0
        end
    }
    setmetatable(proxy, mt)

    if not name then 
        if t.name then name = t.name
        else name = "<unknown table name>" end
    end
    local msg = name .. " read-only; forbidden to write to it directly. Rejected key: "
    
    mt.__newindex = function(t,k,v)
        _G.error(msg .. k)
    end

    return proxy
end

-- prepare package for export, in the global env --
local _ENV = _G
utils = P.makeReadOnly(P)
return utils