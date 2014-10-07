animation = class("animation")

--[[ TRIGGERS:
mapload								when the map is loaded
timepassed:time						when <time> ms have passed
playerxgreater:x					when a player's x is greater than x
playerxless:x						when a player's x is less than x
playerygreater:x					when a player's y is greater than y
playeryless:x						when a player's y is less than y
animationtrigger:i					when animationtrigger with ID i is triggered
--]]

--[[ CONDITIONS:
noprevsublevel						doesn't if the level was changed from another sublevel (Mario goes through pipe, lands in 1-1_1, prevsublevel was _0, no trigger.)
worldequals:i						only triggers if current world is i
levelequals:i						only triggers if current level is i
sublevelequals:i					only triggers if current sublevel is i
requirecoins:i						requires i coins to trigger (will not remove coins)
--]]

--[[ ACTIONS:
disablecontrols[:player]			disables player input and hides the portal line
enablecontrols[:player]				enables player input and shows portal line
sleep:time							waits for <time> secs
setcamerax:x						sets the camera xscroll to <x>
setcameray:y						sets the camera yscroll to <y>
pancameratox:x:time					pans the camera horizontally over <time> secs to <x>
pancameratoy:y:time					pans the camera vertically over <time> secs to <y>
disablescroll						disables autoscroll
enablescroll						enables autoscroll
setx[:player]:x						sets the x-position of player(s)
sety[:player]:y						sets the y-position of player(s)
playerwalk[:player]:direction		makes players walk into the given <direction>
playeranimationstop[:player]		stops whatever animation the player is in
disableanimation					disables this animation from triggering
enableanimation						enables this animation to trigger
playerjump[:player]					makes players jump (as high as possible)
playerstopjump[:player]				makes players abort the jump (for small jumps)
dialogbox:text[:speaker]			creates a dialogbox with <text> and <speaker>
removedialogbox						removes the dialogbox
playmusic:i							plays music <i>
screenshake:power					makes the screen shake with <power>
addcoins:coins						adds <coins> coins
addpoints:points					adds <points> points
changebackgroundcolor:r:g:b			changes background color ro rgb
killplayer[:player]					kills player(s)
changetime:time						changes the time left to <time>
loadlevel:world:level:sublevel		starts level <world>-<level>_<sublevel>
disableplayeraim:player				disables mouse or joystick aiming for <player>
enableplayeraim:player				enables mouse or joystick aiming for <player>
closeportals[:player]				closes portals for <player>
makeplayerlook:player:angle			makes players aim in direction of <angle>, starting at right and going CCW, should probably be used in connection with "disableplayeraim" because it's just once
makeplayerfireportal:player:i		makes a player shoot one of their portal
enableportalgun:player				enable portal gun of player
disableportalgun:player				disable portal gun of player
--]]

function animation:init(path, name)
	self.filepath = path
	self.name = name
	self.raw = love.filesystem.read(self.filepath)
	
	self:decode(self.raw)
	
	self.firstupdate = true
	self.running = false
	self.sleep = 0
	self.enabled = true
end

function animation:decode(s)
	self.triggers = {}
	self.conditions = {}
	self.actions = {}
	
	local animationjson = JSON:decode(s)

	for i, v in pairs(animationjson.triggers) do
		self:addtrigger(v)
	end
	
	for i, v in pairs(animationjson.conditions) do
		self:addcondition(v)
	end
	
	for i, v in pairs(animationjson.actions) do
		self:addaction(v)
	end
end

function animation:addtrigger(v)
	table.insert(self.triggers, {unpack(v)})
	if v[1] == "mapload" then
		
	elseif v[1] == "timepassed" then
		self.timer = 0
	elseif v[1] == "playerx" then
	
	elseif v[1] == "animationtrigger" then
		if not animationtriggerfuncs[v[2] ] then
			animationtriggerfuncs[v[2] ] = {}
		end
		table.insert(animationtriggerfuncs[v[2] ], self)
	end
end

function animation:addcondition(v)
	table.insert(self.conditions, {unpack(v)})
end

function animation:addaction(v)
	table.insert(self.actions, {unpack(v)})
end

