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
	
	-- PROPERTIES THAT WERE RE-DELEGATED TO US FROM DMAP
	self.everyonedead = false
	--[[
		levelfinish* should be per-map, however, until that is handled properly, it's here to cope
	]]
	self.levelfinished = false
	self.levelfinishtype = nil
	self.coinanimation = 1
	self.redcoinanimation = 1
	self.flyingfishdelay = 1
	self.bulletbilldelay = 1
	self.firedelay = math.random(4)
	self.windtimer = 0.1
	self.firetimer = firedelay
	self.flyingfishtimer = flyingfishdelay
	self.bulletbilltimer = bulletbilldelay
	--self.gelcannontimer = 0 --disabled because it is managed by the weapon
	--self.pausemenuselected = 1 --disabled because it shouldn't be here
	self.pswitchactive = {blue = false, grey = false}
	self.pswitchtimers = {blue = 0, grey = 0}
	self.givemestuff = {lives = 0, times = 0, coinage = 0}
	
	--[[@NOTE: Commented out to force refactoring the relevant code into the player's weapon.
	self.portaldelay = {}
	for i = 1, players do
		self.portaldelay[i] = 0
	end
	]]
	
	-- MAP DATA / PROPERTIES
	self.maps = {} --array of dmaps, keyed by their name
	self.currentMap = nil
	self.currentMapName = mapName --set by loadMap, reference to maps array
	
	self.timelimit = 400 --@MAGIC: default time limit
	
	self.customtiles = false
	
	self.preCacheData = {} --this is stubbed for the purpose of only loading what's necessary
	
	self.animatedtimers = {}
	
	if mapName then
		self:openMap(mapName)
	end
	
	-- engine stuff
	self.orphanage = {} --objects that belonged to a map but are in transit or have been abandoned
	
	-- GAME FLAGS
	self.time = self.timelimit
	
	self.lowtime = 99 --when the time gets to this, play the jingle
	self.timescale = 2.5 --for use with converting magic nintendo units into real people time
end

function world:start()
	-- begin processing world state
	self:playmusic()
	self.currentMap:start()
end

function world:openMap(mapName)
	self.maps[mapName] = dmap:new(mapName, self)
	return self:switchToMap(mapName) --@DEV: temporary workaround b/c we can only handle a single map atm
end

function world:switchToMap(mapName)
	self.currentMapName = mapName
	self.currentMap = self.maps[mapName]
	return self.currentMap
end

world.getMap = world.switchToMap --aliasing until proper behavior written

--[[function world:getMap(mapName)
	-- get (and switch to) the specified map, or the current map
	-- returns false if supplied a mapname that isn't loaded
	local tmapName = mapName or self.currentMap
	if mapName and not self.maps[mapName] then
		return false
	else
		return self:switchToMap(tmapName)
	end
end]]

world.getMapOrOpen = world.openMap

--[[function world:getMapOrOpen(mapName)
	-- this is here as a helper, so that in the future, we can overload it to
	-- queue a map to open in some weird state
	
	if not self:getMap(mapName) then
		return self:openMap(mapName)
	else
		return self:getMap(mapName)
	end
end]]

function world:levelscreen_load(reason, unknown)
	-- unavoidable globals
	help_tipi = math.random(1,#help_tips)
	
	--check if lives left
	local livesleft = false
	if self.startinglives > 0 then
		for k,v in pairs(self.maps) do
			if v.state == "spawn" then
				for k2,v2 in pairs(v.objects.player) do
					if v2.lives > 0 then
						livesleft = true
						break
					end
				end
				if livesleft then break end
			else
				--@WARNING: This will fail if ANY maps haven't been started.
				print("WARNING: Levelscreen tried to process player live count, but no players existed.")
				livesleft = true
				break
			end
		end
	end
	
	--local blacktime --eventually we gotta localize this to something, but to what
	if reason == "sublevel" or reason == "vine" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		--sublevelscreen_level = i --commented out because I dunno what it does
	elseif livesleft then
		gamestate = "levelscreen"
		blacktime = levelscreentime
		if reason == "next" then --next level
			--@TODO: clear current map(s) and transition players
			
			--check if next level doesn't exist
			--[[if not love.filesystem.exists("mappacks/" .. mappack .. "/" .. w.gworld .. "-" .. w.glevel .. ".txt") then
				gamestate = "mappackfinished"
				blacktime = gameovertime
				music:play("princessmusic.ogg")
			end]]
		end
	else
		gamestate = "gameover"
		blacktime = gameovertime
		playsound("gameover") --no players loaded at this point, allowed global
	end
	
	if editormode or true then --@DEV: doing stuff for reasons
		blacktime = 0
	end
	
	if reason ~= "initial" then
		updatesizes()
	end
	
	if reason == "initial" then
		blacktime = blacktime * 1.5
	end
	
	--love.graphics.setBackgroundColor(0, 0, 0)
	levelscreentimer = 0
	
	--reached worlds -- should be in dmap
	--[[if not reachedworlds[mappack] then
		reachedworlds[mappack] = {}
	end
	
	if not reachedworlds[mappack][self.currentMapName] then
		reachedworlds[mappack][self.currentMapName] = true
		saveconfig()
	end]]
	
	--Load the level
	if gamestate == "levelscreen" then
		self:getOrOpenMap(self.mappackSets.firstmap) --@WARNING: won't load next levels properly
	elseif gamestate == "sublevelscreen" then
		--loadlevel(sublevelscreen_level)
	end
	
	if skiplevelscreen and gamestate ~= "gameover" and gamestate ~= "mappackfinished" then
		self:getMap():start(gamestate == "levelscreen")
	end
end

--[[@NOTE: functions for tile-wise operations and junk to duplicate
	* tilequads[ map[x][y][1] ]:getProperty
	
]]

function world:draw_earthquake()
	if self.earthquake > 0 and #objects["rainboom"] > 0 then
		for i = 1, rainboom.effectstripes do
			local r, g, b = unpack(rainboom.colortable[math.mod(i-1, 6)+1])
			local a = earthquake/rainboom.effectearthquake*255
			
			love.graphics.setColor(r, g, b, a)
			
			local alpha = math.rad((i/rainboom.effectstripes + math.mod(sunrot/5, 1)) * 360)
			local point1 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
			
			local alpha = math.rad(((i+1)/rainboom.effectstripes + math.mod(sunrot/5, 1)) * 360)
			local point2 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
			
			love.graphics.polygon("fill", width*8*scale, 112*scale, point1[1], point1[2], point2[1], point2[2])
		end
	end
	
	love.graphics.setColor(255, 255, 255, 255)
	--tremoooor!
	if self.earthquake > 0 then
		tremorx = (math.random()-.5)*2*earthquake
		tremory = (math.random()-.5)*2*earthquake
		
		love.graphics.translate(round(tremorx), round(tremory))
	end
end

function world:draw() --some things belong to the world, others the game
	love.graphics.setBackgroundColor(self.backgroundcolor)
	
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


-- Why is music scoped to world? Because the game.lua is too big and we have no client object.
function world:playmusic(song)
	local musicname = song or self.currentMap.music
	if self.currentMap.music then
		if self.time <= self.lowtime and self.time > 0 then
			music:play(musicname, true)
		else
			music:play(musicname)
		end
	end
end

function world:stopmusic(song)
	local musicname = song or self.currentMap.music
	if self.currentMap.timelimit then
		if self.time <= self.lowtime and self.time > 0 then
			music:stop(musicname, true)
		else
			music:stop(musicname)
		end
	end
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