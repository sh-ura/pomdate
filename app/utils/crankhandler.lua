--- Dumps crank change data every frame that the crank is not in use.
--- Must call update() to drive.

local pd <const> = playdate
local d <const> = debugger

local usingcrank = false

--- Get the number of ticks that the crank has turned through
---     since the previous frame.
---@param ticksPerRevolution int frequency of ticks per full revolution of the crank
local function getCrankTicks(ticksPerRevolution)
    usingcrank = true
    return pd.getCrankTicks(ticksPerRevolution)
end

--- Drive the crank-data-dumping utility. Call on every frame.
local function update()
    if not usingcrank then pd.getCrankTicks(1) end
    usingcrank = false
end

crankhandler = {
    name = "crankhandler",
    getCrankTicks = getCrankTicks,
    update = update
}
crankhandler = utils.makeReadOnly(crankhandler)
return crankhandler