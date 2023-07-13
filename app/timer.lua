-- pkg Timer provides value-based timers that work around the pausing bug in the Playdate SDK
timer = {}
local _G = _G

import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing" --TODO rm

local pd <const> = playdate
local d <const> = debugger
local tmr <const> = pd.timer
local utils <const> = utils
local floor <const> = math.floor -- TODO may be able to replace this w // floor division lua operator?
local pairs <const> = pairs

-- Timer packs a timer with its UI.
class('Timer').extends()
local Timer <const> = Timer
local _ENV = timer
name = "timer"

local MSEC_PER_SEC <const> = 1000
local SEC_PER_MIN <const> = 60

local activeTimers = {}

function update()
    tmr.updateTimers()
    for _, timer in pairs(activeTimers) do
        timer:update()
    end
end

--- Initializes, but does not start, a Timer.
---@param name string timer's name for graybox and debugging
---@param callback function (optional) to call when timer completes
function Timer:init(name, callback)
    -- TODO give each timer a name
    Timer.super.init(self)
    self.name = name
    self._callback = callback

    self._duration = 0.0 -- float timer duration in msec

    self._timer = nil -- "value-based" pd timer w linear interpolation
    self._isPaused = false -- true iff the timer is paused
end

--TODO desc
--TODO how to drive updates now that we don't inherit from sprite
function Timer:update()
    -- if timer has completed
    if self._timer and self._timer.value <= 0 then
        self:stop()
        self._callback()
    end
end

--- Stop a Timer.
--- Stopped timers can be restarted by calling start().
function Timer:stop()
    activeTimers[self.name] = nil
    self._timer = nil
    self._isPaused = false
end

--- Pause a Timer.
--- Paused timers can be continued with start().
function Timer:pause()
    if self._timer then
        activeTimers[self.name] = nil
        -- self._timer:pause() -- doesn't work; when started the value 'fast-forwards' according to the current time
        self._isPaused = true

        --TODO below is workaround for pd.timer:pause() being broken.
        -- Rm/refactor when bugfix
        self._duration = self._timer.value -- cache time-at-pause as new duration
        self._timer = nil
    else d.log(self.name .. " timer is nil; can't pause") end
end

--- Start a timer from a paused *or* stopped state.
--- Supports starting from both states to mimic pd.timer's docs.
--- However running timers cannot be started. Call reset() instead.
function Timer:start()
    if self._timer then
        d.log("forbidden to reset timer " .. self.name)
    else
        self._timer = tmr.new(self._duration, self._duration, 0)
        self._isPaused = false
        activeTimers[self.name] = self
    end
end

--[[ Won't work while pd.timer:pause() is buggy
--- (re)Starts a Timer that will run for its configured duration
function Timer:reset()
    self.timer:stop()
    self.timer:start()
end

--- Returns true if the timer is stopped, ex. if it has completed.
function Timer:isStopped()
    return self._timer == nil
end
--]]


--- Set the duration the timer should run for (in minutes).
---@param mins integer duration
function Timer:setDuration(mins)
    self._duration = (mins + 0.0) * SEC_PER_MIN * MSEC_PER_SEC
end

--- Returns true if this timer is active (ie. has been started and is not paused)
function Timer:isActive()
    if activeTimers[self.name] == self then return true
    else return false end
end

--- Get the time remaining in clock time
---@param msec integer milliseconds
---@return integer minutes
---@return integer seconds remainder
function Timer:getClockTime()
    --TODO refactor when pd.timer.pause() is fixed
    local msec = 0
    if self._isPaused then msec = self._duration --TODO rm workaround
    elseif self._timer then msec = self._timer.value
    end
    
    local sec = msec / MSEC_PER_SEC
    local min = floor(sec / SEC_PER_MIN)
    sec = floor(sec - min * SEC_PER_MIN)
    return min, sec
end


local _ENV = _G
return timer