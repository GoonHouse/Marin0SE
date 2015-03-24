dmap = class("dmap")

--[[
	This exists to split some of the load out of world.lua, in addition to allowing multiple maps per world.
	These are keyed by map name in world, like: world.maps["1-1"]
]]

function dmap:init(mapName, world)
	print("dmap init")
	self.cl = nil --custom layer for objects
	self.world = world
	self.mapName = mapName
	self.state = "init" --
	self.dospawn = false
	
	--MISC VARS; Misc Global Variables
	
	self.flagx = false
	self.lakitoendx = false
	self.lakitoend = false
	self.noupdate = false
	--@DEV: these should be in the camera or something but they're here (GLOBALLY FOR NOW)
	--xscroll = 0
	--yscroll = 0
	self.ylookmodifier = 0
	self.currentscissor = {0, 0,love.window.getWidth(), love.window.getHeight()}
	self.repeatX = 0
	self.lastrepeat = 0
	self.displaywarpzonetext = false
	self.mazestarts = {}
	self.mazeends = {}
	self.mazesolved = {}
	self.mazesolved[0] = true
	self.mazeinprogress = false
	self.earthquake = 0
	self.sunrot = 0
	
	self.switchtimeout = false
	
	--class tables
	self.coinblocktimers = {}
	self.coinblockanimations = {}
	self.portalparticles = {}
	self.portalprojectiles = {}
	self.dialogboxes = {}
	self.inventory = {}
	for i = 1, 9 do
		self.inventory[i] = {}
	end
	self.mccurrentblock = 1
	self.itemanimations = {}
	
	self.blockbouncetimer = {}
	self.blockbouncex = {}
	self.blockbouncey = {}
	self.blockbouncecontent = {}
	self.blockbouncecontent2 = {}
	self.warpzonenumbers = {}
	
	self.objects = {}
	-- Initialize all registered object arrays.
	for _,v in pairs(basedents) do
		self.objects[v]={}
	end
	for _,v in pairs(saneents) do
		self.objects[v]={}
	end
	
	--@DEV: COMPATIBILITY ASSIGNMENTS FROM GLOBALS
	--objects = self.objects
	
	
	self.startx = {3, 3, 3, 3, 3}
	self.starty = {13, 13, 13, 13, 13}
	self.checkpointx = {}
	self.checkpointy = {}
	self.pipestartx = nil
	self.pipestarty = nil
	self.globalanimation = nil
	self.enemiesspawned = {}
	
	--LOAD THE MAP
	self:stiLoadMap(mapName)
	--if not self:stiLoadMap(mapName) then --make one up
		--self:dummyMap()
	--end
	
	-- SPECIAL OBJECTS
	--self.objects.screenboundary.left = screenboundary:new(0)
	--self.objects.screenboundary.right = screenboundary:new(self.map.width)
	
	if self.flagx then
		self.objects.screenboundary.flag = screenboundary:new(self.flagx+6/16)
	end
	
	if self.objects.axe and self.objects.axe[#self.objects.axe] then
		self.objects.screenboundary.axe = screenboundary:new(self.objects.axe[#self.objects.axe].cox)
	end
	
	--@WARNING: This should really be a single option but, whatever.
	if self.intermission then
		self.globalanimation = "intermission"
	elseif self.bonusstage then
		self.globalanimation = "vinestart"
	end
	
	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	--[[
	if #self.mazestarts == #self.mazeends then
		self.mazegates = {}
		for i = 1, #self.mazestarts do
			local maxgate = 1
			for x = self.mazestarts[i], self.mazeends[i] do
				for y = 1, self.mapheight do
				]]
					--if self.map[x][y][2] and entitylist[self.map[x][y][2]] and entitylist[self.map[x][y][2]].t == "mazegate" then
						--[[if tonumber(self.map[x][y][3]) > maxgate then
							maxgate = tonumber(self.map[x][y][3])
						end
					end
				end
			end
			self.mazegates[i] = maxgate
		end
	else
		print("WARNING: Mazenumber doesn't fit!")
	end
	]]
	--@NOTE: Here's where we overload to set the position of pipers! Yee.
	--[[
	if warpdestid then --@WARNING: WE USE GLOBAL STATE HERE BECAUSE WE DON'T KNOW WHAT ELSE TO DO
		local foundit=false
		local thepipex, thepipey, thepipe
		for lxi,lxa in pairs(map) do
			for lyi,lya in pairs(lxa) do
				if lya[3] == warpdestid then
					foundit=true
					self.pipestartx = lxi
					self.pipestarty = lyi
					thepipe = self.map[lxi][lyi]
					break
				end
			end
			if foundit then
				break
			end
		end
		
		if foundit then
			
			local pipeoffx, pipeoffy
			if thepipe[7] == "up" then
				pipeoffx = 1
				pipeoffy = 0
			elseif thepipe[7] == "down" then
				pipeoffx = 1
				pipeoffy = -1
			elseif thepipe[7] == "left" then
				pipeoffx = -1
				pipeoffy = 0
			elseif thepipe[7] == "right" then
				pipeoffx = 0
				pipeoffy = 0
			end
			
			self.globalanimation = "pipe_"..thepipe[7].."_out"
			
			self.startx = {self.pipestartx-pipeoffx, self.pipestartx-pipeoffx, self.pipestartx-pipeoffx, self.pipestartx-pipeoffx, self.pipestartx-pipeoffx}
			self.starty = {self.pipestarty-pipeoffy, self.pipestarty-pipeoffy, self.pipestarty-pipeoffy, self.pipestarty-pipeoffy, self.pipestarty-pipeoffy}
			
			--check if startpos is a colliding block
			]]
			--if tilequads[map[startx[1]][starty[1]][1]]:getproperty("collision", startx[1], starty[1]) then
			--	animation = "pipeup2"
			--end
		--else
			--print("WARNING: Tried to take a pipe to a level that did not have corresponding destination pipe (",warpdestid,")")
		--end
		--clear warpdestid because it would never get cleared otherwise
		--warpdestid = nil
	--end
	
	--set starts to checkpoint
	--@NOTE: I goofed with these. Don't tell anyone.
	--[[if not isSublevel and self.checkpointsub then
		for i = 1, self.checkpointsub do
			if self.checkpointx[i] then
				self.startx[i] = self.checkpointx[i]
			end
			if self.checkpointy[i] then
				self.starty[i] = self.checkpointy[i]
			end
		end
	end]]
	
	--Adjust start X scroll
	--xscroll = self.startx[1]-scrollingleftcomplete-2
	--if xscroll > self.map.width - width then
		--xscroll = self.map.width - width
	--end
	
	--if xscroll < 0 then
		--xscroll = 0
	--end
	
	--and Y too
	--[[
	yscroll = self.starty[1]-height+downscrollborder
	if yscroll > self.map.height - height - 1 then
		yscroll = self.map.height - height - 1
	end
	
	if yscroll < 0 then
		yscroll = 0
	end
	]]
	self.spawnrestrictions = {}
	
	--Clear spawn area from enemies
	--[[
	for i = 1, #self.startx do
		if self.startx[i] == self.checkpointx[i] and self.starty[i] == self.checkpointy[i] then
			table.insert(self.spawnrestrictions, {self.startx[i], self.starty[i]})
		end
	end
	]]
	
	--updateranges() --do we need to do this here? first-step simulation for range things.
end

function dmap:start()
	print("DEBUG: dmap started processing")
	--begins the simulation, for now holds the player spawns, but the world should manage that eventually
	self.state = "spawn"
	self.dostart = true
	
	-- PLAYERS ARE BORN NOW
	--@NOTE: I just don't feel like messing with this.
	local mul = 0.5
	if self.gsublevel ~= 0 or self.prevsublevel ~= false then
		-- offset the player pos based on sublevel dohickery
		mul = 2/16
	end
	
	self.objects.player = {}
	local spawns = {}
	for i = 1, players do
		local lanimation = self.globalanimation
		
		local astartx, astarty
		if i > 4 then
			astartx = self.startx[5]
			astarty = self.starty[5]
		else
			astartx = self.startx[i]
			astarty = self.starty[i]
		end
		
		if astartx then
			local add = -6/16
			for j, v in pairs(spawns) do
				if v.x == astartx and v.y == astarty then
					add = add + mul
				end
			end
			
			table.insert(spawns, {x=astartx, y=astarty})
			
			self.objects.player[i] = player:new(self.world, astartx+add, astarty-1, i, lanimation, self.world.startingsizes[i], playertype)
		else
			--@NOTE: singleplayer game start uses this
			self.objects.player[i] = player:new(self, 1.5 + (i-1)*mul-6/16+1.5, 13, i, lanimation, self.world.startingsizes[i], playertype)
		end
	end
	
	--ADD ENEMIES ON START SCREEN
	--[[
	if editormode == false then
		local xtodo = width+1
		if self.map.width < width+1 then
			xtodo = self.map.width
		end
		
		local ytodo = height+1
		if self.map.height < height+1 then
			ytodo = self.map.height
		end
			
		for x = math.floor(xscroll), math.floor(xscroll)+xtodo do
			for y = math.floor(yscroll), math.floor(yscroll)+ytodo do
				self:spawnEnemy(x, y)
			end
		end
	end
	]]
end

function dmap:stiLoadMap(mapName)
	self.mapName = mapName or "1-1"
	self.mapFormat = "lua"
	
	local mapstr = "mappacks/" .. mappack .. "/" .. mapName
	self.imap = sti.new(mapstr)
	
	self.imap:addCustomLayer("objs", 3)
	
	self.imap.layers.tiles.properties.collidable = true
	
	self.cl = self.imap.layers["objs"]
	
	self.cl.objects = self.objects
	
	function self.cl:update(dt)
		for _, objgroup in pairs(self.objects) do
			for objindex, obj in pairs(objgroup) do
				if obj.update then
					obj:update(dt)
				end
			end
		end
	end
	
	function self.cl:draw()
		legaldraw(self.objects)
		--illegaldraw(self.objects)
	end
	
	--@WARNING: feeding globals, should be undone eventually
	
	-- the game doesn't understand the rawmap so for now we forward properties as necessary
	--self.map.width = self.imap.width
	--self.map.height = self.imap.height
	
	-- unknown globals
	
	-- load properties into ourself
	for property_name,property_value in pairs(self.imap.properties) do
		self[property_name] = property_value
	end
	
	-- commented out to focus on junk, this is meant to queue the assets
	--[[for k,v in pairs(self.rawMap.tilesets) do
		-- iterate through all the potential tilesets and act accordingly
		if _G[v.name.."img"] then
			newBatch(v.name, _G[v.name.."img"])
		else
			print("WARNING: Tried to load spritebatch for nonexistant image: ", v.name)
		end
	end]]
	
	-- load the map data up from layers 1 and 2
	for layername, layer in pairs(self.imap.layers) do
		if layer.type == "tilelayer" then
			
		elseif layer.type == "objectgroup" then
			self:spawnOnMapLayer(layer.objects)
		end
	end
	
	self:linkAllObjects()
	
	--[[
	for x=1, self.map.width do
		self.map[x] = {}
		self.coinmap[x] = {}
		if not self.world.animatedtimers[x] then
			self.world.animatedtimers[x] = {}
		end
		for y=1, self.map.height do
			local dex = (y-1)*self.map.width+x --plus 1
			self.map[x][y] = {
				self.imap.layers["tiles"].data[dex],
				gels = {},
				portaloverride = {}
			}
			]]
			--@TODO: Make the get property thing easier. This was behind "createobjects" but that disappeared.
			--if tilequads[self.imap.layers["tiles"].data[dex]]:getproperty("collision") then
				--self.objects.tile[x .. "-" .. y] = tile:new(x-1, y-1) --@WARNING: PROBABLY BROKEN
			--end
			--[[
			if self.imap.layers["coins"] and self.imap.layers["coins"].data[dex] > 0 then
				self.coinmap[x][y] = true --@TODO: or the value above, when supported
			end
			]]
			--[[@NOTE: Due to the above we don't need the following:
			if tilequads[r[1] ]:getproperty("coin", x, y) then
				coinmap[x][y] = true
			end
			]]
			
			--[[@NOTE: ignore animated timers for now
			if r[1] > 10000 then
				if tilequads[ r[1] ].triggered then
					animatedtimers[x][y] = animatedtimer:new(x, y, r[1])
				end
			end
			]]
			--[[
		end
	end
	]]
	
	-- should this be sorted by period instead of position, I'm confused
	--[[
	animatedtimers = {}
	for x = 1, mapwidth do
		animatedtimers[x] = {}
	end
	]]
end

function dmap:linkAllObjects(override)
	if self.dostart or override then
		for _, objgroup in pairs(self.objects) do
			for _, obj in pairs(objgroup) do
				if obj.link then
					obj:link()
				end
			end
		end
	end
end

function dmap:xloadMap(mapName, format)
	self.mapName = mapName or "1-1"
	self.mapFormat = format or "txt"
	
	local mapstr = "mappacks/" .. mappack .. "/" .. mapName .. "." .. format
	print("LOADING: dmap processing "..mapstr)
	if love.filesystem.exists(mapstr) == false then
		print("CRITICAL: dmap "..mapstr.." not found!")
		return false
	end
	local tmap = love.filesystem.read( mapstr )
	
	self.rawMap = JSON:decode(tmap)
	
	-- convenience helpers that pull from rawMap
	self.map = {}
	self.coinmap = {}
	
	--@WARNING: feeding globals, should be undone eventually
	mapwidth = self.rawMap.width
	mapheight = self.rawMap.height
	
	-- the game doesn't understand the rawmap so for now we forward properties as necessary
	self.map.width = self.rawMap.width
	self.map.height = self.rawMap.height
	
	-- unknown globals
	self.unstatics = {} --???
	self.spritebatchX = {}
	self.spritebatchY = {}
	
	-- load properties into ourself
	for k,v in pairs(self.rawMap.properties) do
		self[k] = v
	end
	
	-- commented out to focus on junk, this is meant to queue the assets
	--[[for k,v in pairs(self.rawMap.tilesets) do
		-- iterate through all the potential tilesets and act accordingly
		if _G[v.name.."img"] then
			newBatch(v.name, _G[v.name.."img"])
		else
			print("WARNING: Tried to load spritebatch for nonexistant image: ", v.name)
		end
	end]]
	
	-- load the map data up from layers 1 and 2
	for x=1, self.map.width do
		self.map[x] = {}
		self.coinmap[x] = {}
		if not self.world.animatedtimers[x] then
			self.world.animatedtimers[x] = {}
		end
		for y=1, self.map.height do
			local dex = (y-1)*self.map.width+x --plus 1
			self.map[x][y] = {
				self.rawMap.layers[1].data[dex],
				gels = {},
				portaloverride = {}
			}
			--@TODO: Make the get property thing easier. This was behind "createobjects" but that disappeared.
			if tilequads[self.rawMap.layers[1].data[dex]]:getproperty("collision") then
				--self.objects.tile[x .. "-" .. y] = tile:new(x-1, y-1) --@WARNING: PROBABLY BROKEN
			end
			if self.rawMap.layers[2].data[dex] > 0 then
				self.coinmap[x][y] = true --@TODO: or the value above, when supported
			end
			--[[@NOTE: Due to the above we don't need the following:
			if tilequads[r[1] ]:getproperty("coin", x, y) then
				coinmap[x][y] = true
			end
			]]
			
			--[[@NOTE: ignore animated timers for now
			if r[1] > 10000 then
				if tilequads[ r[1] ].triggered then
					animatedtimers[x][y] = animatedtimer:new(x, y, r[1])
				end
			end
			]]
		end
	end
	
	if self.rawMap.layers[3] then --entities
		self:spawnOnMapLayer(self.rawMap.layers[3].objects)
	end
	
	if self.rawMap.layers[4] then --enemies
		self:spawnOnMapLayer(self.rawMap.layers[4].objects)
	end
	
	-- should this be sorted by period instead of position, I'm confused
	--[[
	animatedtimers = {}
	for x = 1, mapwidth do
		animatedtimers[x] = {}
	end
	]]
	
	-- LINK ALL OBJECTS [might be redundant]
	if self.dostart then
		for i, v in pairs(self.objects) do
			for j, w in pairs(v) do
				if w.link then
					w:link()
				end
			end
		end
	end
	
	--[[@NOTE: Commenting out because I'm not sure what this all does.
	if flagx then
		flagimgx = flagx+8/16
		flagimgy = flagy-10+1/16
	end
	]]
	
	--[[@NOTE: This seems to populate an empty map & make tile objects.
	for x = 0, -30, -1 do
		map[x] = {}
		for y = 1, mapheight-2 do
			map[x][y] = {1}
		end
		
		for y = mapheight-1, mapheight do
			map[x][y] = {2}
			if createobjects then
				objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
			end
		end
	end
	]]
	
	--[[@NOTE: Property loading, handled elsewhere.
	
	--background
	background = {unpack(backgroundcolor[1])}
	custombackground = false
	
	--portalgun
	portalsavailable = {true, true}
	
	levelscreenback = nil
	levelscreenbackname = nil
	
	--MORE STUFF
	for i = 3, #s2 do
		s3 = s2[i]:split(EQUALSIGN)
		if s3[1] == "backgroundr" then
			background[1] = tonumber(s3[2])
		elseif s3[1] == "backgroundg" then
			background[2] = tonumber(s3[2])
		elseif s3[1] == "backgroundb" then
			background[3] = tonumber(s3[2])
		elseif s3[1] == "background" then
			background = {unpack(backgroundcolor[tonumber(s3[2])])}
		elseif s3[1] == "spriteset" then
			spriteset = tonumber(s3[2])
		elseif s3[1] == "intermission" then
			intermission = true
		elseif s3[1] == "haswarpzone" then
			haswarpzone = true
		elseif s3[1] == "underwater" then
			underwater = true
		elseif s3[1] == "music" then
			if tonumber(s3[2]) then
				local i = tonumber(s3[2])
				musicname = musiclist[i]
			else
				musicname = s3[2]
			end
		elseif s3[1] == "bonusstage" then
			bonusstage = true
		elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
			custombackground = true
			if s3[2] and custombackgroundimg[ s3[2] ] then
				custombackground = s3[2]
			end
		elseif s3[1] == "customforeground" then
			customforeground = true
			if s3[2] and custombackgroundimg[ s3[2] ] then
				customforeground = s3[2]
			end
		elseif s3[1] == "timelimit" then
			mariotimelimit = tonumber(s3[2])
		elseif s3[1] == "scrollfactor" then
			scrollfactor = tonumber(s3[2])
		elseif s3[1] == "fscrollfactor" then
			fscrollfactor = tonumber(s3[2])
		elseif s3[1] == "portalgun" then
			if s3[2] == "none" then
				portalsavailable = {false, false}
			elseif s3[2] == "blue" then
				portalsavailable = {true, false}
			elseif s3[2] == "orange" then
				portalsavailable = {false, true}
			end
		elseif s3[1] == "levelscreenback" then
			if love.filesystem.exists("mappacks/" .. mappack .. "/levelscreens/" .. s3[2] .. ".png") then
				levelscreenbackname = s3[2]
				levelscreenback = {}
				levelscreenback = love.graphics.newImage("mappacks/" .. mappack .. "/levelscreens/" .. s3[2] .. ".png")
			end
		end
	end
	]]
	return true --nothing bad happened
end

function dmap:zdummyMap()
	self.background = {unpack(backgroundcolor[1])}
	self.map = {}
	self.coinmap = {}
	self.map.height = 15
	self.map.width = 25
	self.portalsavailable = {true, true}
	self.music = "overworld.ogg"
	for x = 1, self.map.width do
		self.map[x] = {}
		self.coinmap[x] = {}
		for y = 1, self.map.height do
			if y > 13 then
				self.map[x][y] = {2, gels={}, portaloverride={}}
				self.objects.tile[x .. "-" .. y] = tile:new(x-1, y-1)
			else
				self.map[x][y] = {1, gels={}, portaloverride={}}
			end
		end
	end
	
	
	--[[
	smbspritebatch = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
	smbspritebatchfront = love.graphics.newSpriteBatch( smbtilesimg, 10000 )
	portalspritebatch = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	portalspritebatchfront = love.graphics.newSpriteBatch( portaltilesimg, 10000 )
	if customtiles then
		customspritebatch = love.graphics.newSpriteBatch( customtilesimg, 10000 )
		customspritebatchfront = love.graphics.newSpriteBatch( customtilesimg, 10000 )
	end
	]]
	self.spritebatchX = {}
	self.spritebatchY = {}
end

function dmap:spawnOnMapLayer(layer)
	-- processes all the data in a layer and spawns them accordingly
	--@WARNING: For now, objects are unaware of their spawn conditions
	for k,v in pairs(layer) do
		if tonumber(v.type) ~= nil and entitylist[tonumber(v.type)] then --this is an entity
			local t = entitylist[tonumber(v.type)].t -- the name of the entity
			--print("MAPLOAD: Processing a ",t,"#",v.type)
			if t == "spawn" then
				--[[@NOTE: commenting these out because I'm not sure how they translate
				local r2 = {unpack(r)}
				table.remove(r2, 1)
				table.remove(r2, 1)
				
				--compatibility for Mari0
				if #r2 == 0 then
					startx = {x, x, x, x, x}
					starty = {y, y, y, y, y}
				else
					if r2[1] == "true" then --all
						startx = {x, x, x, x, x}
						starty = {y, y, y, y, y}
					else
						for i = 1, 5 do
							if r2[i+1] == "true" then
								startx[i] = x
								starty[i] = y
							end
						end
					end
				end
				]]
			elseif --[[createobjects and]] not editormode then
				--@TODO: Add these to our local object array in addition to the global store.
				-- All the sane entities get to play nicely here.
				if table.contains(saneents, t) then
					table.insert(self.objects[t], _G[t]:new(v.x/v.width+1, v.y/v.height+1, v.properties))
					--table.insert(textentities, textentity:new(x-1, y-1, r))
				elseif table.contains(basedents, t) then
					table.insert(self.objects[t], _G[t]:new(v.x/v.width+1, v.y/v.height+1, v.properties))
				--[[@NOTE: commented out these odd cases because they'll certainly break something
				elseif t == "warppipe" then
					table.insert(warpzonenumbers, {x, y, r[3]})
					
				elseif t == "manycoins" then
					self.map[x+1][y+1][3] = 7
					
				elseif t == "flag" then
					flagx = x-1
					flagy = y
					
				elseif t == "lakitoend" then
					lakitoendx = x
					
				elseif t == "pipespawn" and (prevsublevel == r[3]-1 or (mariosublevel == r[3]-1 and blacktime == sublevelscreentime)) then
					pipestartx = x
					pipestarty = y
					
				elseif t == "gel" then
					if tilequads[ map[x][y][1] ]:getproperty("collision", x, y) then
						if r[4] == "true" then
							map[x][y]["gels"]["left"] = r[3]
						end
						if r[5] == "true" then
							map[x][y]["gels"]["top"] = r[3]
						end
						if r[6] == "true" then
							map[x][y]["gels"]["right"] = r[3]
						end
						if r[7] == "true" then
							map[x][y]["gels"]["bottom"] = r[3]
						end
					end
					
				elseif t == "mazestart" then
					if not table.contains(mazestarts, x) then
						table.insert(mazestarts, x)
					end
					
				elseif t == "mazeend" then
					if not table.contains(mazeends, x) then
						table.insert(mazeends, x)
					end
				]]
				end
			end
		elseif enemiesdata[v.type] then --this is an enemy
			table.insert(self.objects.enemy, enemy:new(v.x/v.width+1, v.y/v.height+1, v.type, v.properties))
		else
			print("WARNING: Unknown entity ID ", v.type, "at", v.x/16, ",", v.y/16)
		end
	end
end

-- stuff to junk around with the world
function dmap:inmap(x, y)
	if not x or not y then
		return false
	end
	if x >= 1 and x <= self.map.width and y >= 1 and y <= self.map.height then
		return true
	else
		return false
	end
end

function dmap:spawnEnemy(x, y) --spawn an enemy at the position specified
	print("WARNING: Using spawnenemy instead of spawning at start.")
	if not self:inmap(x, y) then
		return
	end
	
	--don't spawn when on a coinblock or breakable block
	--[[if tilequads[map[x][y][1] ]:getproperty("breakable", x, y) or tilequads[map[x][y][1] ]:getproperty("coinblock", x, y) then
		table.insert(enemiesspawned, {x, y})
		return
	end]]

	for i = 1, #self.enemiesspawned do
		if x == self.enemiesspawned[i][1] and y == self.enemiesspawned[i][2] then
			return
		end
	end
	
	--spawnrestriction
	local allowenemy = true
	for i = 1, #self.spawnrestrictions do
		if x > self.spawnrestrictions[i][1]-6 and x < self.spawnrestrictions[i][1]+6 and y > self.spawnrestrictions[i][2]-6 and y < self.spawnrestrictions[i][2]+6 then
			allowenemy = false
		end
	end
	
	local r = self.map[x][y]
	if #r > 1 then 
		local wasenemy = false
		if allowenemy and table.contains(enemies, r[2]) and not editormode then
			if not tilequads[ self.map[x][y][1] ]:getproperty("breakable", x, y) and not tilequads[ self.map[x][y][1] ]:getproperty("coinblock", x, y) then
				table.insert(self.objects.enemy, enemy:new(x, y, r[2], r))
				wasenemy = true
			end
		elseif entitylist[r[2]] then --SPECIAL HANDLERS FOR ABNORMAL ENTITIES
			local t = entitylist[r[2]].t
			if allowenemy and t == "cheepcheep" then
				if math.random(2) == 1 then
					table.insert(self.objects.enemy, enemy:new(x, y, "cheepcheepwhite", r))
				else
					table.insert(self.objects.enemy, enemy:new(x, y, "cheepcheepred", r))
				end
				wasenemy = true
				
			elseif t == "platformfall" then
				table.insert(self.objects.platform, platform:new(x, y, {0, 0, r[3]}, "fall")) --Platform fall
				
			elseif t == "platformbonus" then
				table.insert(self.objects.platform, platform:new(x, y, {0, 0, 3}, "justright"))
			end
		end
		
		table.insert(self.enemiesspawned, {x, y})
		
		if wasenemy then
			--spawn enemies in 5x1 line so they spawn as a unit and not alone.
			print("DEBUG: Spawning horde of enemies.")
			self:spawnEnemy(x-2, y)
			self:spawnEnemy(x-1, y)
			self:spawnEnemy(x+1, y)
			self:spawnEnemy(x+2, y)
		end
	end
end

function dmap:getTile(x, y, portalable, portalcheck, facing, ignoregrates, dir)
	--returns masktable value of block (As well as the ID itself as second return parameter)
	-- also includes a portalcheck and returns false if a portal is on that spot.
	if portalcheck then
		for i, v in pairs(self.objects.portal) do
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					return false
				end
			end
		
			if v.x2 ~= false then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					return false
				end
			end
		end
	end
	
	--@TODO: Make a general lookup so that entities can occupy/reserve tiles
	--check for tubes
	for i, v in pairs(self.objects.geldispenser) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(self.objects.cubedispenser) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	--bonusstage thing for keeping it from fucking up by allowing portals to be shot next to the vine in 4-2_2 for example
	if self.bonusstage then
		if y == self.map.height and (x == 4 or x == 6) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if x <= 0 or y <= 0 or y >= self.map.height+1 or x > self.map.width then
		return false, 1
	end
	
	if self:getTilePropertyAt(x, y, "invisible") then
		return false
	end
	
	if portalcheck then
		local side
		if facing == "up" then
			side = "top"
		elseif facing == "right" then
			side = "right"
		elseif facing == "down" then
			side = "bottom"
		elseif facing == "left" then
			side = "left"
		end
		local conditions = {
			not_mirror = not self:getTilePropertyAt(x, y, "mirror"),
			collision = self:getTilePropertyAt(x, y, "collision"),
			portalable = self:getTilePropertyAt(x, y, "portalable"),
			not_grate = not self:getTilePropertyAt(x, y, "grate"), --not a fan of grates either
		}
		-- this is used for named condition checks so there's no ambiguity
		if self.map[x][y]["gels"] and self.map[x][y]["gels"][side] then
			local gelstat = self.map[x][y]["gels"][side]
			if enum_gels[gelstat] == "black" then
				conditions["portalable"] = false
			end
			if not conditions["not_mirror"] and table.contains(gelsthattarnishmirrors, enum_gels[gelstat]) then
				conditions["portalable"] = false
			end
			if not conditions["portalable"] and enum_gels[gelstat] == "white" then
				conditions["portalable"] = true
				conditions["not_mirror"] = true
			end
		end
		
		
		--To stop people from portalling under the vine, which caused problems, but was fixed elsewhere (and betterer)
		--[[for i, v in pairs(objects["vine"]) do
			if x == v.cox and y == v.coy and side == "top" then
				return false, 1
			end
		end--]]
		
		if self.map[x][y]["portaloverride"][side] then
			return true, self.map[x][y][1]
		end
		
		-- if anything in the conditions table is false, then it's a no-go and we give a false
		return (not table.contains(conditions, false)) or conditions["not_mirror"], self.map[x][y][1]
	else
		if ignoregrates then
			return self:getTilePropertyAt(x, y, "collision") and self:getTilePropertyAt(x, y, "grate") == false, self.map[x][y][1]
		else
			return self:getTilePropertyAt(x, y, "collision"), self.map[x][y][1]
		end
	end
end

function dmap:getTilePropertyAt(x, y, property)
	return tilequads[self.map[x][y][1]]:getproperty(property)
end

function dmap:update(dt)
	-- Update sprite's coordinates
	local sprite = self.imap.layers["objs"].objects.player[1]
	local down = love.keyboard.isDown

	local x, y = 0, 0
	local forcemult = 3200
	if down("w") or down("up")		then y = y - forcemult end
	if down("s") or down("down")	then y = y + forcemult end
	if down("a") or down("left")	then x = x - forcemult end
	if down("d") or down("right")	then x = x + forcemult end
	sprite.body:applyForce(x, y)
	
	
	game.probes.items.updates:pushEvent("physics")
	--physicsupdate(self.objects, dt)
	game.probes.items.updates:popEvent("physics")
	
	game.probes.items.updates:pushEvent("imap")
	self.imap:update(dt)
	game.probes.items.updates:popEvent("imap")
end
function dmap:debugDraw()
	love.graphics.setLineWidth(1)
	love.graphics.setPointSize(5)
	love.graphics.setPointStyle("rough")
	
	local sprite = self.imap.layers["objs"].objects.player[1]
	local points = {sprite.body:getWorldPoints(sprite.shape:getPoints())}
	love.graphics.polygon("line", points)
	
	love.graphics.setColor(0,0,255)
	for i=1,#points,2 do
		love.graphics.point(points[i], points[i+1])
	end
	love.graphics.setColor(255,0,255)
	love.graphics.point(sprite.body:getWorldCenter())
	love.graphics.setColor(0,255,0)
	love.graphics.point(sprite.body:getPosition())
end
function dmap:draw(scalex, scaley)
	--@DEBUG: set to anything smaller than the default scale in order to look for draws escaping the map draw
	self.imap:draw()
	
	-- Draw sprite in centre of screen
	--love.graphics.push()
	--tx = -pt.p1.x*16 --math.floor(-math.fmod(pt.p1.x, 1)*16*scale)
	--ty = pt.p1.y*16-height*16 --math.floor(-math.fmod(pt.p1.y, 1)*16*scale)
	--print(tx, ty)
	--love.graphics.translate(tx, ty)
	--self.imap:setDrawRange(tx, ty, width*scale*16, height*scale*16)
	
	--love.graphics.pop()
	--scalex = scalex or 3
	--scaley = scaley or 3
	--self.imap:setDrawRange(120, 1, love.graphics.getWidth()/4, love.graphics.getHeight()/4)
	--self.imap:setDrawRange(math.floor(-math.fmod(xscroll, 1)*16*scale), math.floor(-math.fmod(yscroll, 1)*16*scale), love.graphics.getWidth(), love.graphics.getHeight())
	--self.imap:draw()
end

function legaldraw(objs)
	game.probes.items.draws:pushEvent("legal_draw")
	for _, objgroup in pairs(objs) do
		for _, obj in pairs(objgroup) do
			if obj.body then
				love.graphics.setColor(255, 255, 255)
				local x, y = obj.body:getWorldCenter()
				local angle = obj.body:getAngle()
				local points = {obj.shape:getPoints()}
				local offx, offy = points[5], points[6] -- the third point is its top left
				--@WARNING: The above might not always work, consider that when moving forward
				love.graphics.draw(obj.graphic, obj.quad, x, y, angle, 1, 1, offx, offy)
			end
		end
	end
	game.probes.items.draws:popEvent("legal_draw")
end

function illegalupdate(objs, dt)
	game.probes.items.updates:pushEvent("main_update")
	for i, v in pairs(updatetable) do
		delete = {}
		
		for j, w in pairs(v) do
			if w.update and w:update(dt) then
				table.insert(delete, j)
			elseif w.autodelete then
				if w.y > mapheight+5 or w.x > mapwidth+5 or w.x < -5 or w.y < -5 then
					if w.autodeleted then
						w:autodeleted()
					end
					table.insert(delete,j)
				end
			end
		end
		
		if #delete > 0 then
			table.sort(delete, function(a,b) return a>b end)
			
			for j, w in pairs(delete) do
				table.remove(v, w)
			end
		end
	end
	game.probes.items.updates:popEvent("main_update")
end

function illegaldraw(objs)
	game.probes.items.draws:pushEvent("scene_objects")
	love.graphics.setColor(255, 255, 255)
	for j, w in pairs(objs) do
		if j ~= "tile" then
			for i, v in pairs(w) do
				if v.drawable and v.graphic and v.quad then
					love.graphics.setScissor()
					love.graphics.setColor(255, 255, 255)
					local dirscale
					
					if j == "player" then
						if (v.portalsavailable[1] or v.portalsavailable[2]) then
							if (v.pointingangle+math.pi*2 > -v.rotation+math.pi*2 and (not (v.pointingangle > -v.rotation+math.pi))) or v.pointingangle < -v.rotation-math.pi then
								dirscale = -scale
							else
								dirscale = scale
							end
						else
							if v.animationdirection == "right" then
								dirscale = scale
							else
								dirscale = -scale
							end
						end
						
						if bigmario then
							dirscale = dirscale * scalefactor
						end
					else
						if v.animationdirection == "left" then
							dirscale = -scale
						else
							dirscale = scale
						end
					end
					
					if v.mirror then
						dirscale = -dirscale
					end
					
					local horscale = scale
					if v.shot or v.upsidedown then
						horscale = -scale
					end
					
					if j == "player" and bigmario then
						horscale = horscale * scalefactor
					end
					
					if v.customscale then
						horscale = horscale * v.customscale
						dirscale = dirscale * v.customscale
					end
					
					local portal, portaly = insideportal(v.x, v.y, v.width, v.height)
					local entryX, entryY, entryfacing, exitX, exitY, exitfacing
					
					--SCISSOR FOR ENTRY
					if v.customscissor and v.portalable ~= false then
						local t = "setStencil"
						if v.invertedscissor then
							t = "setInvertedStencil"
						end
						love.graphics[t](function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end)
					end
						
					if v.moves and v.portalable ~= false then
						if not v.customscissor and portal ~= false and (v.active or v.portaloverride) then
							if portaly == 1 then
								entryX, entryY, entryfacing = portal.x1, portal.y1, portal.facing1
								exitX, exitY, exitfacing = portal.x2, portal.y2, portal.facing2
							else
								entryX, entryY, entryfacing = portal.x2, portal.y2, portal.facing2
								exitX, exitY, exitfacing = portal.x1, portal.y1, portal.facing1
							end
							
							if entryfacing == "right" then
								love.graphics.setScissor(math.floor((entryX-xscroll)*16*scale), math.floor(((entryY-3.5-yscroll)*16)*scale), 64*scale, 96*scale)
							elseif entryfacing == "left" then
								love.graphics.setScissor(math.floor((entryX-xscroll-5)*16*scale), math.floor(((entryY-4.5-yscroll)*16)*scale), 64*scale, 96*scale)
							elseif entryfacing == "up" then
								love.graphics.setScissor(math.floor((entryX-xscroll-3)*16*scale), math.floor(((entryY-5.5-yscroll)*16)*scale), 96*scale, 64*scale)
							elseif entryfacing == "down" then
								love.graphics.setScissor(math.floor((entryX-xscroll-4)*16*scale), math.floor(((entryY-0.5-yscroll)*16)*scale), 96*scale, 64*scale)
							end
						end
					end
					
					if type(v.graphic) == "table" then --the main graphic draw happenings
						for k = 1, #v.graphic do
							if v.colors[k] then
								love.graphics.setColor(v.colors[k])
							else
								love.graphics.setColor(255, 255, 255)
							end
							-- THIS PART DRAWS MARIO / ALL COLORIZABLE OBJECTS
							--love.graphics.draw(v.graphic[k], v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							love.graphics.draw(v.graphic[k], v.quad, v.x+v.offsetX, v.y+v.offsetY, v.rotation, 1, 1, v.quadcenterX, v.quadcenterY)
						end
					else
						if v.graphic and v.quad then
							--love.graphics.draw(v.graphic, v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							love.graphics.draw(v.graphic, v.quad, v.x+v.offsetX, v.y+v.offsetY, v.rotation, 1, 1, v.quadcenterX, v.quadcenterY)
						end
					end
					
					--HATS
					if v.drawhat then
						local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
						
						if offsets and #v.hats > 0 then
							local yadd = 0
							for i = 1, #v.hats do
								if v.hats[i] ~= 0 then
									if v.hats[i] == 1 then
										love.graphics.setColor(v.colors[1])
									else
										love.graphics.setColor(255, 255, 255)
									end
									if v.graphic == v.biggraphic or v.animationstate == "grow" then
										love.graphics.draw(v.graphic[k], v.quad, v.x*16+v.offsetX, v.y*16+v.offsetY, v.rotation, 1, 1, v.quadcenterX, v.quadcenterY)
										--love.graphics.draw(bighat[v.hats[i]].graphic, v.x*16+v.offsetX, v.y*16+v.offsetY, v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
										--love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
										yadd = yadd + bighat[v.hats[i]].height
									else
										--love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
										love.graphics.draw(hat[v.hats[i]].graphic, v.x*16+v.offsetX, v.y*16+v.offsetY, v.rotation, 1, 1, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
										yadd = yadd + hat[v.hats[i]].height
									end
								end
							end
						end
						love.graphics.setColor(255, 255, 255)
					end
					
					-- THIS CHUNKY BIT IS FOR DRAWING THE PORTAL GUN ITSELF
					--@TODO: export to portal gun drawing stuff
					if type(v.graphic) == "table" then
						if v.graphic[0] then
							love.graphics.setColor(255, 255, 255)
							love.graphics.draw(v.graphic[0], v.quad, v.x*16+v.offsetX, v.y*16+v.offsetY, v.rotation, 1, 1, v.quadcenterX, v.quadcenterY)
						end
						if v.graphic.dot then
							love.graphics.setColor(unpack(v["portal" .. (v.lastportal or 1) .. "color"]))
							love.graphics.draw(v.graphic["dot"], v.quad, v.x*16+v.offsetX, v.y*16+v.offsetY, v.rotation, 1, 1, v.quadcenterX, v.quadcenterY)
						end	
					end
					
					--portal duplication
					if v.customscissor and v.portalable ~= false then
						local t = "setStencil"
						if v.invertedscissor then
							t = "setInvertedStencil"
						end
						love.graphics[t](function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end)
					end
					
					if v.moves and (v.active or v.portaloverride) and v.portalable ~= false then
						if not v.customscissor and portal ~= false then
							--love.graphics.setScissor(unpack(currentscissor))
							local px, py, pw, ph, pr, pad = v.x, v.y, v.width, v.height, v.rotation, v.animationdirection
							px, py, d, d, pr, pad = portalcoords(px, py, 0, 0, pw, ph, pr, pad, entryX, entryY, entryfacing, exitX, exitY, exitfacing)
							
							if pad ~= v.animationdirection then
								dirscale = -dirscale
							end
							
							horscale = scale
							if v.shot or v.upsidedown then
								horscale = -scale
							end
							
							if exitfacing == "right" then
								love.graphics.setScissor(math.floor((exitX-xscroll)*16*scale), math.floor(((exitY-yscroll-3.5)*16)*scale), 64*scale, 96*scale)
							elseif exitfacing == "left" then
								love.graphics.setScissor(math.floor((exitX-xscroll-5)*16*scale), math.floor(((exitY-yscroll-4.5)*16)*scale), 64*scale, 96*scale)
							elseif exitfacing == "up" then
								love.graphics.setScissor(math.floor((exitX-xscroll-3)*16*scale), math.floor(((exitY-yscroll-5.5)*16)*scale), 96*scale, 64*scale)
							elseif exitfacing == "down" then
								love.graphics.setScissor(math.floor((exitX-xscroll-4)*16*scale), math.floor(((exitY-yscroll-0.5)*16)*scale), 96*scale, 64*scale)
							end
							
							if type(v.graphic) == "table" then
								for k = 1, #v.graphic do
									if v.colors[k] then
										love.graphics.setColor(v.colors[k])
									else
										love.graphics.setColor(255, 255, 255)
									end
									love.graphics.draw(v.graphic[k], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
								end
							else
								love.graphics.draw(v.graphic, v.quad, math.ceil(((px-xscroll)*16+v.offsetX)*scale), math.ceil(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
							end
							
							--HAAAATS
							if v.drawhat then
								local offsets = gethatoffset(v.char, v.graphic, v.animationstate, v.runframe, v.jumpframe, v.climbframe, v.swimframe, v.underwater, v.infunnel, v.fireanimationtimer, v.ducking)
						
								if offsets and #v.hats > 0 then
									local yadd = 0
									for i = 1, #v.hats do
										if v.hats[i] ~= 0 then
											if v.hats[i] == 1 then
												love.graphics.setColor(v.colors[1])
											else
												love.graphics.setColor(255, 255, 255)
											end
											if v.graphic == v.biggraphic or v.animationstate == "grow" then
												love.graphics.draw(bighat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[v.hats[i]].x + offsets[1], v.quadcenterY - bighat[v.hats[i]].y + offsets[2] + yadd)
												yadd = yadd + bighat[v.hats[i]].height
											else
												love.graphics.draw(hat[v.hats[i]].graphic, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[v.hats[i]].x + offsets[1], v.quadcenterY - hat[v.hats[i]].y + offsets[2] + yadd)
												yadd = yadd + hat[v.hats[i]].height
											end
										end
									end
								end
							end
							
							if type(v.graphic) == "table" then
								if v.graphic[0] then
									love.graphics.setColor(255, 255, 255)
									love.graphics.draw(v.graphic[0], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
								end
								if v.graphic.dot and v.lastportal then
									love.graphics.setColor(unpack(v["portal" .. v.lastportal .. "color"]))
									love.graphics.draw(v.graphic["dot"], v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
								end
							end
						end
					end
					--love.graphics.setScissor(unpack(currentscissor))
					love.graphics.setStencil()
				end
			end
		end
	end
	game.probes.items.draws:popEvent("scene_objects")
end

-- PORTAL SPECIFIC OBJECT MANIPULATION CODE
