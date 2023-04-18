-- configs provides project-wide constants,
--      and it enables user configuration of some app functionality.

-- The constant below are published straight to the importing environment,
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
    CONFIG      = 2,
    MENU        = 3,
    RUN_TIMER   = 4,
    DONE_TIMER  = 5
}

local pd <const> = playdate

local sysmenu = nil -- playdate system menu

local function init()
    sysmenu = pd.getSystemMenu()

    sysmenu:addMenuItem("Reset poms", resetPomCount)
end

configs = {
    name = "configs",
    init = init
}
configs = utils.makeReadOnly(configs)
return configs