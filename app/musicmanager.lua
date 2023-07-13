---TODO pkg 'musicmanager' handles the playing of not-SFX music, specifically, notification sounds.

local pd <const> = playdate
local d <const> = debugger
local snd <const> = pd.sound
local utils <const> = utils
local type <const> = type
local pairs <const> = pairs

local fileplayer = nil
local tracklist = nil
local currentTrackName = nil

--- Play a track.
---@param trackName name of the track to play
local function play(trackName)
    if not trackName then d.log("no trackName provided to play()") return end
    local trackData = tracklist[trackName]
    if not trackData or not trackData.path then d.log("missing critical data for music track "..trackName) return end

    fileplayer:pause()          -- calling stop() would trigger callback, if any
    fileplayer:load(trackData.path)
    currentTrackName = trackName
    if trackData.volume then fileplayer:setVolume(trackData.volume) end
    if trackData.callback then
        fileplayer:setFinishCallback(trackData.callback)
        fileplayer:play(1)      -- play once, so that callback can get called after
    else
        fileplayer:play(0)      -- loop endlessly
    end
end

--- Initialize the music manager
local function init()
    fileplayer = snd.fileplayer.new()
    fileplayer:setStopOnUnderrun(false)
    tracklist = {}
end

--- Add one or more tracks to the tracklist.
---@param tracks table of (name, {path, volume, callback}) tuples to add to the tracklist, OR
---              string name of the single track to add
---@param path string (optional) path to the single track to add
---@param volume float (optional) volume of the track, in range [0,1]
---@param callback function (optional) to call when track completes one playthrough
local function add(tracks, path, volume, callback)
    local function addOne(name, path, volume, callback)
        if not path then d.log("no path provided for "..name.." track") return end
        if not volume then volume = 1 end

        tracklist[name] = {
            path = path,
            volume = volume,
            callback = callback     -- may be nil
        }
    end

    if type(tracks) == "table" then
        for name, data in pairs(tracks) do
            addOne(name, data.path, data.volume, data.callback)
        end
    elseif type(tracks) == "string" then addOne(tracks, path, callback)
    else d.log("unrecognized arg1 type for musicmanager.add")
    end
end

local function update()
    if stateIsDONE_TIMER() then -- TODO should be DONE_TIMER
        local trackName = getTimerName()
        if currentTrackName == trackName and fileplayer:isPlaying() then
            return
        end
        play(trackName)
    else
        if fileplayer:isPlaying() then fileplayer:pause() end
    end
end

musicmanager = {
    init = init,
    add = add,
    update = update
}
return musicmanager