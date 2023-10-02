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
local confs = {}
local metaconfs = {
    snoozeOn = {
        default = true,
        get = function()
            d.log("no confs.snoozeOn.get func set")
            return confs.snoozeOn
        end
    },
    snoozeDuration = {
        default = 2,
        min = 1,
        max = 10,
        get = function()
            d.log("no confs.snoozeDuration.get func set")
            return confs.snoozeDuration
        end
    },
    pomsPerCycle = {
        default = 3,
        min = 2,
        max = POMS_MAX,
        get = function()
            d.log("no confs.pomsPerCycle.get func set")
            return confs.pomsPerCycle
        end
    },
    pomSavingOn = {
        default = false,
        get = function()
            d.log("no confs.pomSavingOn.get func set")
            return confs.pomSavingOn
        end
    }
}
local snooze_max = 10

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

--- Initializes the configuration manager and screen.
---@param state table containing any loaded configuration state
local function init(savestate)
    -- initialize confs using loaded savestate or the default values
    for k, v in pairs(metaconfs) do
        if savestate and savestate[k] ~= nil then confs[k] = savestate[k]
        else confs[k] = v.default end
    end
    d.log("confmanager state loaded, confs:", confs)

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
    inst:moveTo(MARGIN, H_SCREEN - MARGIN - inst.height) -- bottom of screen

    local c_confs = 0
    for _ in pairs(confs) do c_confs = c_confs + 1 end
    local w_setting, h_setting
    local w_label, h_label
    local w_labelBonus = 80
    local w_setter, h_setter

    local confList = List(
        {"confList", W_SCREEN - MARGIN*2, inst.y - 10 - MARGIN},
        vert, 2
    )
    confList:moveTo(MARGIN, MARGIN)
    w_setting, h_setting = confList:getMaxContentDim(c_confs)
    confList:setEnablingCriteria(stateIsCONF)

    --- Creates a list item, label, and setter for a configurable setting
    ---@param name string setting name to be used in debugging
    ---@param description string label to be shown to the user
    ---@return List setter, to contain the interactable UIElements for this setting
    local function initConfItem(name, description)
        local item = List({name, w_setting, h_setting}, hori, 1)
        w_setter, h_setter = item:getMaxContentDim(2)
        h_label = h_setter
        w_label = w_setter + w_labelBonus -- give label a bit more room
        w_setter = w_setter - w_labelBonus
        local label = Button({name.."Desc", w_label, h_label})
        local setter = List({name.."Setter", w_setter, h_setter}, hori, 0)
        item:addChildren({label, setter}, 'parentEnables')
        confList:addChildren(item, 'parentEnables')

        label:setText(description)
        label.isSelected = function() return item.isSelected() end
        label:forceConfigured() -- label only needs to hilight like a button
        setter.isSelected = function() return item.isSelected() end

        return setter
    end

    --- Populate a On/Off toggle setter
    ---@param setter List obtained from initConfItem (above)
    ---@param init initial value, true or false
    ---@return function that yields the current value
    local function fillONFSetterGetter(setter, init)
        local w, h = setter:getMaxContentDim(2)
        local switch = init
        local OnBtn = Button({setter.name.."OnBtn", w, h})
        OnBtn:setText("On")
        OnBtn.isPressed = OnBtn.isSelected
        OnBtn.pressedAction = function() switch = true end
        local OffBtn = Button({setter.name.."OffBtn", w, h})
        OffBtn:setText("Off")
        OffBtn.isPressed = OffBtn.isSelected
        OffBtn.pressedAction = function() switch = false end
        setter:addChildren({OnBtn, OffBtn}, 'parentEnables')

        if not init then setter:next() end
        return function() return switch end
    end

    --- Populate a dial-type setter
    ---@param setter List obtained from initConfItem (above)
    ---@param unit string
    ---@param min number minimum value
    ---@param max number maximum value
    ---@param init number initial value
    ---@return function that yields the current value
    local function fillDialSetterGetter(setter, unit, min, max, init)
        local w, h = setter:getMaxContentDim()
        local dial = Dial({setter.name.."Dial", w, h}, min, max)
        dial.getDialChange = crankhandler.subscribe(max)
        dial:setUnit(unit)
        setter:addChildren(dial, 'parentEnables')
        dial.isSelected = function () return setter.isSelected() end
        
        dial:setValue(init)
        return function() return dial.value end
    end

    metaconfs.snoozeOn.get = fillONFSetterGetter(
        initConfItem("snoozeONF", "Timers can be snoozed"),
        confs.snoozeOn
    )
    metaconfs.snoozeDuration.get = fillDialSetterGetter(
        initConfItem("snoozeDuration", "Snooze duration"),
        "min",
        metaconfs.snoozeDuration.min,
        metaconfs.snoozeDuration.max,
        confs.snoozeDuration
    )
    metaconfs.pomsPerCycle.get = fillDialSetterGetter(
        initConfItem("pomsPerCycle", "Poms per long break"),
        "pom",
        metaconfs.pomsPerCycle.min,
        metaconfs.pomsPerCycle.max,
        confs.pomsPerCycle
    )
    metaconfs.pomSavingOn.get = fillONFSetterGetter(
        initConfItem("pomSavingOn", "Save elapsed poms on quit"),
        confs.pomSavingOn
    )
end

--- Call to update confs based on user selections.
--- Can call every frame, or just when closing the config menu.
local function update()
    for k, _ in pairs(confs) do confs[k] = metaconfs[k].get() end
end

--- Prepares the conf state to be saved as app data.
---@return table to save in data file
local function sav()
    update()
    return confs
end

confmanager = {
    name = "confmanager",
    confs = confs,
    init = init,
    update = update,
    sav = sav
}
return confmanager