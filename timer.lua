-- timer provides value-based timers, rendered as sprites
local P = {}; local _G = _G
timer = {}

import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/easing" --TODO rm

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local floor <const> = math.floor -- TODO may be able to replace this w // floor division lua operator?
local linease = pd.easingFunctions.linear --TODO rm

-- Timer packs a timer with its UI.
class('Timer').extends(gfx.sprite)
local Timer <const> = Timer

local MSEC_PER_SEC <const> = 1000
local SEC_PER_MIN <const> = 60

local notifSound = nil

local _ENV = P
name = "timer"

--- Converts the msec argument into the clock time, rounded down
---@param msec integer milliseconds
---@return integer minutes
---@return integer seconds remaining after msec is converted to min 
local function convertTime(msec)
    local sec = msec / MSEC_PER_SEC
    local min = floor(sec / SEC_PER_MIN)
    sec = floor(sec - min * SEC_PER_MIN)
    return min, sec
end

--- Notifies user that timer is complete
local function notify()
    --d.log("notification pushed")
    if notifSound then notifSound:play(0) end
end

--- Set the sound to be played when a timer finishes
---@param sound pd.sound.sampleplayer or pd.sound.fileplayer
function setNotifSound(sound)
    if not sound.play or not sound.stop then
        d.log("attempting to set unplayable notif sound", sound)
        return
    end
    notifSound = sound
end

--- Initializes, but does not start, a Timer.
---@param name string timer's name for graybox and debugging
function Timer:init(name)
    -- TODO give each timer a name
    Timer.super.init(self)
    self.name = name

    self._duration = 0.0 -- float timer duration in msec
    self._minsDuration = 0 -- cache int duration in min, saves some computation in getDuration()
    self._img = gfx.image.new(200,150)
    self:setImage(self.img)
    
    self.timer = nil

    self:setCenter(0, 0) --anchor top-left
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

        gfx.pushContext(self._img)
            gfx.clear()
            gfx.drawText("*"..timeString.."*", 0, 0)
        gfx.popContext()

        -- if timer has completed
        if msec <= 0 then
            gfx.pushContext(self._img)
                gfx.clear()
                gfx.drawText("*DONE*", 0, 0)
            gfx.popContext()
            self.timer = nil
            notify()
        end

        --DEBUG doing this prevents the sprite from auto-refreshing when self._img changes
        --TODO set a larger font instead of upscaling default text
        self:setImage(self._img:scaledImage(4))
    end

    Timer.super.update(self)
    --debugger.illustrateBounds(self)
end

function Timer:remove()
    notifSound:stop()
    Timer.super.remove(self)
end

function Timer:start()
    self.timer = pd.timer.new(self._duration, self._duration, 0) -- "value-based" timer w linear interpolation
end

function Timer:stop()
    self.timer = nil
end

--- Set the duration the timer should run for (in minutes).
---@param mins integer duration
function Timer:setDuration(mins)
    self._minsDuration = mins
    self._duration = (mins + 0.0) * SEC_PER_MIN * MSEC_PER_SEC
end

--- Get the duration the timer will run for (in minutes).
---@return integer mins duration
function Timer:getDuration()
    return self._minsDuration
end

local _ENV = _G
timer = utils.makeReadOnly(P)
return timer