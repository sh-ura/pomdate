---pkg ButtonSwitch can render an animation of a switch attached to a button
-- pkg header: define pkg namespace
buttonswitch = {}
local _G = _G

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local Render <const> = Render
local COLOR = GFX.COLOR
local pathPrefix = GFX.GEN.pathPrefix
local pi <const> = math.pi
local sin <const> = math.sin
local cos <const> = math.cos
local type <const> = type
local centered <const> = kTextAlignment.center

--- ButtonSwitch renders an animation of a button with a horizontal-hinge-style switch above it, connected by a vertical tether.
--- A very specific animation for the "crank dial circuit" UI.
class('ButtonSwitch').extends(Render)
local ButtonSwitch <const> = ButtonSwitch
local _ENV = buttonswitch -- enter pkg namespace
name = "buttonswitch"

--- Creates a render of a button-switch.
---@param name string
---@param drawButtonShape function that takes (width,height) input and draws the basic button shape
---@param buttonWidth number width of the button
---@param buttonHeight number height of the button
---@param buttonLabel string or image to label the button with
---@param buttonTravel number distance traveled per frame
---@param switchLength number length of switch
---@param switchThickness number thickness of the switch
---@param spacing number approximate distance between the switch and the button
function ButtonSwitch:init(name, drawButtonShape, buttonWidth, buttonHeight, buttonLabel, buttonTravel, switchLength, switchThickness,
                           spacing)
    --TODO test that all of these inputs are actually given
    self.drawButtonShape = drawButtonShape
    self.buttonWidth = buttonWidth
    self.buttonHeight = buttonHeight
    self.buttonLabel = buttonLabel
    self.buttonTravel = buttonTravel
    self.switchLength = switchLength
    self.switchThickness = switchThickness
    self.spacing = spacing

    ButtonSwitch.super.init(self, name)
end

--- (Re)bakes the buttonswitch animation
function ButtonSwitch:bake()
    local drawButtonShape = self.drawButtonShape
    local buttonWidth = self.buttonWidth
    local buttonHeight = self.buttonHeight
    local buttonLabel = self.buttonLabel
    local buttonTravel = self.buttonTravel
    local switchLength = self.switchLength
    local switchThickness = self.switchThickness
    local spacing = self.spacing

    local w_frame = switchLength + 10
    local h_frame = switchLength + spacing + buttonHeight / 2
    local n_frames = 10
    local C = 3 / 4 * pi -- phase shift
    local x_button = 0.1 * switchLength
    local y_button = switchLength + spacing + 2

    local Amp = 0.8 * switchLength -- amplitude
    local radPerFrame = pi / 4 / (n_frames - 1)
    local buttonTravelPerFrame = buttonTravel / n_frames

    local imagetable = gfx.imagetable.new(n_frames)
    local theta
    local x
    local y
    local i_frame
    for j = 0, n_frames - 1 do
        local frame = gfx.image.new(w_frame, h_frame, COLOR.clear)
        theta = j * radPerFrame
        x = Amp * cos(-theta - C)
        y = Amp * sin(-theta - C)
        gfx.pushContext(frame)
            gfx.setColor(COLOR.pos)
            gfx.setLineWidth(switchThickness)
            gfx.setLineCapStyle(gfx.kLineCapStyleRound)
            -- draw wire from (x,y) to the unit-circle origin, transposed by (switchLength, switchLength)
            gfx.drawLine(x + switchLength, y + switchLength, switchLength, switchLength)
            gfx.setLineWidth(4)
            -- draw tether from the switch wire to the B button
            x = x_button + buttonWidth / 2
            y = y + switchLength + 5
            gfx.drawLine(x, y, x, 242)
            -- button
            x = x_button
            y = y_button + j * buttonTravelPerFrame
            drawButtonShape(buttonWidth, buttonHeight, x, y)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            if type(buttonLabel) == "string" then
                gfx.drawTextAligned(buttonLabel, x + buttonWidth / 2, y + 10, centered)
            end
        gfx.popContext()

        i_frame = j + 1
        imagetable:setImage(i_frame, frame)
    end
    self.imagetable = imagetable

    ButtonSwitch.super.bake(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return buttonswitch
