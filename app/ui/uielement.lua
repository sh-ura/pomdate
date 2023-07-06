--- pkg 'uielement' provides an abstract class for interactive
--- UI sprites.
--- TODO may want to add justSelected and justDeselected to
---     improve efficiency and permit custom anims

import 'CoreLibs/easing'
import 'CoreLibs/animator'
import 'ui/switch'
import 'ui/animation'

-- pkg header: define pkg namespace
local P = {}; local _G = _G
uielement = {}

local pd <const> = playdate
local gfx <const> = pd.graphics
local utils <const> = utils
local d <const> = debugger
local newVector <const> = utils.newVector
local newPoint <const> = utils.newPoint
local Switch <const> = Switch
local Animation <const> = Animation
local type <const> = type
local pairs <const> = pairs
local ipairs <const> = ipairs
local insert <const> = table.insert
local centered = kTextAlignment.center

local W_SCREEN <const> = W_SCREEN
local H_SCREEN <const> = H_SCREEN
local COLOR_CLEAR <const> = COLOR_CLEAR
local COLOR_0 <const> = COLOR_0
local COLOR_1 <const> = COLOR_1
local ANIM_DURATION <const> = UI_ANIM_DURATION / 400
local ANIM_DELAY <const> = UI_ANIM_DELAY

-- configure UIElement position transformation math here
-- For all easing functions: func(t,b,c,d) => r
-- t = elapsed time
-- b = val at beginning
-- c = change == val at ending - beginning
-- d = duration (total time)
-- r = next value
local ease <const> = pd.easingFunctions.linear

--- UIElement is an interactive sprite that can parent other UIElements.
--- It can be an abstract class for more specialized UI components, or
---     be the template for simple UIElement objects such as groups/"folders".
class('UIElement').extends(gfx.sprite)
local UIElement <const> = UIElement
local _ENV = P -- enter pkg namespace
name = "uielement"