function animation:update(dt)
	--check my triggers for triggering, yo
	for i, v in pairs(self.triggers) do
		if v[1] == "mapload" then
			if self.firstupdate then
				self:trigger()
			end
		elseif v[1] == "timepassed" then
			self.timer = self.timer + dt
			if self.timer >= tonumber(v[2]) and self.timer - dt < tonumber(v[2]) then
				self:trigger()
			end
		elseif v[1] == "playerxgreater" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].x+objects["player"][i].width/2 > tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
		elseif v[1] == "playerxless" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].x+objects["player"][i].width/2 < tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
			
		elseif v[1] == "playerygreater" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].y+objects["player"][i].height/2 > tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
		elseif v[1] == "playeryless" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].y+objects["player"][i].height/2 < tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
		end
	end
	
	self.firstupdate = false
	
	if self.running then
		if self.sleep > 0 then
			self.sleep = math.max(0, self.sleep - dt)
		end
		
		while self.sleep == 0 and self.currentaction <= #self.actions do
			local v = self.actions[self.currentaction]
			if v[1] == "disablecontrols" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][1].controlsenabled = false
					end
				else
					local p = objects["player"][tonumber(string.sub(v[2], -1))]
					if p then
						p.controlsenabled = false
					end
				end
			elseif v[1] == "enablecontrols" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][1].controlsenabled = true
					end
				else
					local p = objects["player"][tonumber(string.sub(v[2], -1))]
					if p then
						p.controlsenabled = true
					end
				end
			elseif v[1] == "sleep" then
				self.sleep = tonumber(v[2])
			elseif v[1] == "setcamerax" then
				xscroll = tonumber(v[2])
			elseif v[1] == "pancameratox" then
				autoscroll = false
				cameraxpan(tonumber(v[2]), tonumber(v[3]))
			elseif v[1] == "pancameratoy" then
				autoscroll = false
				cameraypan(tonumber(v[2]), tonumber(v[3]))
			elseif v[1] == "disablescroll" then
				autoscroll = false
			elseif v[1] == "enablescroll" then
				autoscroll = true
			elseif v[1] == "setx" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].x = tonumber(v[3])
					end
				else
					if objects["player"][tonumber(string.sub(v[3], -1))] then
						objects["player"][tonumber(string.sub(v[3], -1))].x = tonumber(v[4])
					end
				end
			elseif v[1] == "sety" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].y = tonumber(v[3])
					end
				else
					if objects["player"][tonumber(string.sub(v[3], -1))] then
						objects["player"][tonumber(string.sub(v[3], -1))].y = tonumber(v[4])
					end
				end
			elseif v[1] == "playerwalk" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:animationwalk(v[3])
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:animationwalk(v[3])
					end
				end
			elseif v[1] == "playeranimationstop" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:stopanimation()
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:stopanimation()
					end
				end
			elseif v[1] == "disableanimation" then
				self.enabled = false
			elseif v[1] == "enableanimation" then
				self.enabled = true
			elseif v[1] == "playerjump" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:jump(true)
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:jump(true)
					end
				end
			elseif v[1] == "playerstopjump" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:stopjump(true)
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:stopjump()
					end
				end
			elseif v[1] == "dialogbox" then
				createdialogbox(v[2], v[3])
			elseif v[1] == "removedialogbox" then
				dialogboxes = {}
			
			elseif v[1] == "playmusic" then
				love.audio.stop()
				if v[2] then
					if musicname then
						music:stop(musicname)
					end
					musicname = v[2]
					playmusic()
				end
			elseif v[1] == "screenshake" then
				earthquake = tonumber(v[2]) or 1
			elseif v[1] == "addcoins" then
				collectcoin(nil, nil, tonumber(v[2]) or 1)
			elseif v[1] == "addpoints" then
				addpoints(tonumber(v[2]) or 1)
			elseif v[1] == "changebackgroundcolor" then
				love.graphics.setBackgroundColor(tonumber(v[2]) or 255, tonumber(v[3]) or 255, tonumber(v[4]) or 255)
			elseif v[1] == "killplayer" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:die("script")
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:die("script")
					end
				end
			elseif v[1] == "changetime" then
				mariotime = (tonumber(v[2]) or 400)
			elseif v[1] == "loadlevel" then
				love.audio.stop()
				
				marioworld = tonumber(v[2]) or marioworld
				mariolevel = tonumber(v[3]) or mariolevel
				mariosublevel = tonumber(v[4]) or mariosublevel
				levelscreen_load("next")
				
			elseif v[1] == "disableplayeraim" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].disableaiming = true
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].disableaiming = true
					end
				end
			elseif v[1] == "enableplayeraim" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].disableaiming = false
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].disableaiming = false
					end
				end
			
			elseif v[1] == "closeportals" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:removeportals()
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:removeportals()
					end
				end
				
			elseif v[1] == "makeplayerlook" then
				local ang = math.mod(math.mod(tonumber(v[3]), 360)+360, 360)
				
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].pointingangle = math.rad(ang)-math.pi/2
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].pointingangle = math.rad(ang)-math.pi/2
					end
				end
			
			elseif v[1] == "makeplayerfireportal" then
				if tonumber(v[3]) == 1 or tonumber(v[3]) == 2 then
					if v[2] == "everyone" then
						for i = 1, players do
							local sourcex = objects["player"][i].x+6/16
							local sourcey = objects["player"][i].y+6/16
							local direction = objects["player"][i].pointingangle
							
							shootportal(i, 1, sourcex, sourcey, direction)
						end
					else
						local i = tonumber(string.sub(v[2], -1))
						
						if objects["player"][i] then
							local sourcex = objects["player"][i].x+6/16
							local sourcey = objects["player"][i].y+6/16
							local direction = objects["player"][i].pointingangle
							
							shootportal(i, 1, sourcex, sourcey, direction)
						end
					end
				end
				
			elseif v[1] == "disableportalgun" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].portalgundisabled = true
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].portalgundisabled = true
					end
				end
				
			elseif v[1] == "enableportalgun" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].portalgundisabled = false
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].portalgundisabled = false
					end
				end
			end
			
			self.currentaction = self.currentaction + 1
		end
		
		if self.currentaction > #self.actions then
			self.running = false
		end
	end
end

function animation:trigger()
	if self.enabled then
		--check conditions
		local pass = true
		
		for i, v in pairs(self.conditions) do
			if v[1] == "noprevsublevel" then
				if prevsublevel then
					pass = false
					break
				end
			elseif v[1] == "sublevelequals" then
				print(mariosublevel)
				if (v[2] == "main" and (tonumber(mariosublevel) ~= 0)) or (v[2] ~= "main" and tonumber(v[2]) ~= tonumber(mariosublevel)) then
					pass = false
					break
				end
			elseif v[1] == "levelequals" then
				if tonumber(v[2]) ~= tonumber(mariolevel) then
					pass = false
					break
				end
			elseif v[1] == "worldequals" then
				if tonumber(v[2]) ~= tonumber(marioworld) then
					pass = false
					break
				end
			elseif v[1] == "requirecoins" then
				if mariocoincount < tonumber(v[2]) then
					pass = false
					break
				end
			end
		end
		
		if pass then
			self.running = true
			self.currentaction = 1
			self.sleep = 0
		end
	end
end

function animation:draw()
	
end