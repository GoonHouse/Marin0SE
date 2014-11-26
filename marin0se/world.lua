world = class("world")
--[[
	world is meant to contain the global gamestate info that does not belong to players
	the idea is that world is supposed to be an interface for all the global functions and data
	that are getting used everywhere
	
	additionally, map info is available through this, but it is important to note that 
	we want to be able to extend this functionality such that multiple maps can be loaded
	simultaneously, but they would belong to the same world so the timer and such would be
	shared
	
	since world is a class there can be multiple worlds and by utilizing this we would have
	multiple sets of worlds loaded simultaneously
	
	all the X/Ys when it comes to map coordinates are +1 because the iterators are 0-indexed
	for the sake of the loops, I may change this at some point for (greater) consistency's sake
]]


function world:init(mapName)
	-- ABSORBED GLOBALS FROM: game_load()
	self.checkpointx = {}
	self.checkpointy = {}
	self.checkpointsub = false
	self.startinglives = 3 --was mariolivecount
	self.startingsizes = {} --was mariosizes
	for i = 1, players do
		self.startingsizes[i] = 1
	end
	self.autoscroll = true
	self.jumpitems = { "mushroom", "oneup" } --no idea what this does
	self.gworld = 1 --was marioworld
	self.glevel = 1 --was *...
	self.gsublevel = 0
	self.respawnsublevel = 0
	self.prevsublevel = 0
	self.musicname = nil --this is technically already antiquated by self.music but who knows
	
	
	
	-- settings.txt
	self.mappackSets = { --load some sane defaults
		name = "unnamed mappack",
		author = "no author",
		description = "no description",
		lives = 3,
		firstmap = "1-1",
	}
	if love.filesystem.exists("mappacks/" .. mappack .. "/settings.txt") then
		local s = love.filesystem.read( "mappacks/" .. mappack .. "/settings.txt" )
		local s1 = s:split("\n")
		for j = 1, #s1 do
			local s2 = s1[j]:split("=")
			self.mappackSets[ s2[1] ] = s2[2]
		end
	end
	
	-- PHYSICS AND THE LIKE
	self.friction = 14
	--[[significant friction values:
		14 = base friction for motionless players
		20 = friction the box 
		100 = "superfriction" for when player's run speed is above maxrunspeed
	]]
	self.friction_air_multiplier = 0
	--[[significant air friction values:
		0 = basically nothing cares about air
	]]
	self.gravity = 80 --this is aliased as "yacceleration" in the code, so be aware
	--[[significant gravity values:
		30 = player's gravity while jumping
		
	]]
	
	
	-- MAP DATA / PROPERTIES
	self.backgroundcolor = {0,0,0}
	love.graphics.setBackgroundColor(self.backgroundcolor) --@WARNING: this should go elsewhere / be a method
	
	self.spriteset = 1
	self.music = "overworld.ogg"
	self.intermission = false
	self.bonusstage = false
	self.haswarpzone = false
	self.underwater = false
	self.timelimit = 400 --@MAGIC: default time limit
	self.scrollfactor = 0
	self.fscrollfactor = 0
	self.portalgun = "both"
	
	self.custombackground = nil
	self.customforeground = nil
	self.levelscreenback = nil
	
	self.customtiles = false
	
	self.preCacheData = {} --this is stubbed for the purpose of only loading what's necessary
	
	self.rawMap = {} --this is the raw level data, not processed for convenience
	self.map = {} --this is the level that is compatible with older formats
	self.coinmap = {}
	self.animatedtimers = {}
	
	if mapName then
		self.mapName = mapName
		self:loadLevel(mapName)
	end
	
	
	-- GAME FLAGS
	self.time = self.timelimit
	
	self.lowtime = 99 --when the time gets to this, play the jingle
	self.timescale = 2.5 --for use with converting magic nintendo units into real people time
	
	-- OTHER THINGS THAT WE MANAGE
	self.objects = {}
	--self.players = objects["player"] --for now we reference the global players because that's all we know
end

function world:startLevel() --not sure what this actually does \o/
	
end

