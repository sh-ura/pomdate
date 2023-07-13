--- pkg utils contains generic utility functions for all files in the project
utils = {}
local _G = _G

local pd <const> = playdate
local pairs = pairs
local type = type

local _ENV = utils
name = "utils"

newVector = pd.geometry.vector2D.new
newPoint = pd.geometry.point.new

-- prepare package for export, in the global env --
local _ENV = _G
return utils