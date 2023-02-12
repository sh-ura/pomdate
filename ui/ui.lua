--- pkg 'ui' defines a singleton UI class
--- For dev convenience, this package accesses the global namespace,
--- but is not intended to modify any global var other than STATE.

import 'ui/uielement'
import 'ui/button'
import 'ui/panel'

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
class('UI').extends(UIElement)
--local localstatic <const> = val --TODO non-imported statics go here

local instance = nil
local buttons = { --TODO rm dont actually need these to persist here
    work = nil,
    short = nil,
    long = nil,
    configApp = nil,
    pause = nil,
    snooze = nil
}
local timersmenu = nil -- seq that timer buttons appear in

--local function localfunc() end --TODO local funcs go here

--- Initializes and returns new UI instance.
--- If instance already exists, this func does nothing but returns that instance.
function UI:init()
    if instance then 
        d.log("UI instance exists; not reinstantiating; returning instance")
        return instance
    end

    UI.super.init(self, "uimanager <<singleton>>")

    buttons.work = Button("work")
    buttons.work.isPressed = function ()
        return pd.buttonJustPressed(A)
    end
    buttons.work.action = function ()
        selectedTimer = timers.work
        state = STATES.TIMER
        timersmenu:transitionOut()
        toRun()
    end
    timersmenu = Panel("timers")
    timersmenu.isSelected = function ()
        return state == STATES.MENU
    end
    timersmenu:addChild(buttons.work)
    timersmenu:moveTo(300,20)

    instance = self
    self = utils.makeReadOnly(self, "UI instance")
end

---TODO desc
function UI:update()
    if state == STATES.MENU then
        timersmenu:transitionIn()
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

--TODO function get() end

ui = {name = "ui"}
ui = utils.makeReadOnly(ui)
return ui