-- confmanager provides project-wide constants,
--      and it enables user configuration of some app functionality.

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local A <const> = pd.kButtonA
local B <const> = pd.kButtonB

-- The constants below are published straight to the importing environment,
--      in this case, the global env.
W_SCREEN = 400
W_CENTRE = 200
H_SCREEN = 240
H_CENTRE = 120
Z_MAX = 32767
Z_MIN = -32768
AXES = {
    X = 1,
    Y = 2
}
STATES = {
    LOADING     = 1,
    CONF        = 2,
    MENU        = 3,
    RUN_TIMER   = 4,
    DONE_TIMER  = 5
}

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
    local inst = Textbox({"backFromConfInst", 300, 30})
    inst:setEnablingCriteria(stateIsCONF)
    inst:setText("_B returns to app_", "dontResize")
end

confmanager = {
    name = "confmanager",
    init = init
}
confmanager = utils.makeReadOnly(confmanager)
return confmanager