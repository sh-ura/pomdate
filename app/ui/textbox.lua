---TODO pkg 'textbox' provides a simple textbox UIElement,
---     useful for tooltips etc.
--TODO rn this has no distinguishing features from UIElement. rm?
textbox = {}; local _G = _G

import 'ui/uielement'

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
local _ENV = textbox      -- enter pkg namespace
name = "textbox"

--local localstatic <const> = val --TODO non-imported statics go here

--local localvar = val --TODO local vars go here

--local function localfunc() end --TODO local funcs go here

--- Initializes a new Textbox UIElement instance.
---@param configs table adhering to the format of uielement.getDefaultConfigs()
---@param text string (optional) text to set
function Textbox:init(configs, text)
    Textbox.super.init(self, configs) --should always be at top of init func

    self.text = self.name .. " no-text"
    if text then self.text = text end

    --TODO override self.renderText()
end

---TODO desc
function Textbox:update()
    if not Textbox.super.update(self) then return end
    --d.illustrateBounds(self)
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return textbox