-- Project-wide constants

local exported = {
    name = "configs",
    W_SCREEN = 400, W_CENTRE = 200,
    H_SCREEN = 240, H_CENTRE = 120
}

configs = utils.makeReadOnly(exported)

return configs