--- Initializes a new UIElement sprite.
---@param coreProps table containing the following core properties, named or array-indexed:
---         'name' or 1: (string) button name for debugging
---         'w' or 2: (integer; optional) initial width, defaults to screen width
---         'h' or 3: (integer; optional) initial height, defaults to screen height
function UIElement:init(coreProps)
    UIElement.super.init(self)
    self:setCenter(0, 0) --anchor top-left

    -- unpack coreProps
    local name, w, h
    if coreProps then
        if coreProps.name then
            name = coreProps.name
        elseif coreProps[1] then
            name = coreProps[1]
        end

        if coreProps.w then
            w = coreProps.w
        elseif coreProps[2] then
            w = coreProps[2]
        end

        if coreProps.h then
            h = coreProps.h
        elseif coreProps[3] then
            h = coreProps[3]
        end
    end
    if not name or name == "" or type(name) ~= 'string' then
        name = "unnamed-UIElement"
    end
    if not w or w == 0 or type(w) ~= 'number' then
        w = W_SCREEN
    end
    if not h or h == 0 or type(h) ~= 'number' then
        h = H_SCREEN
    end
    w = w // 1 -- ensure int
    h = h // 1
    self.name = name

    -- position props
    self.position = {
        default = newPoint(0, 0),
        offsets = {
            disabled = newVector(0, 0),
            selected = newVector(0, 0)
        },
        options = {},
        _animator = nil, -- gfx.animator that is currently performing repositioning
        _arrivalCallback = function() end  -- call this function when the element completes repositioning
    }

    -- visualization props
    self._font = gfx.getFont()
    self._textDrawMode = gfx.kDrawModeCopy
    self.text = nil
    self.bg_anim = nil      -- background
    self.fg_anim = nil      -- non-text foreground, in an animation loop (1-frame paused if static img)
    self._fg_text = nil     -- text foreground
    self._img = gfx.image.new(w, h, COLOR_CLEAR)
    self:setImage(self._img)
    self._scale = 1         -- sprite scale

    -- sound props
    self.sounds = {
        -- name = sampleplayer_or_fileplayer
    }

    --TODO _isConfigured should be a table of checks since many things need configuring
    self._isConfigured = false
    local configWarningComplete = false
    --- Log, once, that the UIElement not had been configured.
    --- Can optionally call in update(). Or ignore completely.
    self._checkConfig = function()
        if not self._isConfigured and not configWarningComplete then
            d.log("uielement '" .. self.name .. "'' not configured")
            configWarningComplete = true
        end
    end

    self._parent = "nil"    -- this backref should only be used in debugging
    self._children = {}     -- list of UIElements this panel parents
    self._i_selectChild = 1 -- index of currently selected child

    --- Determines if this UIElement is selected, ie. "focused on".
    ---@return boolean true if the element's selection criteria are met
    self.isSelected = function()
        if not self._isConfigured then d.log("uielement '" .. self.name .. "' select criteria not set") end
        return true
    end
    self._wasSelected = false -- isSelected() was true on previous update
    --- Called once each time a deselected element becomes selected
    self.justSelectedAction = function () end
    --- Called once each time selected element becomes deselected
    self.justDeselectedAction = function () end

    --- Enables/disables this UIElement.
    --- If setEnablingCriteria() is not called on this element, it will remain disabled by default.
    self._switch = Switch(self)
    self._switch.shouldClose = function()
        if not self._isConfigured then d.log("uielement '" .. self.name .. "' disabled! Set enabling conditions.") end
        return false
    end
    self._switch:add()
    self._deferringRemove = false -- element is in the process of transitioning into removal

    --- Prepare the text, to later be drawn onto the element by redraw().
    self.renderText = function()
        if not self._isConfigured then d.log("uielement " .. self.name .. "text rendering not set") end
        if not self.text then d.log("no text to render on " .. self.name) return end
        local w, h = self:getSize()
        if not self._fg_text then
            self._fg_text = gfx.image.new(w, h, COLOR_CLEAR)
        end

        gfx.pushContext(self._fg_text)
            gfx.clear(COLOR_CLEAR)
            gfx.setFont(self._font)
            gfx.setImageDrawMode(self._textDrawMode)
            gfx.drawTextAligned(self.text, w/(2 * self._scale), (h/self._scale - self._font:getHeight())/2, centered)
        gfx.popContext()
    end
end

--- Drives the element.
---@return boolean whether the element should take up user input this frame.
function UIElement:update()
    UIElement.super.update(self)

    -- handle animation to position on screen, depending on state of UI
    if self:isSelected() then
        if not self._wasSelected then
            self.justSelectedAction()
            self:reposition(self:getPointPosition(), self.position.default + self.position.offsets.selected)
        end
        self._wasSelected = true
    else
        if self._wasSelected then
            self.justDeselectedAction()
            self:reposition(self:getPointPosition(), self.position.default)
        end
        self._wasSelected = false
    end

    if self.fg_anim and not self.fg_anim.paused then
        self:redraw()
    end
    if self.position._animator then
        if self.position._animator:ended() then
            self.position._arrivalCallback()
            self.position._arrivalCallback = function() end
            self.position._animator = nil
        end
        return false
    else return true end
end

--- Redraw the UIElement's background and foreground onto its sprite.
function UIElement:redraw()
    gfx.pushContext(self._img)
        gfx.clear(COLOR_CLEAR)
        if self.bg_anim then self.bg_anim:draw(0, 0) end
        if self.fg_anim then self.fg_anim:draw(0,0) end
        if self.text then
            self.renderText()
            self._fg_text:draw(0, 0)
        end
    gfx.popContext()
    if self._scale ~= 1 then self:setImage(self._img:scaledImage(self._scale)) end
end

--- Set the font and color to use for drawing foregrounded text in this element.
---@param font gfx.font
---@param drawMode gfx.kDrawMode[mode] (optional)
function UIElement:setFont(font, drawMode)
    self._font = font
    if drawMode then self._textDrawMode = drawMode end
    self:redraw()
end

