--- Collects crank ticks on each frame for subscribers.
--- Must set pd.cranked = crankhandler.cranked to drive.

local pd <const> = playdate
local d <const> = debugger
local insert <const> = table.insert
local ipairs <const> = ipairs
local floor <const> = math.floor

local subscribers = {}

--- Subscribe to the crankhandler and receive a custom getCrankTicks function to query as desired.
--- As long as their getCrankTicks function is called every frame, crankhandler will consider a
---     subscriber active, and keep them up-to-date.
--- An inactive subscriber can become active any time by calling their getCrankTicks function.
---@param ticksPerRevolution integer (optional) number of ticks to count per one full rotation of the crank.
---                             Defaults to 360.
---@return function getCrankTicks() returns integer
local function subscribe(ticksPerRevolution)
    if not ticksPerRevolution then ticksPerRevolution = 360 end
    local sub = {
        using = false,
        degreesPerTick = 360/ticksPerRevolution,
        bufferedDegrees = 0,
        ticks = 0
    }
    insert(subscribers, sub)
    return function()
        sub.using = true
        local ticks = floor(sub.ticks)
        sub.ticks = 0
        return ticks
    end
end

--- To drive the crankhandler, set the value of pd.cranked to this function
---@param change float the angle change in degrees
---@param acceleratedChange float change multiplied by a value that increases as the crank moves faster,
---                                 similar to the way mouse acceleration works
local function cranked(change, acceleratedChange)
    --d.log("cranking "..change.." deg, acceleratedChange: "..acceleratedChange)
    local degrees = 0   local ticks = 0     local degreesPerTick = 0
    for _, sub in ipairs(subscribers) do
        if sub.using then
            degrees = sub.bufferedDegrees + change
            degreesPerTick = sub.degreesPerTick
            ticks = degrees / degreesPerTick
            sub.bufferedDegrees = degrees % degreesPerTick -- leftovers -> buffer
            sub.ticks = sub.ticks + ticks
        end
        sub.using = false
    end
end

crankhandler = {
    name = "crankhandler",
    subscribe = subscribe,
    cranked = cranked
}
return crankhandler