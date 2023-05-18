-- The constants below are published straight to the importing environment,
--      in this case, the global env.
W_SCREEN = 400
W_CENTRE = 200
H_SCREEN = 240
H_CENTRE = 120
Z_MAX = 32767
Z_MIN = -32768
MARGIN = 10
COLOR_0 = playdate.graphics.kColorWhite
COLOR_1 = playdate.graphics.kColorBlack -- "positive color", ie. standard color to draw in
COLOR_CLEAR = playdate.graphics.kColorClear
DRAWMODE_BITMAP = playdate.graphics.kDrawModeCopy
DRAWMODE_DEBUG = playdate.graphics.kDrawModeInverted
STATES = {
    LOADING     = 1,
    CONF        = 2,
    MENU        = 3,
    RUN_TIMER   = 4,
    DONE_TIMER  = 5
}
UI_ANIM_DURATION = 1500
UI_ANIM_DELAY = 0 -- base delay in msec on state-based animations after state change