--- Draw an image, matching the UIElement's proportions if appropriate.
---@param self UIElement
---@param drawable function in the drawInRect(width, height) format, OR
---                gfx.imagetable, OR
---                gfx.nineSlice, OR anything with a :draw(x, y) funtion, ex.
---                gfx.image
---                gfx.sprite, OR
---                gfx.tilemap
---@return ui.animation, paused if the drawable is a static image
local function renderDrawable(self, drawable)
    if type(drawable) ~= 'function'
    and not (drawable.draw or drawable.drawImage) then
        d.log("img, text, or anim for " .. " not a supported drawable")
        return nil
    end

    local name = self.name .. "Anim"
    local w, h = self:getSize()
    local draw = function(width, height) end
    local imagetable = gfx.imagetable.new(1)

    if type(drawable) == 'function' then
        draw = drawable
    elseif drawable.drawImage then -- is an imagetable
        imagetable = drawable
        return Animation(name, imagetable)
    elseif drawable.drawInRect then -- is a nineSlice
        if drawable.getSize then
            local w_d, h_d = drawable:getSize()
            if w_d >= w or h_d >= h then
                d.log("can't stretch nineSlice for " .. self.name)
                return nil
            end
        end
        draw = function (width, height) return drawable.drawInRect(0, 0, width, height) end
    else -- is an image, a sprite, a tilemap, or custom class with a .draw
        draw = function (width, height) return drawable:draw(0,0) end
    end

    local img = gfx.image.new(w, h, COLOR_CLEAR)
    gfx.pushContext(img)
        draw(w, h)
    gfx.popContext()
    imagetable:setImage(1, img)
    return Animation(name, imagetable)
end

--- Set some text to show on the element, will render, by default,
---     above all other foreground and background element images.
---@param text string
function UIElement:setText(text)
    self.text = text
    self:redraw()
end

--- Set a foreground image or animation, which will sit above the element's background
---     but below its text.
--- All types of non-text foreground are processed into and stored as animations.
--- Foreground may need to be redrawn into self._img by extending classes, using :draw().
---@param drawable gfx.animation.loop, OR
---                function in the drawInRect(width, height) format, OR
---                gfx.imagetable, OR
---                gfx.nineSlice, OR anything with a :draw funtion, ex.
---                gfx.image
---                gfx.sprite, OR
---                gfx.tilemap
---@param framesDelay integer (optional) how many update frames to wait before
---                     incrementing to next animation frame. Defaults to ui.animation default
function UIElement:setForeground(drawable, framesDelay)
    self.fg_anim = renderDrawable(self, drawable)
    if framesDelay then self.fg_anim:setDelay(framesDelay) end
    self.fg_anim:add()
    local w, h = self.fg_anim:image():getSize()
    if w > self.width then
        d.log(self.name .. " background wide; resizing sprite")
        self._img = gfx.image.new(w, self.height)
        self:setImage(self._img)
    end
    if h > self.height then
        d.log(self.name .. " background tall; resizing sprite")
        self._img = gfx.image.new(self.width, h)
        self:setImage(self._img)
    end
    self:redraw()
end

--- Set a background image or animation.
--- All types of non-text background are processed into and stored as animations.
--- Background may need to be redrawn into self._img by extending classes, using :draw().
---@param drawable function in the drawInRect(width, height) format, OR
---                gfx.imagetable, OR
---                gfx.nineSlice, OR anything with a :draw funtion, ex.
---                gfx.image
---                gfx.sprite, OR
---                gfx.tilemap
---@param framesDelay integer (optional) how many update frames to wait before
---                     incrementing to next animation frame. Defaults to ui.animation default
function UIElement:setBackground(drawable, framesDelay)
    self.bg_anim = renderDrawable(self, drawable)
    if framesDelay then self.bg_anim:setDelay(framesDelay) end
    self.bg_anim:add()
    local w, h = self.bg_anim:image():getSize()
    if w > self.width then
        self.log(self.name .. " background wide; resizing sprite")
        self._img = gfx.image.new(w, self.height)
        self:setImage(self._img)
    end
    if h > self.height then
        self.log(self.name .. " background tall; resizing sprite")
        self._img = gfx.image.new(self.width, h)
        self:setImage(self._img)
    end
    self:redraw()
