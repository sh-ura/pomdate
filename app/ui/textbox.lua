---TODO pkg 'textbox' provides a simple textbox UIElement,
---     useful for tooltips etc.

import 'ui/uielement'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
textbox = {}

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
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

    self._font = gfx.getFont() --TODO make font config'able
    if text then self:setText(text)
    else self:setText(self.name .. " notext") end

    self = utils.makeReadOnly(self, "Textbox instance")
end

---TODO desc
function Textbox:update()
    Textbox.super.update(self)
    --d.illustrateBounds(self)
end

--- Set the font to draw text in.
--- If no font is set, textbox uses default-font-at-instantiation.
---@param font playdate.graphics.font
function Textbox:setFont(font)
    --TODO check that arg is a font
    self._font = font
end

--TODO word wrapping, resizing
--- Set the label to show on the button
---@param text string
function Textbox:setText(text)
    gfx.pushContext(self._img)
        --TODO set font to self._font prior to printing text
        gfx.clear()
        gfx.drawText(text, 0, 0)
    gfx.popContext()
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
textbox = utils.makeReadOnly(P)
return textbox