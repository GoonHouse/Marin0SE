loader = class("loader")

--[[@NOTE:
	This is written as a god object to do things like loading assets based on other assets.
	Should do the thing fine.
	
	This makes use of the globals:
		spritebatches		stores batches for sprites!
]]

function loader:init()
	self.filesToLoad = {}
	self.objectsToLoad = 0 --#above
	self.objectsLoaded = 0 --
	
	
end

function loader:update(dt)
	-- check the status of a thread and report back with eta / progress
	
end

function loader:processTileset(name, img)
	spritebatches[name] = love.graphics.newSpriteBatch( img, spritebatchsize )
	spritebatches[name.."_front"] = love.graphics.newSpriteBatch( img, spritebatchsize )
end