end

---TODO might be nice to use sound.sample more and recycle sampleplayers
---TODO use enum instead of string for name
--- Associate sound effect to this UIElement.
--- Multiple sound effects supported; just use different names.
--- Sound-play will need to be triggered manually or configured elsewhere.
---@param name string name to index the sound by, ex. "selected". Becomes: uielement.sound[name]
---@param soundplayer pd.sound.sampleplayer
---             or pd.sound.fileplayer
---@param volume float (optional)
function UIElement:setSound(name, soundplayer, volume)
    if not name or not soundplayer then d.log("missing args for "..self.name..":setSound()") end
    if not soundplayer.play then d.log("attempted to set invalid soundplayer for " .. self.name) end

    if volume then soundplayer:setVolume(volume) end
    self.sounds[name] = soundplayer
end

--- Convenience function returns element's current position as a Point
---@return gfx.geometry.point
function UIElement:getPointPosition()
    return newPoint(self:getPosition())
end

--- Get one of the element's positional anchors
---@param name string (optional) name of the position offset type, ex. 'disabled', 'selected'
---@return gfx.geometry.point
function UIElement:getConfiguredPosition(name)
    local offset = self.position.offsets[name]
    if not offset then offset = newVector(0, 0) end
    return self.position.default + offset
end

--- Set the element's default position on the screen when the element is visible.
--- To configure behaviour-specific relocation animations, see offsetPositions()
---@param x integer default x-position on the screen
---         OR gfx.geometry.point
---         OR gfx.geometry.vector2D
---@param y integer default y-position on the screen
function UIElement:setPosition(x, y)
    if x and y then
        self.position.default = newPoint(x, y)
    elseif x.unpack then
        self.position.default = newPoint(x:unpack())
    end
end

--- Configure the relocation of the element upon change in state/behaviour.
--- If an offset of a given name already exists for this element, the new vector will
---     be added to it, rather than overriding it entirely.
--- Thus you may wish to call resetOffsets() priorly.
---@param vectors table of pd.geometry.vector2D indexed by name, ex. "disabled", "selected"
---@param options table (optional) options indexed by the vector name they apply to
function UIElement:offsetPositions(vectors, options)
    if vectors and type(vectors) == "table" then
        local v_o
        for name, v in pairs(vectors) do
            v_o = self.position.offsets[name]
            if not v_o then v_o = newVector(0,0) end
            self.position.offsets[name] = v_o + v
        end
    else d.log("bad arg1 to offsetPositions. need table of Vector2D") end
    if options and type(options) == 'table' then
        for name, o in pairs(options) do
            self.position.options[name] = o
        end
    end
end

--- Reset position offset(s) to the zero vector.
---@param offsets string OR array of string offset names, ex. {"disabled", "selected"}
function UIElement:resetOffsets(names)
    local zero = newVector(0,0)
    if type(names) == 'table' then
        for _, name in ipairs(offsets) do
            if self.position.offsets[name] then self.position.offsets[name] = zero end
        end
    elseif type(names) == 'string' then
        if self.position.offsets[names] then self.position.offsets[names] = zero end
    end
end

--- Animate element into a new position
---@param origin pd.geometry.point
---@param destination pd.geometry.point or pd.geometry.vector2D
---@param callback function (optional) to call upon arrival at destination
---@param reverses boolean (optional) true if element should move back to origin after upon reaching destination
function UIElement:reposition(origin, destination, callback, reverses)
    if destination and destination.dotProduct then
        destination = origin + destination
    end
    self.position._animator = gfx.animator.new(
        ANIM_DURATION * origin:distanceToPoint(destination), --TODO need to make this val tiny
        origin, destination, ease, ANIM_DELAY
    )
    if callback then
        self.position._arrivalCallback = callback end
    if reverses then
        self.position._animator.reverses = true end
    self:setAnimator(self.position._animator)
