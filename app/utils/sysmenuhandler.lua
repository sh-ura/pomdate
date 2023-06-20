--- Notifies subscribers that the system menu is being opened.
--- Must set pd.gameWillPause = sysmenuhandler.gameWillPause to drive.

local pd <const> = playdate
local d <const> = debugger
local insert <const> = table.insert
local ipairs <const> = ipairs
local type <const> = type

local subscribers = {}
local sysmenuOpened = false

--- Subscribe to the sysmenu handler
---@param callback function sysmenuhandler will call this when the sysmenu is about to open. ex. an update() function
---@param function that yields a boolean, true iff the sysmenu is about to open
local function subscribe(callback)
    if callback and type(callback) == 'function' then
        insert(subscribers, callback)
    end
    return function() return sysmenuOpened end
end

--- To drive the sysmenu handler, set the value of pd.gameWillPause to this function
local function gameWillPause()
    sysmenuOpened = true
    for _, callback in ipairs(subscribers) do
        callback()
    end
    sysmenuOpened = false
end

sysmenuhandler = {
    name = "sysmenuhandler",
    subscribe = subscribe,
    gameWillPause = gameWillPause
}

sysmenuhandler = utils.makeReadOnly(sysmenuhandler)
return sysmenuhandler