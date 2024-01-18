---pkg 'lock' provides a lock class that can be used by a dependent to track the (non)blocking status of its dependencies.
-- pkg header: define pkg namespace
lock = {}
local _G = _G

local d <const> = debugger

--- Locks can be locked and unlocked by dependencies to track their readiness.
--- Lock provides a checkIfUnlocked function that returns true if there are no locking dependencies,
---     false otherwise.
--- Thus, Lock.checkIfUnlocked can be used as the conditions function argument for
---     UIElement.addInteractivityCondition, etc.
class('Lock').extends()
local Lock <const> = Lock
local _ENV = lock      -- enter pkg namespace
name = "lock"

--- Initializes a new Lock instance.
--- Usage example:
---        local dependent = UIElement()
---        local dependency = UIElement()
---        local lock = Lock()
---        dependency:lockWhile(uielement.dependableActions.enteringScreen, lock)
---        dependent:addInteractivityCondition(lock.checkIfUnlocked)
---@param name string instance name for debugging
function Lock:init(name)
    Lock.super.init(self) --should always be at top of init func
    self.name = name -- for debugging

    local bolts = 0

    --- To be used by a dependency to lock the lock.
    self.lock = function () bolts = bolts + 1 end

    --- To be used by a dependency to unlock the lock.
    self.unlock = function ()
        bolts = bolts - 1
        if bolts < 0 then bolts = 0 end --this shouldn't happen tho
    end

    --[[ an alternative lock pattern:
        lock.lockWhile(dependency:isEntering())
        lock.lockWhile(otherDependency:isEntering())

        -- ...

        function Lock:update()
            for _, depIsDoingLockingActivity in ipairs(self.dependencies) do
                    if depIsDoingLockingActivity() then bolts = bolts + 1 end
            end
        end
    --]]

    --- To be used by a dependent in action-permission decision-making.
    ---@return boolean true iff the lock is unlocked, hence there are no blocking dependencies.
    self.checkIfUnlocked = function () return bolts <= 0 end
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return lock