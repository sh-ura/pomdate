-- confmanager provides project-wide constants,
--      and it enables user configuration of some app functionality.

--TODO standardize use of conf vs setting vocab

import 'ui/list'
import 'ui/textbox'
import 'ui/button'

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB
local vert <const> = list.orientations.vertical
local hori <const> = list.orientations.horizontal
local pairs <const> = pairs

local sysmenu = nil -- playdate system menu
local confMenuItem = nil
local backMenuItem = nil

--- Published as the active set of confs
local confs = {
    snooze = nil
}
local defaults = {
    snooze = true
}

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
    local margin_screen = 20
    local function stateIsCONF() return state == STATES.CONF end

    -- main will load and initialize any saved settings at startup
    -- here, we init any outstanding non-initialized settings
    for k, v in pairs(defaults) do
        if confs[k] == nil then d.log("no conf " ..k) confs[k] = v end
    end

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
    local inst = Textbox({"backFromConfInst", 300, 20}, "_B returns to app_")
    inst:setEnablingCriteria(function () return backButton:isEnabled() end)
    inst:moveTo(margin_screen, H_SCREEN - margin_screen - inst.height) -- bottom of screen

    local settings = {
        snoozeONF = { -- the keys below will be present in all setting tables
            item = nil, -- ui.list: the container to represent the setting in the confs table
            desc = nil, -- ui.textbox: the setting description
            setter = nil -- ui element: the interactable element
        },
        savePomCountONF = {},
        pomsPerLongBreak = {},
        snoozeDuration = {},
        toWorkSound = {},
        toBreakSound = {},
        snoozeSound = {}
    }
    local c_settings = 0
    for _ in pairs(settings) do c_settings = c_settings + 1 end

    local w_setting, h_setting
    local w_desc, h_desc
    local w_descBonus = 50
    local w_setter, h_setter

    local confList = List(
        {"confList", W_SCREEN - margin_screen*2, inst.y - 10 - margin_screen},
        vert, 2
    )
    confList:moveTo(margin_screen, margin_screen)
    w_setting, h_setting = confList:getMaxContentDim(c_settings)
    confList:setEnablingCriteria(stateIsCONF)

    --TODO this block should be generic to all settings
    settings.snoozeONF.item = List({"snoozeONF", w_setting, h_setting}, hori, 0)
    w_setter, h_setter = settings.snoozeONF.item:getMaxContentDim(2)
    h_desc = h_setter
    w_desc = w_setter + w_descBonus -- give desc a bit more room
    w_setter = w_setter - w_descBonus
    settings.snoozeONF.desc = Textbox({"snoozeONFDesc", w_desc, h_desc},
        "Timer snoozing")
    settings.snoozeONF.desc.isSelected = function() return false end
    settings.snoozeONF.setter = List({"snoozeONFSetter", w_setter, h_setter}, hori, 0)
    local item = settings.snoozeONF.item --TODO refactor once generic
    settings.snoozeONF.setter.isSelected = function() return item.isSelected() end
    settings.snoozeONF.item:addChildren(
        {settings.snoozeONF.desc, settings.snoozeONF.setter}, 'parentEnables')
    confList:addChildren(settings.snoozeONF.item, 'parentEnables')
    settings.snoozeONF.setter.isSelected = function() return item.isSelected() end

    local w_tmp, h_tmp = settings.snoozeONF.setter:getMaxContentDim(2)
    local snoozeOnBtn = Button({"snoozeOnButton", w_tmp, h_tmp})
    snoozeOnBtn:setLabel("On")
    snoozeOnBtn.isPressed = function() return snoozeOnBtn.isSelected() end
    snoozeOnBtn.pressedAction = function() confs.snooze = true end
    local snoozeOffBtn = Button({"snoozeOffButton", w_tmp, h_tmp})
    snoozeOffBtn:setLabel("Off")
    snoozeOffBtn.isPressed = function() return snoozeOffBtn.isSelected() end
    snoozeOffBtn.pressedAction = function() confs.snooze = false end
    settings.snoozeONF.setter:addChildren({snoozeOnBtn, snoozeOffBtn}, 'parentEnables')
    if not confs.snooze then settings.snoozeONF.setter:next() end -- toggle to loaded setting val
end

confmanager = {
    name = "confmanager",
    confs = confs,
    init = init
}
confmanager = utils.makeReadOnly(confmanager)
return confmanager