function world:loadLevel(mapName, isSublevel)
	print("inside world:loadLevel")
	collectgarbage("collect")
	love.audio.stop()
	animationsystem_load()
	
	--[[
	if replaysystem then
		for i = 1, #replaydata do
			replaytimer[i] = 0
			replayi[i] = 1
			replaychar[i] = characters.mario
		end
	end
	]]

	if isSublevel then
		self.prevsublevel = self.gsublevel
		self.gsublevel = mapName
		self.currentmap = mapName
	else
		self.gsublevel = 0
		self.prevsublevel = self.currentmap
		self.time = 400
		
		--check for checkpoint!
		if self.checkpointsub then
			self.mariosublevel = self.checkpointsub
			-- assign "checkpointsub" to something I guess? I don't know
		end
	end
	
	--MISC VARS; Misc Global Variables
	self.gameplaytype = "oddjob" --List over in variables.lua
	self.everyonedead = false
	self.levelfinished = false
	self.coinanimation = 1
	self.redcoinanimation = 1
	self.flagx = false
	self.levelfinishtype = nil
	self.firedelay = math.random(4)
	self.flyingfishdelay = 1
	self.bulletbilldelay = 1
	self.windtimer = 0.1
	self.firetimer = firedelay
	self.flyingfishtimer = flyingfishdelay
	self.bulletbilltimer = bulletbilldelay
	self.lakitoendx = false
	self.lakitoend = false
	self.noupdate = false
	xscroll = 0
	self.repeatX = 0
	self.lastrepeat = 0
	self.ylookmodifier = 0
	self.displaywarpzonetext = false
	self.mazestarts = {}
	self.mazeends = {}
	self.mazesolved = {}
	self.mazesolved[0] = true
	self.mazeinprogress = false
	self.earthquake = 0
	self.sunrot = 0
	self.gelcannontimer = 0
	self.pausemenuselected = 1
	self.coinblocktimers = {}

	self.switchtimeout = false
	self.pswitchactive = {blue = false, grey = false}
	self.pswitchtimers = {blue = 0, grey = 0}
		
	self.givemestuff = {lives = 0, times = 0, coinage = 0}
	
	self.portaldelay = {}
	for i = 1, players do
		self.portaldelay[i] = 0
	end
	
	--class tables
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
	objects = self.objects
	
	xscroll = 0
	yscroll = 0
	self.ylookmodifier = 0
	
	self.startx = {3, 3, 3, 3, 3}
	self.starty = {13, 13, 13, 13, 13}
	self.pipestartx = nil
	self.pipestarty = nil
	self.globalanimation = nil
	
	self.enemiesspawned = {}
	
	self.intermission = false
	self.haswarpzone = false
	self.underwater = false
	self.bonusstage = false
	self.custombackground = false
	self.customforeground = false
	self.mariotimelimit = 400
	self.spriteset = 1
	
	enemies_load()
	print("did load enemies")
	
	--LOAD THE MAP
	if not self:loadMap(mapName, "json") then --make one up
		self:dummyMap()
	end
	
	-- SPECIAL OBJECTS
	self.objects["screenboundary"] = {}
	self.objects["screenboundary"]["left"] = screenboundary:new(0)
	
	self.objects["screenboundary"]["right"] = screenboundary:new(mapwidth)
	
	if self.flagx then
		self.objects["screenboundary"]["flag"] = screenboundary:new(self.flagx+6/16)
	end
	
	if self.objects["axe"] and self.objects["axe"][#self.objects["axe"]] then
		self.objects["screenboundary"]["axe"] = screenboundary:new(self.objects["axe"][#self.objects["axe"]].cox)
	end
	
	if self.intermission then
		self.globalanimation = "intermission"
	end
	
	if not isSublevel then
		self.mariotime = self.mariotimelimit
	end
	
	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	if #self.mazestarts == #self.mazeends then
		self.mazegates = {}
		for i = 1, #self.mazestarts do
			local maxgate = 1
			for x = self.mazestarts[i], self.mazeends[i] do
				for y = 1, self.mapheight do
					if self.map[x][y][2] and entitylist[self.map[x][y][2]] and entitylist[self.map[x][y][2]].t == "mazegate" then
						if tonumber(self.map[x][y][3]) > maxgate then
							maxgate = tonumber(self.map[x][y][3])
						end
					end
				end
			end
			self.mazegates[i] = maxgate
		end
	else
		print("Mazenumber doesn't fit!")
	end
	
	--check if it's a bonusstage (boooooooonus!)
	if self.bonusstage then
		self.globalanimation = "vinestart"
	end
		
	--set startx to pipestart
	
	--@NOTE: Here's where we overload to set the position of pipers! Yee.
	if warpdestid then
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
			--if tilequads[map[startx[1]][starty[1]][1]]:getproperty("collision", startx[1], starty[1]) then
			--	animation = "pipeup2"
			--end
		else
			print("WARNING: Tried to take a pipe to a level that did not have corresponding destination pipe (",warpdestid,")")
		end
		--clear warpdestid because it would never get cleared otherwise
		warpdestid = nil
	end
	
	--set starts to checkpoint
	--@NOTE: I goofed with these. Don't tell anyone.
	if not isSublevel and self.checkpointsub then
		for i = 1, self.checkpointsub do
			if self.checkpointx[i] then
				self.startx[i] = self.checkpointx[i]
			end
			if self.checkpointy[i] then
				self.starty[i] = self.checkpointy[i]
			end
		end
	end
	
	--Adjust start X scroll
	xscroll = self.startx[1]-scrollingleftcomplete-2
	if xscroll > mapwidth - width then
		xscroll = mapwidth - width
	end
	
	if xscroll < 0 then
		xscroll = 0
	end
	
	--and Y too
	yscroll = self.starty[1]-height+downscrollborder
	if yscroll > mapheight - height - 1 then
		yscroll = mapheight - height - 1
	end
	
	if yscroll < 0 then
		yscroll = 0
	end
	
	self.spawnrestrictions = {}
	
	--Clear spawn area from enemies
	for i = 1, #self.startx do
		if self.startx[i] == self.checkpointx[i] and self.starty[i] == self.checkpointy[i] then
			table.insert(self.spawnrestrictions, {self.startx[i], self.starty[i]})
		end
	end
	
	--add the players
	--@NOTE: I just don't feel like messing with this.
	local mul = 0.5
	if w.gsublevel ~= 0 or self.prevsublevel ~= false then
		mul = 2/16
	end
	
	self.objects["player"] = {}
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
			
			self.objects["player"][i] = player:new(self, astartx+add, astarty-1, i, lanimation, self.startingsizes[i], playertype)
		else
			self.objects["player"][i] = player:new(self, 1.5 + (i-1)*mul-6/16+1.5, 13, i, lanimation, self.startingsizes[i], playertype)
		end
	end
	
	--ADD ENEMIES ON START SCREEN
	if editormode == false then
		local xtodo = width+1
		if mapwidth < width+1 then
			xtodo = mapwidth
		end
		
		local ytodo = height+1
		if mapheight < height+1 then
			ytodo = mapheight
		end
			
		for x = math.floor(xscroll), math.floor(xscroll)+xtodo do
			for y = math.floor(yscroll), math.floor(yscroll)+ytodo do
				self:spawnEnemy(x, y)
			end
		end
	end
	
	--load editor
	--editor_load() no editor that doesn't make sense
	
	updateranges()
	
	generatespritebatch()
	print("finished w:loadLevel without problems")
end

function world:loadMap(mapName, format)
	mapName = mapName or "1-1"
	format = format or "txt"
	
	local mapstr = "mappacks/" .. mappack .. "/" .. mapName .. "." .. format
	print("LOADING: "..mapstr)
	if love.filesystem.exists(mapstr) == false then
		print("CRITICAL: "..mapstr.." not found!")
		return false
	end
	local tmap = love.filesystem.read( mapstr )
	
	self.rawMap = JSON:decode(tmap)
	
	-- convenience helpers that pull from rawMap
	self.map = {}
	self.coinmap = {}
	
	
	-- localized for the sake of convenience
	
	-- globals to process
	mapwidth = self.rawMap.width
	mapheight = self.rawMap.height
	
	-- unknown globals
	unstatics = {} --???
	spritebatchX = {}
	spritebatchY = {}
	
	-- load properties
	for k,v in pairs(self.rawMap.properties) do
		self[k] = v
	end
	
	-- commented out to focus on junk
	--[[for k,v in pairs(self.rawMap.tilesets) do
		-- iterate through all the potential tilesets and act accordingly
		if _G[v.name.."img"] then
			newBatch(v.name, _G[v.name.."img"])
		else
			print("WARNING: Tried to load spritebatch for nonexistant image: ", v.name)
		end
	end]]
	
	-- load the map data up from layers 1 and 2
	for x=0, mapwidth-1 do
		self.map[x+1] = {}
		self.coinmap[x+1] = {}
		self.animatedtimers[x+1] = {}
		for y=0, mapheight-1 do
			local dex = y*mapwidth+x+1 --plus 1
			self.map[x+1][y+1] = {
				self.rawMap.layers[1].data[dex],
				gels = {},
				portaloverride = {}
			}
			--@TODO: Make the get property thing easier. This was behind "createobjects" but that disappeared.
			if tilequads[self.rawMap.layers[1].data[dex]]:getproperty("collision") then
				self.objects.tile[x+1 .. "-" .. y+1] = tile:new(x, y)
			end
			if self.rawMap.layers[2].data[dex] > 0 then
				self.coinmap[x+1][y+1] = true --@TODO: or the value above, when supported
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
	
	if createobjects then
		--Add links
		for i, v in pairs(objects) do
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

--[[@NOTE: functions for tile-wise operations and junk to duplicate
	* tilequads[ map[x][y][1] ]:getProperty
	
]]

function world:dummyMap()
	self.background = {unpack(backgroundcolor[1])}
	mapheight = 15
	mapwidth = 25
	self.portalsavailable = {true, true}
	self.music = "overworld.ogg"
	self.map = {}
	self.coinmap = {}
	for x = 1, width do
		self.map[x] = {}
		self.coinmap[x] = {}
		for y = 1, mapheight do
			if y > 13 then
				map[x][y] = {2}
				self.objects["tile"][x .. "-" .. y] = tile:new(x-1, y-1)
				map[x][y]["gels"] = {}
				map[x][y]["portaloverride"] = {}
			else
				map[x][y] = {1}
				map[x][y]["gels"] = {}
				map[x][y]["portaloverride"] = {}
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

function world:spawnOnMapLayer(layer)
	for k,v in pairs(layer) do
		if tonumber(v.type) ~= nil and entitylist[tonumber(v.type)] then --this is an entity
			local t = entitylist[v.type].t -- the name of the entity
			print("MAPLOAD: Processing a ",t,"#",v.type)
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
					table.insert(objects[t], _G[t]:new(v.x/v.width+1, v.y/v.height+1, v.properties))
					--table.insert(textentities, textentity:new(x-1, y-1, r))
				elseif table.contains(basedents, t) then
					table.insert(objects[t], _G[t]:new(v.x/v.width+1, v.y/v.height+1, v.properties))
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
function world:spawnEnemy(x, y) --spawn an enemy at the position specified
	if not inmap(x, y) then
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
			if not tilequads[map[x][y][1] ]:getproperty("breakable", x, y) and not tilequads[map[x][y][1] ]:getproperty("coinblock", x, y) then
				table.insert(self.objects["enemy"], enemy:new(x, y, r[2], r))
				wasenemy = true
			end
		elseif entitylist[r[2]] then
			local t = entitylist[r[2]].t
			if allowenemy and t == "cheepcheep" then
				if math.random(2) == 1 then
					table.insert(self.objects["enemy"], enemy:new(x, y, "cheepcheepwhite", r))
				else
					table.insert(self.objects["enemy"], enemy:new(x, y, "cheepcheepred", r))
				end
				wasenemy = true
				
			elseif t == "platformfall" then
				table.insert(self.objects["platform"], platform:new(x, y, {0, 0, r[3]}, "fall")) --Platform fall
				
			elseif t == "platformbonus" then
				table.insert(self.objects["platform"], platform:new(x, y, {0, 0, 3}, "justright"))
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

function world:getTile(x, y, portalable, portalcheck, facing, ignoregrates, dir)
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
	
	--check for tubes
	for i, v in pairs(objects["geldispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["cubedispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	--bonusstage thing for keeping it from fucking up by allowing portals to be shot next to the vine in 4-2_2 for example
	if bonusstage then
		if y == mapheight and (x == 4 or x == 6) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if x <= 0 or y <= 0 or y >= mapheight+1 or x > mapwidth then
		return false, 1
	end
	
	if tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
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
			not_mirror = not tilequads[map[x][y][1]]:getproperty("mirror", x, y),
			collision = tilequads[map[x][y][1]]:getproperty("collision", x, y),
			portalable = tilequads[map[x][y][1]]:getproperty("portalable", x, y),
			not_grate = not tilequads[map[x][y][1]]:getproperty("grate", x, y), --not a fan of grates either
		}
		-- this is used for named condition checks so there's no ambiguity
		if map[x][y]["gels"] and map[x][y]["gels"][side] then
			local gelstat = map[x][y]["gels"][side]
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
		
		if map[x][y]["portaloverride"][side] then
			return true, map[x][y][1]
		end
		
		-- if anything in the conditions table is false, then it's a no-go and we give a false
		return (not table.contains(conditions, false)) or conditions["not_mirror"], map[x][y][1]
	else
		if ignoregrates then
			return tilequads[map[x][y][1]]:getproperty("collision", x, y) and tilequads[map[x][y][1]]:getproperty("grate", x, y) == false, map[x][y][1]
		else
			return tilequads[map[x][y][1]]:getproperty("collision", x, y), map[x][y][1]
		end
	end
end

function world:draw() --some things belong to the world, others the game
	
	if self.earthquake > 0 then
		love.graphics.translate(-round(self.tremorx), -round(self.tremory))
	end
	
	--[[@NOTE: these should be handled by sanenets
	
	love.graphics.setColor(255, 255, 255)
	--portals
	for i, v in pairs(w.objects.portals) do
		v:draw()
	end
	
	love.graphics.setColor(255, 255, 255)
	--particles
	for j, w in pairs(self.objects.portalparticle) do
		w:draw()
	end
	
	--Portal projectile
	for i, v in pairs(self.objects.portalprojectile) do
		v:draw()
	end
	
	--COINBLOCKanimation
	love.graphics.setColor(255, 255, 255)
	for i, v in pairs(coinblockanimations) do
		love.graphics.draw(coinblockanimationimg, coinblockanimationquads[coinblockanimations[i].frame], math.floor((coinblockanimations[i].x - xscroll)*16*scale), math.floor(((coinblockanimations[i].y-yscroll)*16-8)*scale), 0, scale, scale, 4, 54)
	end
	
	for i, v in pairs(dialogboxes) do
		v:draw()
	end
	]]
end

function world:update(dt)
	--earthquake reset
	if self.earthquake > 0 then
		self.earthquake = math.max(0, self.earthquake-dt*self.earthquake*2-0.001)
		self.sunrot = self.sunrot + dt
	end
	
	--coinblocktimer things
	for i, v in pairs(self.coinblocktimers) do
		if v[3] > 0 then
			v[3] = v[3] - dt
		end
	end
	
	-- red coin animation [THIS SHOULDN'T BE HERE]
	self.redcoinanimation = self.redcoinanimation + dt*6.75
	if self.redcoinanimation >= 5 then
		self.redcoinanimation = self.redcoinanimation % 4
	end
	self.redcoinframe = math.floor(self.redcoinanimation)
	
	--blockbounce [WHY ARE THESE LIKE THIS? I DON'T KNOW]
	local delete = {}
	
	for i, v in pairs(self.blockbouncetimer) do
		if self.blockbouncetimer[i] < self.blockbouncetime then
			self.blockbouncetimer[i] = self.blockbouncetimer[i] + dt
			if self.blockbouncetimer[i] > self.blockbouncetime then
				self.blockbouncetimer[i] = self.blockbouncetime
				if self.blockbouncecontent then
					item(self.blockbouncecontent[i], self.blockbouncex[i], self.blockbouncey[i], self.blockbouncecontent2[i])
				end
				table.insert(delete, i)
			end
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(self.blockbouncetimer, v)
		table.remove(self.blockbouncex, v)
		table.remove(self.blockbouncey, v)
		table.remove(self.blockbouncecontent, v)
		table.remove(self.blockbouncecontent2, v)
	end
	
	if #delete >= 1 then
		generatespritebatch()
	end
	
	--portal update
	--[[@NOTE: this should be handled by saneents
	for i, v in pairs(portals) do
		v:update(dt)
	end
	
	-- portal particles
	delete = {}
	
	for i, v in pairs(portalparticles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalparticles, v) --remove
	end
	
	-- portal projectiles
	delete = {}
	
	for i, v in pairs(portalprojectiles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalprojectiles, v) --remove
	end
	]]
end































-- SPECIAL HELPER FUNCTIONS TO TRACK THE WORLD'S INHABITANTS
function world:isFantastic()
	return true
end

-- FILTERS
local filters = {}
filters.by_property = function(ply, property)
	return ply[property]
end
filters.genocide = function(ply, reason)
	return ply:die(reason)
end

-- FILTER WRAPPERS
function world:anyPlayersWithProperty(property)
	return filter.runAny(self.players, filters.by_property, property)
end

function world:killAllPlayers(reason)
	return filter.runAll(self.players, filters.genocide, reason)
end

function world:anyPlayersActiveAndAlive()
	return filter.multiAny("All",
		{self.players, filters.by_property, "controlsenabled"}, 
		{self.players, filters.by_property, "dead"}
	)
end