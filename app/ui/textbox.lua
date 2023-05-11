---TODO pkg 'textbox' provides a simple textbox UIElement,
---     useful for tooltips etc.

--TODO rn this has no distinguishing features from UIElement. rm?

import 'ui/uielement'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
textbox = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local COLOR_CLEAR <const> = COLOR_CLEAR
--local externalfunc <const> = somepkg.func --TODO any other external vars go here

---TODO Textbox desc
class('Textbox').extends(UIElement)
local Textbox <const> = Textbox
local _ENV = P      -- enter pkg namespace
name = "textbox"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new Textbox UIElement instance.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
---@param text string (optional) text to set
function Textbox:init(coreProps, text)
    Textbox.super.init(self, coreProps) --should always be at top of init func

    self._text = self.name .. " no-text"
    if text then self._text = text end

    --TODO override self.renderText()

    self = utils.makeReadOnly(self, "Textbox instance")
end

---TODO desc
function Textbox:update()
    Textbox.super.update(self)
    --d.illustrateBounds(self)
end

--TODO word wrapping, resizing
--- Set the label to show on the button
---@param text string
function Textbox:setText(text)
    self._text = text
    self:redraw()
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
textbox = utils.makeReadOnly(P)
return textbox