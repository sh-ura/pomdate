--- Dumps crank change data every frame that the crank is not in use.
--- Must call update() to drive.

local pd <const> = playdate
local d <const> = debugger

local usingcrank = false
local recentTicks = nil

--- Get the number of ticks that the crank has turned through
---     since the previous frame.
---@param ticksPerRevolution int frequency of ticks per full revolution of the crank
local function getCrankTicks(ticksPerRevolution)
    usingcrank = true
    -- if relevant, return result from a call earlier this frame
    if not recentTicks then recentTicks = pd.getCrankTicks(ticksPerRevolution) end
    return recentTicks
end

--- Drive the crank-data-dumping utility.
local function update()
    if not usingcrank then pd.getCrankTicks(1) end
    usingcrank = false
    recentTicks = 0
end

crankhandler = {
    name = "crankhandler",
    getCrankTicks = getCrankTicks,
    update = update
}
crankhandler = utils.makeReadOnly(crankhandler)
return crankhandler