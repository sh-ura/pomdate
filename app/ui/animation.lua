---pkg 'animation' provides an animation object that can draw images
---     from an imagetable.
animation = {}
local _G = _G

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local insert <const> = table.insert
local pairs <const> = pairs
local type <const> = type
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

---TODO Animation desc
class('Animation').extends()
local Animation <const> = Animation
local _ENV = animation     -- enter pkg namespace
name = "animation"

local activeAnimations = {}
local i_nextAnimation = 1

--- Enum for bookmarking animation frames.
--- Uses strings instead of integers to differentiate from frame indices. See track()
bookmarks = {
    first = "1",
    last = "2"
}

function update()
    for _, animation in pairs(activeAnimations) do animation:update() end
end

--- Initializes a new Animation instance.
--- Animation is paused by default, can be played with play() or track().
---@param name string instance name for debugging
---@param imagetable gfx.imagetable to use
function Animation:init(name, imagetable)
    Animation.super.init(self)
    
    self.name = name
    self._imagetable = imagetable
    self._bookmarks = {}
    self._bookmarks[bookmarks.first] = 1
    self._bookmarks[bookmarks.last] = #imagetable
    self._frame = self._bookmarks[bookmarks.first]
    self._c_delay = 0
    self._default_step = 1
    self._step = self._default_step
    self._default_delay = 5
    self._delay = self._default_delay
    self._isPaused = true
    self._endAt = nil
    self._countdownFrames = nil
    self._callback = function () end

    self._i = i_nextAnimation
    i_nextAnimation = i_nextAnimation + 1
end

--- Set the default delay, in update frames rather than time, between animation frames.
--- This delay will be applied upon next call to track() or play().
---@param framesDelay integer (optional) how many update frames to wait before
---                     incrementing to next animation frame. Defaults to 5
function Animation:setDelay(framesDelay)
    self._default_delay = framesDelay
end

--TODO make Switch use this indexing method as well
--- Add this animation to the list of active animations to be updated on animation.update()
function Animation:add()
    activeAnimations[""..self._i..""] = self
end

--- Remove this animation from the list of active animations to be updated on animation.update()
function Animation:remove()
    activeAnimations[""..self._i..""] = nil
end

---TODO desc
function Animation:update()
    if self._isPaused then return end
    local frame = self._frame
    if (self._countdownFrames and self._countdownFrames <= 0)
    or (self._endAt and self._endAt == frame) then
        self:pause()
        self._step = self._default_step
        self._delay = self._default_delay
        self._endAt = nil
        self._countdownFrames = nil
        self._callback()
        return
    end
    
    self._c_delay = self._c_delay + 1
    if self._c_delay >= self._delay then
        self._c_delay = 0
        frame = frame + self._step
        if frame > #self._imagetable then
            frame = frame % #self._imagetable -- loop forwards
        elseif frame < 1 then
            frame = #self._imagetable + frame -- loop backwards
        end
        self._frame = frame
        if self._countdownFrames then self._countdownFrames = self._countdownFrames - 1 end
    end
end

--- Get the image at the current frame
---@return gfx.image
function Animation:image()
    return self._imagetable[self._frame]
end

--- Draw the image at the current frame
---@param x integer x-position
---@param y integer y-position
function Animation:draw(x, y)
    self._imagetable[self._frame]:draw(x,y)
end

--- Pause the animation
function Animation:pause()
    self._isPaused = true
end

--- Pause the animation and reset it to the first frame
function Animation:stop()
    self:pause()
    self._frame = self._bookmarks[bookmarks.first]
end

--- Play the animation.
---@param step integer (optional) unit to step through frames by. Negative value: backwards.
---@param delay integer (optional) how many update frames to wait before
---                     incrementing to next animation frame. Defaults to default set during init.
---@param ending integer (optional) how many frames to play
---                     OR bookmark the frame to end on.
---                     If not provided, the animation loops.
---@param callback function (optional) to call if+when animation ends at ending.
---@param beginning animation.bookmark (optional) the frame to start on.
function Animation:play(step, delay, ending, callback, beginning)
    if beginning then
        self._frame = self._bookmarks[beginning]
    end
    if ending then
        if type(ending) == 'number' then
            self._countdownFrames = ending
        else -- bookmark
            self._endAt = self._bookmarks[ending]
        end
        if callback then
            self._callback = callback
        else
            self._callback = function () end
        end
    end
    if step then self._step = step
    else self._step = self._default_step end
    if delay then self._delay = delay
    else self._delay = self._default_delay end
    self._isPaused = false
end

--- Returns the dimensions of the current frame.
---@return integer width
---@return integer height
function Animation:getSize()
    return self._imagetable[self._frame]:getSize()
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return animation