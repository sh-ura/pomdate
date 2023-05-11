-- The constants below are published straight to the importing environment,
--      in this case, the global env.
W_SCREEN = 400
W_CENTRE = 200
H_SCREEN = 240
H_CENTRE = 120
Z_MAX = 32767
Z_MIN = -32768
MARGIN = 10
COLOR_BG = playdate.graphics.kColorWhite
COLOR_PRIM = playdate.graphics.kColorBlack
COLOR_BITMAP = playdate.graphics.kDrawModeCopy
COLOR_DEBUG = playdate.graphics.kDrawModeInverted
STATES = {
    LOADING     = 1,
    CONF        = 2,
    MENU        = 3,
    RUN_TIMER   = 4,
    DONE_TIMER  = 5
}