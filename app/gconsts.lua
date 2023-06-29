-- The constants below are published straight to the importing environment,
--      in this case, the global env.
W_SCREEN = 400
W_CENTRE = 200
H_SCREEN = 240
H_CENTRE = 120
Z_MAX = 32767
Z_MIN = -32768
X_B_BUTTON = 260                            -- x-position of the pixel above the leftmost edge of the B button on the playdate
X_A_BUTTON = 340                            -- x-position of the pixel above the leftmost edge of the A button on the playdate
MARGIN = 10
COLOR_0 = playdate.graphics.kColorWhite
COLOR_1 = playdate.graphics.kColorBlack     -- "positive color", ie. standard color to draw in
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
POMS_MAX = 7

SOUND = {
    notifPathPrefix = "assets/sound/notif-wav/",
    notifPathSuffix = "",
    uiPathPrefix = "assets/sound/ui/"
}
SOUND.notif_workToBreak = {
    path = SOUND.notifPathPrefix ..
        "06 When Your Eyes Meet From Across the Bar"
        .. SOUND.notifPathSuffix,
    vol = 0.9
}
SOUND.notif_breakToWork = {
    path = SOUND.notifPathPrefix ..
        "01 Into the Maelstrom"
        .. SOUND.notifPathSuffix,
    vol = 0.9
}
SOUND.notif_fromSnooze = {
    path = SOUND.notifPathPrefix ..
        "03 Bittersweet"
        .. SOUND.notifPathSuffix,
    vol = 0.9
}
SOUND.timerButtonSelected = {
    path = SOUND.uiPathPrefix ..
        "FUI Navigation Swipe Short-1",
    vol = 1
}
SOUND.timerButtonPressed = {
    paths = {
        short = SOUND.uiPathPrefix ..
            "click01",
        work = SOUND.uiPathPrefix ..
            "click02",
        long = SOUND.uiPathPrefix ..
            "click03"
    },
    vol = 1
}
SOUND.preSwitchLED = {
    path = SOUND.uiPathPrefix ..
        "tape_playback_02",
    vol = 1
}
SOUND.crankDialSwitch = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.postSwitchLED = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.timerLoaded = {
    paths = {
        short = SOUND.uiPathPrefix ..
            "",
        work = SOUND.uiPathPrefix ..
            "",
        long = SOUND.uiPathPrefix ..
            ""
    },
    vol = 1
}
SOUND.runToMenu = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.doneToMenu = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.backButton = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.nextButton = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.snoozeButton = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
SOUND.pomsFull = {
    path = SOUND.uiPathPrefix ..
        "",
    vol = 1
}
