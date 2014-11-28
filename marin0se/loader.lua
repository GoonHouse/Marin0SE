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

function loadcustomtiles()
	if love.filesystem.exists("mappacks/" .. mappack .. "/tiles.png") then
		customtiles = true
		customtilesimg = love.graphics.newImage("mappacks/" .. mappack .. "/tiles.png")
		local imgwidth, imgheight = customtilesimg:getWidth(), customtilesimg:getHeight()
		local width = math.floor(imgwidth/17)
		local height = math.floor(imgheight/17)
		local imgdata = love.image.newImageData("mappacks/" .. mappack .. "/tiles.png")
		
		for y = 1, height do
			for x = 1, width do
				table.insert(tilequads, quad:new(customtilesimg, imgdata, x, y, imgwidth, imgheight))
				local r, g, b = getaveragecolor(imgdata, x, y)
				table.insert(rgblist, {r, g, b})
			end
		end
		customtilecount = width*height
	else
		customtiles = false
		customtilecount = 0
	end
end


function loadanimatedtiles()
	if animatedtilecount then
		for i = 1, animatedtilecount do
			tilequads["a" .. i] = nil
		end
	end
	
	local function loadfolder(folder)
		local fl = love.filesystem.getDirectoryItems(folder)
		
		local i = 1
		while love.filesystem.isFile(folder .. "/" .. i .. ".png") do
			local v = folder .. "/" .. i .. ".png"
			if love.filesystem.isFile(v) and string.sub(v, -4) == ".png" then
				if love.filesystem.isFile(string.sub(v, 1, -5) .. ".txt") then
					animatedtilecount = animatedtilecount + 1
					local number = animatedtilecount+10000
					local t = animatedquad:new(v, love.filesystem.read(string.sub(v, 1, -5) .. ".txt"), number)
					tilequads[number] = t
					table.insert(animatedtiles, t)
				end
			end
			i = i + 1
		end
	end
	
	animatedtilecount = 0
	animatedtiles = {}
	loadfolder("graphics/animated")
	loadfolder("mappacks/" .. mappack .. "/animated")
end

function loadcustommusics()
	musiclist = {"none.ogg", "overworld.ogg", "underground.ogg", "castle.ogg", "underwater.ogg", "starmusic.ogg"}
	local fl = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/music")
	custommusics = {}
	
	for i = 1, #fl do
		local v = fl[i]
		if (v:match(".ogg") or v:match(".mp3")) and v:sub(-9, -5) ~= "-fast" then
			table.insert(musiclist, v)
			--music:load(v) --Sometimes I come back to code and wonder why things are commented out. This is one of those cases. But it works so eh.
		end
	end
end

function loadlevelscreens()
	levelscreens = {}
	
	local fl = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/levelscreens")
	
	for i = 1, #fl do
		local v = "mappacks/" .. mappack .. "/levelscreens/" .. fl[i]
		if love.filesystem.isFile(v) then
			table.insert(levelscreens, string.lower(string.sub(fl[i], 1, -5)))
		end
	end
end

function loadcustombackgrounds()
	custombackgrounds = {}

	custombackgroundimg = {}
	custombackgroundwidth = {}
	custombackgroundheight = {}
	local fl = love.filesystem.getDirectoryItems("mappacks/" .. mappack .. "/backgrounds")
	
	for i = 1, #fl do
		local v = "mappacks/" .. mappack .. "/backgrounds/" .. fl[i]
		
		if love.filesystem.isFile(v) then
			if string.sub(v, -5, -5) == "1" then
				local name = string.sub(fl[i], 1, -6)
				local bg = string.sub(v, 1, -6)
				local i = 1
				
				custombackgroundimg[name] = {}
				custombackgroundwidth[name] = {}
				custombackgroundheight[name] = {}
					
				while love.filesystem.exists(bg .. i .. ".png") do
					print("background", bg, "index", i)
					custombackgroundimg[name][i] = love.graphics.newImage(bg .. i .. ".png")
					custombackgroundwidth[name][i] = custombackgroundimg[name][i]:getWidth()/16
					custombackgroundheight[name][i] = custombackgroundimg[name][i]:getHeight()/16
					i = i + 1
				end
				table.insert(custombackgrounds, name)
			--[[else
				local name = string.sub(fl[i], 1, -5)
				local bg = string.sub(v, 1, -5)
				
				custombackgroundimg[name] = {love.graphics.newImage(bg .. ".png")}
				custombackgroundwidth[name] = {custombackgroundimg[name][1]:getWidth()/16}
				custombackgroundheight[name] = {custombackgroundimg[name][1]:getHeight()/16}
				
				table.insert(custombackgrounds, name)]]
			end
		end
	end
end

function loadcustomimages(path)
	for i = 1, #overwrittenimages do
		local s = overwrittenimages[i]
		_G[s .. "img"] = _G["default" .. s .. "img"]
	end
	overwrittenimages = {}

	local fl = love.filesystem.getDirectoryItems(path)
	for i = 1, #fl do
		local v = fl[i]
		if love.filesystem.isFile(path .. "/" .. v) then
			local s = string.sub(v, 1, -5)
			if table.contains(imagelist, s) then
				_G[s .. "img"] = love.graphics.newImage(path .. "/" .. v)
				table.insert(overwrittenimages, s)
			end
		end
	end
	
	--tiles
	tilequads = {}
	rgblist = {}
	
	--add smb tiles
	local imgwidth, imgheight = smbtilesimg:getWidth(), smbtilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata
	if love.filesystem.isFile(path .. "/smbtiles.png") then
		imgdata = love.image.newImageData(path .. "/smbtiles.png")
	else
		imgdata = love.image.newImageData("graphics/DEFAULT/smbtiles.png")
	end
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(smbtilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	smbtilecount = width*height
	
	--add portal tiles
	local imgwidth, imgheight = portaltilesimg:getWidth(), portaltilesimg:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)
	local imgdata
	if love.filesystem.isFile(path .. "/portaltiles.png") then
		imgdata = love.image.newImageData(path .. "/portaltiles.png")
	else
		imgdata = love.image.newImageData("graphics/DEFAULT/portaltiles.png")
	end
	
	for y = 1, height do
		for x = 1, width do
			table.insert(tilequads, quad:new(portaltilesimg, imgdata, x, y, imgwidth, imgheight))
			local r, g, b = getaveragecolor(imgdata, x, y)
			table.insert(rgblist, {r, g, b})
		end
	end
	portaltilecount = width*height
end