end

--- Parents another UIElement.
---@param e table of child UIElements, or a single UIElement
---@param parentEnables boolean (option) child is enabled/disabled when parent is enabled/disabled
---@return table of successfully added child UIElements
---SPEC EFFECT  overrides each child's ZIndex to be relative to parent above its new parent
function UIElement:addChildren(e, parentEnables)
    if not e or type(e) == 'boolean' then
        d.log("no children to add to " .. self.name)
        return {}
    end

    local newChildren = {}
    local function addChild(element)
        if not element:isa(UIElement) then
            local name = element.name
            if not name then name = 'no_name' end
            d.log("element " .. name .. " is not a UIElement; can't be child to " .. self.name)
            return
        end

        element._parent = self
        insert(self._children, element)
        insert(newChildren, element)
        if parentEnables then
            element:setEnablingCriteria(function() return self:isEnabled() end)
        end
        element:setPosition(element.position.default + newVector(self.position.default:unpack()))
        element:setZIndex(element:getZIndex() + self:getZIndex())
    end

    if e.isa then
        addChild(e)           -- a single playdate Object
    else
        for _, element in pairs(e) do
            addChild(element)
        end
    end
    return newChildren
end

--- Add element to global sprites list and animate it into position.
function UIElement:add()
    UIElement.super.add(self)
    self:reposition(self.position.default + self.position.offsets.disabled, self.position.default)
end

function UIElement:remove()
    self:reposition(self:getPointPosition(), self.position.default + self.position.offsets.disabled, function()
        UIElement.super.remove(self)
        self._wasSelected = false
    end)
end

--- Moves the UIElement and its children
---@param xOrP integer x-position OR pd.geometry.point OR pd.geometry.vector2D
---@param y integer y-position
---@param dontMoveChildren boolean (optional) false by default, set to true if children should be left in position
---@return integer,integer new coordinates (x1,y1) of the top-left corner
---@return integer,integer new coordinates (x2,y2) of the bottom-right corner
function UIElement:moveTo(xOrP, y, dontMoveChildren)
    local x_o, y_o = self:getPosition()
    local x = xOrP
    if type(xOrP) ~= "number" then
        x = xOrP.x
        y = xOrP.y
    end
    UIElement.super.moveTo(self, x, y)

    if not dontMoveChildren and self._children then
        for _, child in ipairs(self._children) do
            -- globally reposition child, keeping local posn (ie. distance from parent's prev locn)
            child:moveTo(self.x + child.x - x_o, self.y + child.y - y_o)
        end
    end

    return x, y, x + self.width, y + self.height
end

function UIElement:setScale(scale)
    self._scale = scale
    self:redraw()
end

--- Set the Z index for the UIElement.
--- Its children will also be re-indexed,
---     but they will retain their zIndex *relative to* this parent element
---     and one another.
---@param z integer the value to set Z to
function UIElement:setZIndex(z)
    UIElement.super.setZIndex(self, z)
    if self._children then
        for _, child in ipairs(self._children) do
            child:setZIndex(child:getZIndex() + z)
        end
    end
end

--- Forcefully flag the UIElement as having been configured, supressing related warnings.
function UIElement:forceConfigured()
    self._isConfigured = true
end

--- Set the conditions under which this UIElement should be visible and enabled
---@param conditions function that returns a boolean if the conditions have been met
function UIElement:setEnablingCriteria(conditions)
    if type(conditions) ~= 'function' then
        d.log(self.name .. "-enabling conditions must be func", conditions)
        return
    end

    -- existing switch will be garbage-collected
    if self._switch then self._switch:remove() end
    self._switch = Switch(self)
    self._switch.shouldClose = conditions
    self._switch:add()
end

function UIElement:isEnabled()
    --if self._switch.isClosed then d.log(self.name .. " is enabled.") end
    return self._switch.isClosed
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
uielement = utils.makeReadOnly(P)
return uielement
