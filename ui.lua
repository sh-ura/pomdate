---pkg 'ui' defines a singleton UI class

import 'button'

--[[
    TODO 
    1. move all UI related code (ex button gen) to this file
            go slow; refactor a small part, test, repeat
    2. override key sprite class funcs such as moveTo, add, remove
        to trickle the command down to all buttons, as well as the UI superclass itself
    3. set up the other menu buttons
    4. set up the timer-state "buttons"
    5. add rough transition anims to menu, just to architect how it would work
]]--

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

---TODO UI desc
--TODO im not convinced this needs to be a sprite or even a class at all?
class('UI').extends(gfx.sprite)
--local localstatic <const> = val --TODO non-imported statics go here

local instance = nil
local buttons = {
    work = nil,
    short = nil,
    long = nil,
    configApp = nil,
    pause = nil,
    snooze = nil
}
local timersmenu = {} -- seq that timer buttons appear in

--local function localfunc() end --TODO local funcs go here

--- Initializes a new UI instance.
--- Call instantiate() *instead of* instantiating directly with UI().
function UI:init()
    UI.super.init(self)

    buttons.work = button.new("work", 0, 0)
    buttons.work.isSelected = function ()
        return state == STATES.MENU
    end
    buttons.work.isPressed = function ()
        return pd.buttonJustPressed(A)
    end
    buttons.work.action = function ()
        selectedTimer = timers.work
        state = STATES.TIMER
        buttons.work:remove()
        toRun()
    end
    timersmenu = {buttons.work, buttons.short, buttons.long}

    -- buttons.pause = button.new(
    --     "pause",
    --     40,
    --     40,
    --     function ()
    --         toMenu()
    --         --TODO actually these should ONLY change the global state and animate themselves
    --     end
    -- )

    self = utils.makeReadOnly(self, "UI instance")
end

---TODO desc
function UI:update()
    if state == STATES.MENU then
        buttons.work:add()
    -- elseif state == STATES.TIMER then
    --     buttons.pause:add() --TODO we dont wanna do this every frame; figure out how we wanna do transitions
    --     if pd.buttonJustPressed(B) then
    --         buttons.pause:press()
    --         buttons.pause:remove()
    --         state = STATES.MENU
    --     end
    end

    UI.super.update(self)
    --debugger.bounds(self)
end

--- Initializes and returns new UI instance.
--- If instance already exists, this func does nothing but returns that instance.
--- Call new() *instead of* instantiating directly with UI().
---@return UI instance
local function instantiate()
    if instance then 
        d.log("UI instance exists; can't reinstantiate.")
    else
        instance = UI()
    end
    return instance
end

--TODO function get() end

ui = {
    name = "ui",
    instantiate = instantiate
}
ui = utils.makeReadOnly(ui)
return ui