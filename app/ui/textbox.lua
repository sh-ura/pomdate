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
function Textbox:init(coreProps)
    Textbox.super.init(self, coreProps) --should always be at top of init func

    self._font = gfx.getFont() --TODO make font config'able
    self:setText(self.name .. " no text set", 'dontResize')

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

--TODO word wrapping
--- Set the label to show on the button
---@param text string
---@param dontResize boolean (optional) see resize(). Resizes unless this flag is set.
function Textbox:setText(text, dontResize)
    gfx.pushContext(self._img)
        --TODO set font to self._font prior to printing text
        gfx.clear()
        gfx.drawText(text, 2, 2) -- TODO refactor
    gfx.popContext()
    if not dontResize then self:resize() end
end

--TODO just a func skeleton; make this actually work
--- Trim the textbox sprite size to the minimum required
---     for the text it contains.
--- Min textbox size is 1x1 pixels.
--- Max textbox size is always the screen dimensions.
---@return integer new width
---@return integer new height
function Textbox:resize()
    return self._img:getSize()
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
textbox = utils.makeReadOnly(P)
return textbox