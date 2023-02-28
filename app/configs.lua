-- configs provides project-wide constants
-- todo probs should just have this export a bunch of namespace-unbound vars
local P = {}; local _G = _G
configs = {}

-- package contents and logic, within the package env --
local _ENV = P
name = "configs"

W_SCREEN = 400
W_CENTRE = 200
H_SCREEN = 240
H_CENTRE = 120
Z_MAX = 32767
Z_MIN = -32768

-- todo rm??
STATES = {
    LOADING     = 1,
    CONFIG      = 2,
    MENU        = 3,
    TIMER       = 4
}

-- prepare package for export, in the global env --
local _ENV = _G
configs = utils.makeReadOnly(P)
return configs