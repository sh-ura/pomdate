-- confmanager provides project-wide constants,
--      and it enables user configuration of some app functionality.

import 'ui/list'
import 'ui/textbox'

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

local sysmenu = nil -- playdate system menu
local confMenuItem = nil
local backMenuItem = nil

local enter = function() d.log("conf enter func not set") end
local back = function() d.log("conf back func not set") end

function enter()
    sysmenu:removeMenuItem(confMenuItem)
    backMenuItem = sysmenu:addMenuItem("Back to app", back)
    toConf()
end

function back()
    sysmenu:removeMenuItem(backMenuItem)
    confMenuItem = sysmenu:addMenuItem("Config", enter)
    fromConf()
end

local function init()
    local function stateIsCONF() return state == STATES.CONF end

    sysmenu = pd.getSystemMenu()
    local resetPomsMenuItem = sysmenu:addMenuItem("Reset poms", resetPomCount)
    -- The following 2 menu items will alternate
    confMenuItem = sysmenu:addMenuItem("Config", enter)
    backMenuItem = sysmenu:addMenuItem("Back to app", back)
    sysmenu:removeMenuItem(backMenuItem)

    local backButton = Button({"backFromConfButton"}, 'invisible')
    backButton:setEnablingCriteria(stateIsCONF)
    backButton.isPressed = function() return pd.buttonJustPressed(B) end
    backButton.pressedAction = back
    backButton:forceConfigured()
    local inst = Textbox({"backFromConfInst", 300, 30}, "_B returns to app_")
    inst:setEnablingCriteria(stateIsCONF)

    --[[
    local margin = 20
    local w_row = 360
    local w_text = 240
    local w_setting = nil
    local w_boolChoice = nil
    local h_row = 30 --TODO rm; this should depend on config list height

    local pausingConf = List({"pausingConf", w_row, h_row}, list.orientations.horizontal)
    pausingConf:setEnablingCriteria(stateIsCONF)
    pausingConf:moveTo(20, 140)
    local pausingText = pausingConf:addChildren(Textbox({"pausingText", w_text, h_row}), "Timer pausing enabled")[1]
    --TODO addChildren should take an option to set the enabling criteria to depend on parent being enabled
    pausingText:setEnablingCriteria(pausingConf:isEnabled())
    w_setting = pausingConf:getMaxContentDim()
    local pausingToggle = List({"pausingToggle", w_setting, h_row}, list.orientations.horizontal)
    pausingToggle:setEnablingCriteria()
    --]]
end

confmanager = {
    name = "confmanager",
    init = init
}
confmanager = utils.makeReadOnly(confmanager)
return confmanager