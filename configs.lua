-- configs provides project-wide constants
local P = {}; local _G = _G
configs = {}

-- package contents and logic, within the package env --
local _ENV = P
name = "configs"

W_SCREEN = 400
W_CENTRE = 200
H_SCREEN = 240
H_CENTRE = 120

-- prepare package for export, in the global env --
local _ENV = _G
configs = utils.makeReadOnly(P)
return configs