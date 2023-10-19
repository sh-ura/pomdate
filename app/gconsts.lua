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
SNOOZE_LVL = {1,2}

GFX = {
    -- TODO move W_SCREEN, COLOR_0 etc. into here and rm above
    COLOR = {
        neg = playdate.graphics.kColorWhite,
        pos = playdate.graphics.kColorBlack,     -- "positive color", ie. standard color to draw in
        clear = playdate.graphics.kColorClear
    },
    GEN = {
        pathPrefix = "assets/gen/" -- parent: Data folder?
    },
    ICON = {
        pathPrefix = "assets/icons/"
    }
}
GFX.ICON.backPath = GFX.ICON.pathPrefix ..
    "back-button.png"
GFX.ICON.skipPath = GFX.ICON.pathPrefix ..
    "skip-button.png"
GFX.ICON.nextPath = GFX.ICON.pathPrefix ..
    "next-button.png"
GFX.ICON.snoozePath = GFX.ICON.pathPrefix ..
    "snooze-button.png"

FONT = {
    pathPrefix = "assets/fonts/"
}

SOUND = {
    notifPathPrefix = "assets/sound/notif-wav/",
    notifPathSuffix = "", -- TODO should become ".adpcm"
    uiPathPrefix = "assets/sound/ui/"
}
SOUND.notif_workToBreak = {
    path = SOUND.notifPathPrefix ..
        "09 Blue Raspberry Flavoured Lip Gloss" -- TODO change
        .. SOUND.notifPathSuffix,
    volume = 0.8
}
SOUND.notif_breakToWork = {
    path = SOUND.notifPathPrefix ..
        "01 Into the Maelstrom"
        .. SOUND.notifPathSuffix,
    volume = 0.8
}
SOUND.notif_fromSnooze = {
    {
        path = SOUND.notifPathPrefix ..
            "03 Bittersweet"
            .. SOUND.notifPathSuffix,
        volume = 0.8
    },
    {
        path = SOUND.notifPathPrefix ..
            "07 Confidence, Baby.adpcm"
            .. SOUND.notifPathSuffix,
        volume = 0.8
    },
}
SOUND.timerButtonSelected = { -- TODO needs export
    paths = {
        short = SOUND.uiPathPrefix ..
            "FUI Button Click-1",
        work = SOUND.uiPathPrefix ..
            "FUI Cursor Click",
        long = SOUND.uiPathPrefix ..
            "FUI Cursor Blunt"         --"FUI Button Pitch Jump"
    },
    volume = 0.7
}
SOUND.timerButtonPressed = {
    paths = {
        short = SOUND.uiPathPrefix ..
            "LOAD_CASSETTE_08",
        work = SOUND.uiPathPrefix ..
            "LOAD_CASSETTE_02",
        long = SOUND.uiPathPrefix ..
            "LOAD_CASSETTE_07"
    },
    volume = 1
}
SOUND.preSwitchLED = {
    path = SOUND.uiPathPrefix ..
        "tape_playback_02",
    volume = 1
}
SOUND.crankDialSwitch = {
    closing = {
        path = SOUND.uiPathPrefix ..
            "switch-held/Target Lock",
        volume = 1
    },
    closed = {
        path = SOUND.uiPathPrefix ..
            "BUTTON_STOP_05",
        volume = 0.4
    }
}
SOUND.postSwitchLED = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
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
    volume = 1
}
SOUND.runToMenu = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
}
SOUND.doneToMenu = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
}
SOUND.backButton = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
}
SOUND.nextButton = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
}
SOUND.snoozeButton = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
}
SOUND.pomsFull = {
    path = SOUND.uiPathPrefix ..
        "",
    volume = 1
}
