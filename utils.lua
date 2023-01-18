-- pkgs decorators such as access control

local enabled = true

local function disableReadOnly()
    enabled = false
end

-- makeReadOnly() uses metamethods to prevent adding new keys.
-- Not true readonly, as k-v reassignment is unfortunately still permitted.
-- Can use on tables such as class instances, but not on Playdate classes directly,
--      due to Classes needing to be callable for Classname()-style instantiation.
--  t                   target table
--  tname               table name
--  SPECIAL EFFECTS     1. overwrites metatable's \_\_index and \_\_newindex
local function makeReadOnly(t0, tname, indexMetaBehaviour)
    if not enabled then
        return t0
    end

    local proxy = {}
    local mt = { __index = t0 }
    setmetatable(proxy, mt)

    if not tname then 
        if t0.name then tname = t0.name
        elseif t0.className then
            tname = t0.className
        else tname = "<unknown table name>" end
    end
    local msg = tname .. " read-only; forbidden to write to it directly. Rejected key: "
    
    mt.__newindex = function(t,k,v)
        error(msg .. k)
    end

    return proxy
end

local exported = {
    name = "utils",
    disableReadOnly = disableReadOnly,
    makeReadOnly = makeReadOnly
}
utils = makeReadOnly(exported)
return utils