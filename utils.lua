-- pkgs decorators such as access control
-- todo rename and move file into utils dir w debugger

-- err() notifies of error
--  msg         error message
--  throwError  option to throw error, instead of log to debugger
local function err(msg, throwError)
    if throwError then error(msg)
    else debugger.log(msg)
    end
end

-- makeReadOnly() uses metamethods to prevent adding/reassigning keys
--  t                   target table
--  throwError          option to throw error upon write attempt, instead of log to debugger
--  tname               table name
--  SPECIAL EFFECTS     1. overwrites metatable's \_\_newindex
--                      2. by default, 'classes' are permitted to have keys prefixed with "\_\_" overwritten (metamethods)
--                          to disallow metamethod modification, manually provide a tname
function makeReadOnly(t, throwError, tname)
    local permitMetaMethods = false
    
    local mt = getmetatable(t)
    if not mt then 
        mt = {}
        setmetatable(t, mt)
    end

    if not tname then 
        if t.name then tname = t.name
        elseif t.className then
            tname = t.className
            permitMetaMethods = true
        else tname = "<unknown table name>" end
    end
    local msg = tname .. " read-only; forbidden to write to it directly. Rejected key: "
    
    if permitMetaMethods then
        mt.__newindex = function(t,k,v)
            -- permit adding/reassigning methods beginning w __
            if k:sub(1,2) == "__" then rawset(t, k, v)
            else err(msg .. k, throwError) end
        end
    else
        mt.__newindex = function(t,k,v)
            err(msg .. k, throwError)
        end
    end
end

