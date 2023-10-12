---pkg 'render' provides a Render class and some utility functions, for making and loading code-generated graphics.
-- pkg header: define pkg namespace
render = {}
local _G = _G

local pd <const> = playdate
local d <const> = debugger
local gfx <const> = pd.graphics
local insert <const> = table.insert
local pathPrefix <const> = GFX.GEN.pathPrefix
local ipairs <const> = ipairs

--- Render is an abstract class for implementing, saving, and loading code-generated graphics.
--- Renders package together a rendering function ('bake') and the rendered result, which is
---     an imagetable containing the image (or animable series of images.)
class('Render').extends()
local Render <const> = Render
local _ENV = render      -- enter pkg namespace
name = "render"

local renders = {}
local forceBake = false
local permitWrite = true

--- Initializes a new Render instance, using data from the filesystem to load in its imagetable if possible,
---     or baking a new render otherwise.
---@param name string instance name for debugging
function Render:init(name)
    Render.super.init(self) --should always be at top of init func
    
    self.name = name
    self.imagetable = gfx.imagetable.new(pathPrefix .. name)
    if not self.imagetable then
        d.log(self.name .. " images not found; baking")
        self:bake()
    elseif forceBake then
        self:bake()
    end
    insert(renders, self)
end

--- Default bake function - should be overridden by inheriting class.
function Render:bake()
    if not self.imagetable then
        d.log("no imagetable for " .. self.name)
        return
    end
    self:write()
end

--- Save the current imagetable to the playdate Data folder.
function Render:write()
    if not permitWrite then return end
    for i, frame in ipairs(self.imagetable) do
        pd.datastore.writeImage(frame, pathPrefix .. self.name .. "-table-" .. i)
    end
end

--- Re-render all initialized renders to generate a new set of imagetables.
--- Animations/sprites using these imagetables may need to be updated to use the new
---     imagetables.
---@param bakeFutureRenders boolean (optional) if true, force-bakes all future renders as well. Defaults to false.
function bakeAll(bakeFutureRenders)
    if bakeFutureRenders then
        forceBake = true
        d.log("forcing bake of all subsequent renders")
    end
    for _, r in ipairs(renders) do
        r:bake()
    end
end

--- Disables writing renders to the file system upon bake.
--- Presently in use b/c I can't figure out how to load imagetables from the Data folder. :(
function disableWriting()
    permitWrite = false
end

-- pkg footer: pack and export the namespace.
local _ENV = _G
return render