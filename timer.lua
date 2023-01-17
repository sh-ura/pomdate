import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

local MSEC_PER_SEC <const> = 1000
local SEC_PER_MIN <const> = 60

-- Timer packs a timer with its UI.
-- Both the class and its instances are read-only (see utils.makeReadOnly()).
class('Timer').extends(gfx.sprite)

-- TODO decide where I want to set timer posn; amend img size and init params accordingly
-- Timer:init(xpos, ypos) initializes, but does not start, a Timer.
function Timer:init(x, y)
    Timer.super.init(self)

    self:setCenter(0, 0)
    self:moveTo(x, y)

    self.timer = nil
    self.img = gfx.image.new(100, 50)
    self:setImage(self.img)
    makeReadOnly(self, true, "timer instance")
end

--[[
    :update() is called before :draw is called on all sprites
    Suspected conditions for redrawing a sprite if getAlwaysRedraw() == false
        - associated gfx.image has changed
        - sprite has had some transform applied to it
    So if we need to update a sprite every frame, do something in its :update()
--]]
-- Timer:update() draws the current time in the timer countdown
function Timer:update()
    if self.timer then
        local msec = self.timer.value
        local min, sec = convertTime(msec)
        -- debugger.log("min: " .. min .. " sec: " .. sec)
        -- debugger.log(self.timer.value)

        local timeString = ""
        if min < 10 then timeString = "0" end
        timeString = timeString .. min .. ":"
        if sec < 10 then timeString = timeString .. "0" end
        timeString = timeString .. sec

        gfx.lockFocus(self.img)
            gfx.clear()
            gfx.drawText(timeString, 0, 0)
        gfx.unlockFocus()

        -- if timer has completed
        if msec <= 0 then
            self.timer = nil
            gfx.lockFocus(self.img)
                gfx.clear()
                gfx.drawText("DONE", 0, 0)
            gfx.unlockFocus()
        end
    end

    Timer.super.update(self)
    debugger.bounds(self)
end

function Timer:start(minsDuration)
    if not self.timer then -- TODO do  completed timers pass this? if not, test for playdate.timer.timeLeft instead
        -- Returns a new playdate.timer that will run for duration milliseconds. 
        -- callback is a function closure that will be called when the timer is complete.
        -- TODO see playdate.timer.timerEndedCallback
        local msecDuration = minsDuration * SEC_PER_MIN * MSEC_PER_SEC
        debugger.log(msecDuration)
        rawset(self, "timer", pd.timer.new(msecDuration, msecDuration, 0)) -- "value-based" timer w linear interpolation

        if self.timer then debugger.log("timer was nil - now created") end
    else
        self.timer:start() -- TODO check that this autostarts the timer
        debugger.log("timer not nil - started")
    end
end

--[[ not needed yet
function Timer:pause()
    if self:timerIsNil("pause()") then return end
    self.timer:pause()
end
--]]

function Timer:reset()
    if not self.timer then
        debugger.log("self.timer is nil. Can't call Timer:reset().")
        return
    end
    self.timer:reset()
    debugger.log("timer reset")
end

-- convertTime(msec) returns a (min, sec) conversion of the argument, rounded down
function convertTime(msec)
    local sec = msec / MSEC_PER_SEC
    local min = math.floor(sec / SEC_PER_MIN)
    sec = math.floor(sec - min * SEC_PER_MIN)
    return min, sec
end

--[[ not needed yet
-- this function may not need to be named here
-- define it in the pd.timer.new closure?
function notify(t)
    -- call when countdown ends
end
--]]

makeReadOnly(Timer, true)