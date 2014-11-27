player = class("player")

function player:init(world, x, y, i, animation, size, t)
	print("DEBUG: Player was initialized.")
	if (SERVER or CLIENT) and i ~= netplayernumber then
		self.remote = true
	end
	
	self.world = world
	
	self.alwaysactive = true
	
	self.profile = playerprofiles[i]
	self.char = characters[self.profile.character]
	
	self.playernumber = i or 1
	if bigmario then
		self.size = 1
	else
		self.size = size or 1
	end
	--[[@WARNING:
		this is a bit of a hack but apparently every time a level transition
		happens we destroy our mario to set his position relative to the new world
		
		eventually we wanna use enemiesdata["powerup"] and register each powerup right
	]]
	
	if self.size == 1 then
		self.powerupstate = "small"
		self.powerdowntargetstate = "death"
	elseif self.size == 2 then
		self.powerupstate = "super"
		self.powerdowntargetstate = "small"
	elseif self.size == 3 then
		self.powerupstate = "fire"
		self.powerdowntargetstate = "super"
	end
	self.prefermouse = true
	self.t = t or "portalgun"
	self.activeweapon = nil
	self.weapons = {}
	--[[ { weaponname = reference } ]]
	if _G[self.t] and _G[self.t].isWeapon then
		self.weapons[self.t] = _G[self.t]:new(self)
		self.activeweapon = self.weapons[self.t]
	end
	
	self.portalsavailable = {unpack(portalsavailable)}
	local bindtable 
	if self.playernumber == 1 then
		bindtable = controlTable
		if false then
			bindtable.keys = nil
			bindtable.mouseBtns = nil
		end
	else
		bindtable = {}
	end
	self.binds, self.controls = TLbind.giveInstance(bindtable)
	self.binds.controlPressed = function(control)
		--print("wrap control press")
		self:controlPress(control, false)
	end
	self.binds.controlReleased = function(control)
		--print("wrap control release")
		self:controlRelease(control, false)
	end
	
	--PHYSICS STUFF
	self.speedx = 0
	self.speedy = 0
	self.x = x
	self.width = 12/16
	self.height = 12/16
	self.previouslyonground = true --for start falling
	
	if bigmario then
		self.width = self.width*scalefactor
		self.height = self.height*scalefactor
	end
	
	self.lastground = {0, 0}
	
	self.y = y+1-self.height
	self.moves = true
	self.active = true
	self.category = 3
	self.mask = {	true, 
					false, true, false, false, false,
					false, true, false, false, false,
					false, true, false, false, false,
					false, false, false, false, false,
					false, false, false, false, false,
					false, false, false, false, false}
					
	if playercollisions then
		self.mask[3] = false
	end
	
	self.emancipatecheck = true
	
	--IMAGE STUFF
	if self.portalsavailable[1] or self.portalsavailable[2] or not self.char.nogunanimations then
		self.smallgraphic = self.char.animations
		self.biggraphic = self.char.biganimations
	else
		self.smallgraphic = self.char.nogunanimations
		self.biggraphic = self.char.nogunbiganimations
	end
	self.outofboundstimer = 0
	self.drawable = true
	self.quad = self.char.idle[3]
	self.colors = self.profile.colors
	self.customscale = self.char.customscale
	if self.size == 1 then
		self.offsetX = self.char.smalloffsetX
		self.offsetY = self.char.smalloffsetY
		self.quadcenterX = self.char.smallquadcenterX
		self.quadcenterY = self.char.smallquadcenterY
		
		self.graphic = self.smallgraphic
	else
		self.graphic = self.biggraphic
		
		self.quadcenterY = self.char.bigquadcenterY
		self.quadcenterX = self.char.bigquadcenterX
		self.offsetY = self.char.bigoffsetY
		self.offsetX = self.char.bigoffsetX
		
		self.y = self.y - 12/16
		self.height = 24/16
		
		if self.size == 3 then
			self.colors = self.char.flowercolor or flowercolor
		end
	end
	
	if bigmario then
		self.offsetX = self.offsetX*scalefactor
		self.offsetY = self.offsetY*-scalefactor
	end
	
	--hat
	self.hats = self.profile.hats
	self.drawhat = true
	
	--Change height according to hats
	
	--for i = 1, #self.hats do
		--self.height = self.height + (hat[self.hats[i]].height/16)
		--self.y = self.y - (hat[self.hats[i]].height/16)
		--self.offsetY = self.offsetY - hat[self.hats[i]].height
	--end
	
	self.customscissor = false
	
	if players == 1 and not arcade then
		self.portal1color = {60, 188, 252}
		self.portal2color = {232, 130, 30}
	else
		self.portal1color = portalcolor[self.playernumber][1]
		self.portal2color = portalcolor[self.playernumber][2]
	end
	
	if self.portalsavailable[1] then
		self.lastportal = 1
	elseif self.portalsavailable[2] then
		self.lastportal = 2
	end
	
	--OTHER STUFF!
	self.controlsenabled = true
	
	self.runframe = self.char.runframes
	self.jumpframe = 1
	self.swimframe = 1
	self.climbframe = 1
	self.runanimationprogress = 1
	self.jumpanimationprogress = 1
	self.swimanimationprogress = 1
	self.animationstate = "idle" --idle, running, jumping, falling, swimming, sliding, climbing, dead
	self.animationdirection = "right" --left, right. duh
	self.platform = false
	-- we're redoing the combo system to be generic
	self.killstreak = 0
	self.combos = {
		stomp = 1,
		shell = 1,
	}
	
	--@DEV: Not sure why these aren't made children but y'know whatever.
	if not self.world.objects.portal[self.playernumber] then
		self.world.objects.portal[self.playernumber] = portal:new(self.playernumber, self.portal1color, self.portal2color, self)
	end
	self.portal = self.world.objects.portal[self.playernumber]
	
	self.portaldelay = 0
	
	
	self.rotation = 0 --for portals
	self.pointingangle = -math.pi/2
	self.animationdirection = "right"
	self.passivemoved = false
	self.ducking = false
	self.invincible = false
	self.rainboomallowed = true
	self.looktimer = 0
	self.raccoonstarttimer = 0
	self.raccoontimer = 0
	self.raccoonascendtimer = 0
	self.tailwagframe = 1
	self.tailwagtimer = 0
	
	-- PROJECT: LOCALIZE THEM GLOBALS
	self.coins = 0
	self.lives = 3
	self.score = 0
	
	self.gravitydirection = math.pi/2
	
	self.animation = globalanimation or false --pipedown, piperight, pipeup, flag, vine, intermission
	self.animationx = false
	self.animationy = false
	self.animationtimer = 0
	
	self.falling = false
	self.jumping = false
	self.running = false
	self.walking = false
	self.starred = false
	self.dead = false
	self.vine = false
	self.spring = false
	self.startimer = mariostarduration
	self.starblinktimer = mariostarblinkrate
	self.starcolori = 1
	self.fireballcount = 0
	self.fireanimationtimer = fireanimationtime
	
	self.mazevar = 0
	
	self.bubbletimer = 0
	self.bubbletime = bubblestime[math.random(#bubblestime)]
	
	self.underwater = underwater
	if self.underwater then
		self:dive(true)
	end
	
	if self.animation == "intermission" and editormode then
		self.animation = false
	end
	
	if mariolivecount ~= false and self.lives <= 0 then
		self.dead = true
		self.drawable = false
		self.active = false
		self.moves = false
		self.controlsenabled = false
		self.animation = false
	end
	
	if self.animation == "pipe_up_out" then
		self.controlsenabled = false
		self.active = false
		self.animationx = x
		self.animationy = y
		self.customscissor = {x-2.5, y-4, 6, 4}
		self.y = self.animationy + 20/16
		
		self.animationstate = "idle"
		self:setquad()
		
		if self.size > 1 then
			self.animationy = y - 12/16
		end
		
		if arcade and not arcadeplaying[self.playernumber] then
			self.y = self.animationy + 20/16 - pipeanimationdistancedown
			self.animation = false
		end
	elseif self.animation == "pipe_down_out" then
		self.controlsenabled = false
		self.active = false
		self.animationx = x
		self.animationy = y
		self.customscissor = {x-2.5, y-4, 6, 4}
		self.y = self.animationy + 20/16
		
		self.animationstate = "idle"
		self:setquad()
		
		if self.size > 1 then
			self.animationy = y - 12/16
		end
		
		if arcade and not arcadeplaying[self.playernumber] then
			self.y = self.animationy + 20/16 - pipeanimationdistancedown
			self.animation = false
		end
	elseif self.animation == "pipe_right_out" then
		self.controlsenabled = false
		self.active = false
		self.animationx = x-2
		self.animationy = y
		self.customscissor = {x+(6/16), y-5, 2, 6}
		--self.y = self.animationy + 20/16
		self.x = self.animationx - 28/16 --+ pipeanimationdistanceright
		--self.x = self.animationx
		
		self.animationstate = "running"
		self:setquad()
		
		if self.size > 1 then
			self.animationy = y - 12/16
		end
		
		--[[if arcade and not arcadeplaying[self.playernumber] then
			self.y = self.animationy + 20/16 - pipeanimationdistancedown
			self.animation = false
		end]]
	elseif self.animation == "pipe_left_out" then
		self.controlsenabled = false
		self.active = false
		self.animationx = x
		self.animationy = y
		self.customscissor = {x-2+(6/16), y-5, -2, 6}
		--self.y = self.animationy + 20/16
		--self.x = self.animationx + 28/16 --+ pipeanimationdistanceright
		
		self.animationstate = "running"
		self:setquad()
		
		if self.size > 1 then
			self.animationy = y - 12/16
		end
		
		--[[if arcade and not arcadeplaying[self.playernumber] then
			self.y = self.animationy + 20/16 - pipeanimationdistancedown
			self.animation = false
		end]]
	elseif self.animation == "intermission" then
		self.controlsenabled = false
		self.active = true
		self.gravity = mariogravity
		self.animationstate = "running"
		self.speedx = 2.61
		self.pointingangle = -math.pi/2
		self.animationdirection = "right"
	elseif self.animation == "vinestart" then
		self.controlsenabled = false
		self.active = false
		self.pointingangle = -math.pi/2
		self.animationdirection = "right"
		self.climbframe = 2
		self.animationstate = "climbing"
		self:setquad()
		self.x = 4-3/16
		self.y = 15+0.4*(self.playernumber-1)
		self.vineanimationclimb = false
		self.vineanimationdropoff = false
		self.vinemovetimer = 0
		
		if #objects["vine"] == 0 then
			--@DEV: Does this ever happen? Does this ever *not* happen?
			table.insert(objects["vine"], vine:new(5, 16, "start"))
		end
	end
	self:setquad()
	
	table.insert(self.world.objects.tile, tile:new(self.x, self.y+self.height+.12))
end


function player:controlPress(control, fromnetwork)
	if onlinemp and not fromnetwork then
		client_send("controlupdate", {control=control,direction="press"})
	end
	if fromnetwork then
		print("network-pressed: "..control)
		self.controls[control]=true
		self.controls.tap[control]=true
		self.controls.release[control]=true
	else
		--print("pressed: "..control)
	end
	if control=="playerJump" then
		self:jump()
	elseif control=="playerDebug" then
		playsound("shrink", 1, 1)
		killfeed.new({objects["enemy"][1],objects["enemy"][2]}, "physics", objects["enemy"][3])
		savemap2(currentmap)
		--debugbox()
		print("oh boy I'm a test")
	elseif control=="playerRun" then
		self:fire()
	elseif control=="playerReload" then
		self:removeportals()
	elseif control=="playerUse" then
		self:use()
	elseif control=="playerSuicide" then
		self:murder(self, "suicide", "Suicide")
	elseif control=="playerLeft" then
		self:leftkey()
	elseif control=="playerRight" then
		self:rightkey()
	elseif control=="playerPrimaryFire" then
		if self.activeweapon and (not editormode or testlevel) then 
			self.activeweapon:primaryFire()
		end
	elseif control=="playerSecondaryFire" then
		if self.activeweapon and (not editormode or testlevel) then 
			self.activeweapon:secondaryFire()
		end
	end
end
function player:controlRelease(control, fromnetwork)
	if onlinemp and not fromnetwork then
		client_send("controlupdate", {control=control,direction="release"})
	end
	if fromnetwork then
		print("network-released: "..control)
		self.controls[control]=false
		self.controls.tap[control]=false
		self.controls.release[control]=false
	else
		--print("released: "..control)
	end
	if control=="playerJump" then
		self:stopjump()
	end
end

function player:adddata()
	--i, x, y, cscale,     offsetX, offsetY, rotation, quadcenterX, quadcenterY, animationstate, underwater, ducking, hats, graphic, quad, pointingangle, shot, upsidedown, colors, lastportal, portal1color, portal2color)
	
	--local colors = {}
	--for i = 1, #self.colors do
	--	colors[i] = {unpack(self.colors[i])}
	--end
	
	table.insert(livereplaydata[self.playernumber], {time=love.timer.getTime()-livereplaytimer})
	
	local data = {
		x=self.x,
		y=self.y,
		offsetX=self.offsetX,
		offsetY=self.offsetY,
		rotation=self.rotation,
		quadcenterX=self.quadcenterX,
		quadcenterY=self.quadcenterY,
		animationstate=self.animationstate,
		underwater=self.underwater,
		ducking=self.ducking,
		--hats={unpack(self.hats)}, --!
		pointingangle=self.pointingangle,
		--shot=self.shot, --!
		--upsidedown=self.upsidedown, --!
		colors=self.colors, --!
		--lastportal=self.lastportal, --!
		--portal1color={unpack(self.portal1color)}, --!
		--portal2color={unpack(self.portal2color)}, --!
		runframe=self.runframe,
		jumpframe=self.jumpframe,
		climbframe=self.climbframe,
		swimframe=self.swimframe,
		fireanimationtimer=self.fireanimationtimer,
		size=self.size,
		drawable=self.drawable,
		customscissor=self.customscissor,
		world=marioworld,
		level=mariolevel,
		sublevel=mariosublevel,
		animationdirection=self.animationdirection
	}
	
	for i, v in pairs(data) do
		if livereplaystored[self.playernumber][i] == nil or livereplaystored[self.playernumber][i] ~= v then
			livereplaydata[self.playernumber][#livereplaydata[self.playernumber]][i] = v
			livereplaystored[self.playernumber][i] = v
		end
	end
end

function player:update(dt)
	if self.binds.update and self.controls and self.playernumber == 1 then
		self.binds:update()
	end
	
	if self.animationdirection == "right" and self.speedx > maxwalkspeed then --Checks for running movement
		self.running = true
		self.walking = true
	elseif self.animationdirection == "left" and self.speedx < -maxwalkspeed then
		self.running = true
		self.walking = true
	elseif self.animationdirection == "right" and self.speedx > maxwalkspeed/3 then 
		self.running = false
		self.walking = true
	elseif self.animationdirection == "left" and self.speedx < -maxwalkspeed/3 then
		self.running = false
		self.walking = true
	else
		self.running = false
		self.walking = false
	end
	
	-- this is handled in the giant objects iterable
	--[[if self.activeweapon then
		self.activeweapon:update(dt)
	end]]
	
	if replaysystem then
		livereplaydelay[self.playernumber] = livereplaydelay[self.playernumber] + dt
		while livereplaydelay[self.playernumber] >= 1/60 do
			self:adddata()
			livereplaydelay[self.playernumber] = livereplaydelay[self.playernumber] - 1/60
		end
	end
	
	self.passivemoved = false
	self.rotation = unrotate(self.rotation, self.gravitydirection, dt)
	
	--@DEV: This is probably handled by our weapon code, but just in case, here this is.
	if self.portaldelay > 0 then
		self.portaldelay = math.max(0, self.portaldelay - dt/speed)
	end
	
	--Tailwag!
	if self.char.raccoon and (self.tailwag or self.tailwagtimer > 0) then
		if self.tailwagtimer == 0 then
			self.tailwag = false
			playsound("tailwag", self.x, self.y, self.speedx, self.speedy)
		end
		self.tailwagtimer = self.tailwagtimer + dt
		while self.tailwagtimer > raccoontailwagdelay do
			self.tailwagframe = self.tailwagframe + 1
			self.tailwagtimer = self.tailwagtimer - raccoontailwagdelay
			if self.tailwagframe > 3 then
				self.tailwagframe = 1
				self.tailwagtimer = 0
			end
		end
	end
	
	--Spin!
	if self.char.raccoon and self.raccoonspinframe then
		if self.raccoonspintimer == 0 then
			playsound("tailwag", self.x, self.y, self.speedx, self.speedy)
		end
		self.raccoonspintimer = self.raccoonspintimer + dt
		while self.raccoonspintimer > raccoonspindelay and self.raccoonspinframe do
			self.raccoonspintimer = self.raccoonspintimer - raccoonspindelay
			self.raccoonspinframe = self.raccoonspinframe + 1
			if self.raccoonspinframe >= 4 then
				self.raccoonspinframe = false
			end
		end
	end
	
	if self.startimer < mariostarduration and not self.dead then
		self.startimer = self.startimer + dt
		self.starblinktimer = self.starblinktimer + dt
		
		local lmariostarblinkrate = mariostarblinkrate
		if self.startimer >= mariostarduration-mariostarrunout then
			lmariostarblinkrate = mariostarblinkrateslow
		end

		--@TODO: Refactor instances of this weirdass antipattern.
		while self.starblinktimer > lmariostarblinkrate do
			self.starcolori = self.starcolori + 1
			if self.starcolori > #self.profile.starcolors then
				self.starcolori = self.starcolori - #self.profile.starcolors
			end
			self.colors = self.profile.starcolors[self.starcolori]
			
			self.starblinktimer = self.starblinktimer - lmariostarblinkrate
		end
		
		if self.startimer >= mariostarduration-mariostarrunout and self.startimer-dt < mariostarduration-mariostarrunout then
			--check if another starman is playing
			local starstill = false
			for i = 1, players do
				if i ~= self.playernumber and self.world.objects.player[i].starred then
					starstill = true
				end
			end
			
			if not starstill and not levelfinished then
				w:stopmusic("starmusic.ogg")
				w:playmusic()
			end
		end
		
		if self.startimer >= mariostarduration then
			if self.size == 3 then --flower colors
				self.colors = self.char.flowercolor or self.profile.flowercolors
			else
				self.colors = self.char.colors or self.profile.colors
			end
			self.starred = false
			self.startimer = mariostarduration
		end
	end
	
	if self.jumping then
		if self.underwater then
			self.gravity = uwyaccelerationjumping
		else
			self.gravity = yaccelerationjumping
		end
		
		if self.speedy > 0 then
			self.jumping = false
			self.falling = true
		end
	else
		if self.underwater then
			self.gravity = uwyacceleration
		else
			self.gravity = yacceleration
		end
	end
	
	if self.size ~= 1 then
		self.gravitydirection = math.pi/2
	end
	
	--animationS
	if self.animation == "animationwalk" then
		if self.animationmisc == "right" then
			self.speedx = maxwalkspeed
		else
			self.speedx = -maxwalkspeed
		end
		self:runanimation(dt)
		self:setquad()
		return
	elseif self.animation == "pipe_down_in" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			self.y = self.animationy - 28/16 + self.animationtimer/pipeanimationtime*pipeanimationdistancedown
		else
			self.y = self.animationy - 28/16 + pipeanimationdistancedown
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				updatesizes()
				seek_level(self.animationmisc[3], self.animationmisc[4], self.animationmisc[5], self.animationmisc[7], self.animationmisc[9])
			end
		end
		return
	elseif self.animation == "pipe_down_out" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
		
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			self.y = self.animationy - 20/16 + (self.animationtimer-pipeupdelay)/pipeanimationtime*pipeanimationdistancedown
		else
			self.y = self.animationy - 20/16 + pipeanimationdistancedown
			
			if self.animationtimer >= pipeanimationtime then
				self.active = true
				self.controlsenabled = true
				self.animation = false
				self.customscissor = false
			end
		end
		return
	elseif self.animation == "pipe_up_in" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			self.y = self.animationy + 20/16 - (self.animationtimer)/pipeanimationtime*pipeanimationdistancedown
		else
			self.y = self.animationy + 20/16 - pipeanimationdistancedown
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				updatesizes()
				seek_level(self.animationmisc[3], self.animationmisc[4], self.animationmisc[5], self.animationmisc[7], self.animationmisc[9])
			end
		end
		return
	elseif self.animation == "pipe_up_out" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
		
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			self.y = self.animationy + 20/16 - (self.animationtimer-pipeupdelay)/pipeanimationtime*pipeanimationdistancedown
		else
			self.y = self.animationy + 20/16 - pipeanimationdistancedown
			
			if self.animationtimer >= pipeanimationtime then
				self.active = true
				self.controlsenabled = true
				self.animation = false
				self.customscissor = false
			end
		end
		return
	elseif self.animation == "pipe_right_in" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			self.x = self.animationx - 28/16 + self.animationtimer/pipeanimationtime*pipeanimationdistanceright
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt)
			end
			self:setquad()
		else
			self.x = self.animationx - 28/16 + pipeanimationdistanceright
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				updatesizes()
				seek_level(self.animationmisc[3], self.animationmisc[4], self.animationmisc[5], self.animationmisc[7], self.animationmisc[9])
			end
		end
		return
	elseif self.animation == "pipe_right_out" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
		
	elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			self.x = self.animationx + self.animationtimer/pipeanimationtime*pipeanimationdistanceright
			--self.x = self.animationx - self.animationtimer/pipeanimationtime*pipeanimationdistanceright
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt)
			end
			self:setquad()
		else
			--self.x = self.animationx + pipeanimationdistanceright
			--the x at this point is at the mercy of the timer of previous iterations
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				self.active = true
				self.controlsenabled = true
				self.animation = false
				self.customscissor = false
			end
		end
		return
	elseif self.animation == "pipe_left_in" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			self.x = self.animationx - self.animationtimer/pipeanimationtime*pipeanimationdistanceright
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt)
			end
			self:setquad()
		else
			self.x = self.animationx - pipeanimationdistanceright
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				updatesizes()
				seek_level(self.animationmisc[3], self.animationmisc[4], self.animationmisc[5], self.animationmisc[7], self.animationmisc[9])
			end
		end
		return
	elseif self.animation == "pipe_left_out" and self.animationy and self.animationx then
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
		
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			self.x = self.animationx - self.animationtimer/pipeanimationtime*pipeanimationdistanceright
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt)
			end
			self:setquad()
		else
			--self.x = self.animationx - pipeanimationdistanceright
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				self.active = true
				self.controlsenabled = true
				self.animation = false
				self.customscissor = false
			end
		end
		return
	elseif self.animation == "flag" and flagx then
		if self.animationtimer < flagdescendtime then 	
			flagimgy = flagy-10+1/16 + flagydistance * (self.animationtimer/flagdescendtime)
			self.y = self.y + flagydistance/flagdescendtime * dt
			
			self.animationtimer = self.animationtimer + dt
				
			if self.y > flagy-9+4/16 + flagydistance-self.height then
				self.y = flagy-9+4/16 + flagydistance-self.height
				self.climbframe = 2
			else
				if math.mod(self.animationtimer, flagclimbframedelay*2) >= flagclimbframedelay then
					self.climbframe = 1
				else
					self.climbframe = 2
				end
			end
			
			self.animationstate = "climbing"
			self:setquad()
			
			if self.animationtimer >= flagdescendtime then
				flagimgy = flagy-10+1/16 + flagydistance
				self.pointingangle = math.pi/2
				self.animationdirection = "left"
				self.x = flagx + 6/16
			end
			return
		elseif self.animationtimer < flagdescendtime+flaganimationdelay then
			self.animationtimer = self.animationtimer + dt
			
			if self.animationtimer >= flagdescendtime+flaganimationdelay then
				self.active = true
				self.gravity = mariogravity
				self.animationstate = "running"
				self.speedx = 4.27
				self.pointingangle = -math.pi/2
				self.animationdirection = "right"
			end
		else
			self.animationtimer = self.animationtimer + dt
		end
		
		local add = 6
		
		if (self.x >= flagx + add or self.speedx < maxwalkspeed/2) and self.active then
			self.drawable = false
			self.active = false
			if mariotime > 0 then
				playsound("scorering", self.x, self.y, self.speedx, self.speedy)
				subtractscore = true
				subtracttimer = 0
			else
				castleflagmove = true
			end
		end
		
		if subtractscore == true and mariotime >= 0 then
			subtracttimer = subtracttimer + dt
			while subtracttimer > scoresubtractspeed do
				subtracttimer = subtracttimer - scoresubtractspeed
				if mariotime > 0 then
					mariotime = math.ceil(mariotime - 1)
					self.score = self.score + 50
				end
				
				if mariotime <= 0 then
					subtractscore = false
					soundlist["scorering"].source:stop()
					castleflagmove = true
					mariotime = 0
				end
			end
		end
		
		if castleflagmove then
			if self.animationtimer < castlemintime then
				castleflagtime = self.animationtimer
				return
			end
			castleflagy = castleflagy - castleflagspeed*dt
			
			if castleflagy <= 0 then
				castleflagy = 0
				castleflagmove = false
				dofirework = true
				castleflagtime = self.animationtimer
			end
		end
		
		if dofirework then
			local timedelta = self.animationtimer - castleflagtime
			for i = 1, fireworkcount do
				local fireworktime = i*fireworkdelay
				if timedelta >= fireworktime and timedelta - dt < fireworktime then
					table.insert(objects["firework"], firework:new(flagx+6, flagy-13, self))
				end
			end
			
			if timedelta > fireworkcount*fireworkdelay+endtime then
				nextlevel()
				return
			end
		end
		
		--500 points per firework, appear at 1 3 and 6 (Who came up with this?)
		
		--Run animation
		if self.animationstate == "running" then
			self:runanimation(dt)
			self:setquad()
		end
		return
	
	elseif self.animation == "axe" then
		self.animationtimer = self.animationtimer + dt
		
		if not bowserfall and self.animationtimer - dt < castleanimationchaindisappear and self.animationtimer >= castleanimationchaindisappear then
			bridgedisappear = true
		end
		
		if bridgedisappear then
			local v = objects["bowser"][1]
			if v then
				v.walkframe = round(math.mod(self.animationtimer, castleanimationbowserframedelay*2)*(1/(castleanimationbowserframedelay*2)))+1
			end
			self.animationtimer2 = self.animationtimer2 + dt
			while self.animationtimer2 > castleanimationbridgedisappeardelay and self.animationbridgex > 0 do
				self.animationtimer2 = self.animationtimer2 - castleanimationbridgedisappeardelay
				local removedtile = true
			--	for y = 1, mapheight do
			--		if tilequads[map[self.animationbridgex][y][1]]:getproperty("bridge", self.animationbridgex, y) then
			--			removedtile = true
			--			map[self.animationbridgex][y][1] = 1
			--			objects["tile"][self.animationbridgex .. "-" .. y] = nil
			--		end
			--	end
				
				if removedtile then
					generatespritebatch()
			--		playsound("bridgebreak")
					self.animationbridgex = self.animationbridgex - 1
				else
					bowserfall = true
					bridgedisappear = false
				end
			end
		end
		
		if bowserfall then
			local v = objects["bowser"][1]
			if v and not v.fall then
				v.fall = true
				v.speedx = 0
				v.speedy = 0
				v.active = true
				v.gravity = 27.5
				playsound("bowserfall", v.x, v.y, v.speedx, v.gravity) --gravity doesn't get factored into speedy, which is a problem
				self.animationtimer = 0
				return
			end
		end
		
		if bowserfall and self.animationtimer - dt < castleanimationmariomove and self.animationtimer >= castleanimationmariomove then
			self.active = true
			self.gravity = mariogravity
			self.animationstate = "running"
			self.speedx = 4.27
			self.pointingangle = -math.pi/2
			self.animationdirection = "right"
		
			love.audio.stop()
			playsound("castleend", self.x, self.y) --technically not aligned to the axe, but, we don't care
		end
		
		if self.speedx > 0 and self.x >= mapwidth - 8 then
			self.x = mapwidth - 8
			self.animationstate = "idle"
			self:setquad()
			self.speedx = 0
		end
		
		if levelfinishedmisc2 == 1 then
			if self.animationtimer - dt < castleanimationtextfirstline and self.animationtimer >= castleanimationtextfirstline then
				levelfinishedmisc = 1
			end
			
			if self.animationtimer - dt < castleanimationtextsecondline and self.animationtimer >= castleanimationtextsecondline then
				levelfinishedmisc = 2
			end
		
			if self.animationtimer - dt < castleanimationnextlevel and self.animationtimer >= castleanimationnextlevel then
				nextlevel()
			end
		else
			if self.animationtimer - dt < endanimationtextfirstline and self.animationtimer >= endanimationtextfirstline then
				levelfinishedmisc = 1
			end
			
			if self.animationtimer - dt < endanimationtextsecondline and self.animationtimer >= endanimationtextsecondline then
				levelfinishedmisc = 2
				w:stopmusic()
				w:playmusic("princessmusic.ogg")
			end
		
			if self.animationtimer - dt < endanimationtextthirdline and self.animationtimer >= endanimationtextthirdline then
				levelfinishedmisc = 3
			end
			
			if self.animationtimer - dt < endanimationtextfourthline and self.animationtimer >= endanimationtextfourthline then
				levelfinishedmisc = 4
			end
			
			if self.animationtimer - dt < endanimationtextfifthline and self.animationtimer >= endanimationtextfifthline then
				levelfinishedmisc = 5
			end
		
			if self.animationtimer - dt < endanimationend and self.animationtimer >= endanimationend then
				endpressbutton = true
			end
		end
		
		--Run animation
		if self.animationstate == "running" and self.animationtimer >= castleanimationmariomove then
			self:runanimation(dt)
			self:setquad()
		end
		return
		
	elseif self.animation == "death" or self.animation == "deathpit" then
		self.animationtimer = self.animationtimer + dt
		self.animationstate = "dead"
		self:setquad()
		
		if self.animation == "death" then
			if self.animationtimer >= deathanimationjumptime then
				if self.animationtimer - dt < deathanimationjumptime then
					self.speedy = -deathanimationjumpforce
				end
				self.speedy = self.speedy + deathgravity*dt
				self.y = self.y + self.speedy*dt
			end
		end
		
		if self.animationtimer > deathtotaltime then
			if self.animationmisc == "everyonedead" then
				print("ALERT: Player is managing world respawns, please localize this to gamemode rules.")
				game_load() --we don't have a better way of restarting so this will have to do
				--levelscreen_load("death")
			elseif not everyonedead then
				self:respawn()
			end
		end
		
		return
	elseif self.animation == "intermission" then
		--Run animation
		if self.animationstate == "running" then
			self:runanimation(dt)
			self:setquad()
		end
		
		return
		
	elseif self.animation == "vine" then
		self.y = self.y - vinemovespeed*dt
		
		self.vinemovetimer = self.vinemovetimer + dt
		
		self.climbframe = math.ceil(math.mod(self.vinemovetimer, vineframedelay*2)/vineframedelay)
		self.climbframe = math.max(self.climbframe, 1)
		self:setquad()
		
		if self.y < -4 then
			levelscreen_load("vine", self.animationmisc)
		end
		return
	elseif self.animation == "vinestart" then
		self.animationtimer = self.animationtimer + dt
		if self.vineanimationdropoff == false and self.animationtimer - dt <= vineanimationmariostart and self.animationtimer > vineanimationmariostart then
			self.vineanimationclimb = true
		end
		
		if self.vineanimationclimb then
			self.vinemovetimer = self.vinemovetimer + dt
			
			self.climbframe = math.ceil(math.mod(self.vinemovetimer, vineframedelay*2)/vineframedelay)
			self.climbframe = math.max(self.climbframe, 1)
			
			self.y = self.y - vinemovespeed*dt
			if self.y <= 15-vineanimationgrowheight+vineanimationstop+0.4*(self.playernumber-1) then
				self.vineanimationclimb = false
				self.vineanimationdropoff = true
				self.animationtimer = 0
				self.y = 15-vineanimationgrowheight+vineanimationstop+0.4*(self.playernumber-1)
				self.climbframe = 2
				self.pointingangle = math.pi/2
				self.animationdirection = "left"
				self.x = self.x+9/16
			end
			self:setquad()
		end
		
		if self.vineanimationdropoff and self.animationtimer - dt <= vineanimationdropdelay and self.animationtimer > vineanimationdropdelay then
			self.active = true
			self.controlsenabled = true
			self.x = self.x + 7/16
			self.animation = false
		end
		
		return
	
	elseif self.animation == "shrink" then
		self.animationtimer = self.animationtimer + dt
		--set frame lol
		local frame = math.ceil(math.mod(self.animationtimer, growframedelay*3)/shrinkframedelay)
	
		if frame == 1 then
			self.graphic = self.biggraphic
			self:setquad("idle", 2)
			self.quadcenterY = self.char.shrinkquadcenterY
			self.quadcenterX = self.char.shrinkquadcenterX
			self.offsetY = self.char.bigoffsetY
			self.animationstate = "idle"
		else
			self.graphic = self.smallgraphic
			self.quadcenterX = self.char.smallquadcenterX
			self.offsetY = self.char.smalloffsetY
			if frame == 2 then
				self.animationstate = "grow"
				self:setquad("grow")
				self.quadcenterY = self.char.shrinkquadcenterY2
			else
				self.animationstate = "idle"
				self:setquad()
				self.quadcenterY = self.char.smallquadcenterY
			end
		end
		
		local invis = math.ceil(math.mod(self.animationtimer, invicibleblinktime*2)/invicibleblinktime)
		
		if invis == 1 then
			self.drawable = true
		else
			self.drawable = false
		end
		
		if self.animationtimer - dt < shrinktime and self.animationtimer > shrinktime then
			self:goinvincible()
		end
		return
	elseif self.animation == "invincible" then
		self.animationtimer = self.animationtimer + dt
		
		local invis = math.ceil(math.mod(self.animationtimer, invicibleblinktime*2)/invicibleblinktime)
		
		if invis == 1 then
			self.drawable = true
		else
			self.drawable = false
		end
		
		if self.animationtimer - dt < invincibletime and self.animationtimer > invincibletime then
			self.animation = false
			self.invincible = false
			self.drawable = true
		end
		
	elseif self.animation == "grow1" then
		self.animationtimer = self.animationtimer + dt
		--set frame lol
		local frame = math.ceil(math.mod(self.animationtimer, growframedelay*3)/growframedelay)
		
		if frame == 3 then
			self.animationstate = "idle"
			self.graphic = self.biggraphic
			self:setquad("idle")
			self.quadcenterY = self.char.bigquadcenterY
			self.quadcenterX = self.char.bigquadcenterX
			self.offsetY = self.char.bigoffsetY
		else
			self.graphic = self.smallgraphic
			self.quadcenterX = self.char.smallquadcenterX
			self.offsetY = self.char.smalloffsetY
			if frame == 2 then
				self.animationstate = "grow"
				self:setquad("grow", 1)
				self.quadcenterY = self.char.growquadcenterY
			else
				self.animationstate = "idle"
				self:setquad(nil, 1)
				self.quadcenterY = self.char.growquadcenterY2
			end
		end
		
		if self.animationtimer - dt < growtime and self.animationtimer > growtime then
			self.animationstate = self.animationmisc
			self.animation = false
			noupdate = false
			self.quadcenterY = self.char.bigquadcenterY
			self.graphic = self.biggraphic
			self.animationtimer = 0
			self.quadcenterX = self.char.bigquadcenterX
			self.offsetY = self.char.bigoffsetY
		end
		return
		
	elseif self.animation == "grow2" then
		self.animationtimer = self.animationtimer + dt
		--set frame lol
		local frame = math.ceil(math.mod(self.animationtimer, growframedelay*3)/growframedelay)
		self.colors = starcolors[frame]
		
		if self.animationtimer - dt < growtime and self.animationtimer > growtime then
			self.animation = false
			noupdate = false
			self.animationtimer = 0
			self.colors = self.char.flowercolor or flowercolor
		end
		return
	end
	
	if noupdate then
		return
	end
	
	if self.fireanimationtimer < fireanimationtime then
		self.fireanimationtimer = self.fireanimationtimer + dt
		if self.fireanimationtimer > fireanimationtime then
			self.fireanimationtimer = fireanimationtime
		end
	end
	
	--Funnels and fuck
	if self.funnel and not self.infunnel then
		self:enteredfunnel(true)
	end
	
	if self.infunnel and not self.funnel then
		self:enteredfunnel(false)
	end
	
	if self.funnel then
		self.animationstate = "jumping"
		self:setquad()
	end
	
	self.funnel = false
	
	--vine controls and shit
	if self.vine then
		self.gravity = 0
		self.animationstate = "climbing"
		if self.binds.control.playerUp then
			self.vinemovetimer = self.vinemovetimer + dt
			
			self.climbframe = math.ceil(math.mod(self.vinemovetimer, vineframedelay*2)/vineframedelay)
			self.climbframe = math.max(self.climbframe, 1)
			
			self.y = self.y-vinemovespeed*dt
			
			local t = checkrect(self.x, self.y, self.width, self.height, {"tile", "portalwall"})
			if #t ~= 0 then
				self.y = objects[t[1]][t[2]].y + objects[t[1]][t[2]].height
				self.climbframe = 2
			end
		elseif self.binds.control.playerDown then
			self.vinemovetimer = self.vinemovetimer + dt
			
			self.climbframe = math.ceil(math.mod(self.vinemovetimer, vineframedelaydown*2)/vineframedelaydown)
			self.climbframe = math.max(self.climbframe, 1)
			
			checkportalHOR(self, self.y+vinemovedownspeed*dt)
			
			self.y = self.y+vinemovedownspeed*dt
			
			local t = checkrect(self.x, self.y, self.width, self.height, {"tile", "portalwall"})
			if #t ~= 0 then
				self.y = objects[t[1]][t[2]].y - self.height
				self.climbframe = 2
			end
		else
			self.climbframe = 2
			self.vinemovetimer = 0
		end
			
		if self.vine.limit == -1 and self.y+self.height <= vineanimationstart then
			self:vineanimation()
		end
		
		--check if still on vine
		local t = checkrect(self.x, self.y, self.width, self.height, {"vine"})
		if #t == 0 then
			self:dropvine(self.vineside)
		end
		
		self:setquad()
		return
	end
	
	--springs
	if self.spring then
		self.x = self.springx
		self.springtimer = self.springtimer + dt
		self.y = self.springy - self.height - 31/16 + springytable[self.springb.frame]
		if self.springtimer > springtime then
			self:leavespring()
		end
		return
	end
	
	--coins
	if not editormode then
		local x = math.floor(self.x+self.width/2)+1
		local y = math.floor(self.y+self.height)+14/16
		if inmap(x, y) and coinmap[x][y] then
			self:getcoin(1, x, y)
		end
		local y = math.floor(self.y+self.height/2)+1
		if inmap(x, y) and coinmap[x][y] then
			self:getcoin(1, x, y)
		end
		if self.size > 1 then
			if inmap(x, y-1) and coinmap[x][y-1] then
				self:getcoin(1, x, y-1)
			end
		end
	end
	
	--mazegate
	local x = math.floor(self.x+self.width/2)+1
	local y = math.floor(self.y+self.height/2)+1
	if inmap(x, y) and map[x][y][2] and entitylist[map[x][y][2]] and entitylist[map[x][y][2]].t == "mazegate" then
		if map[x][y][3] == self.mazevar + 1 then
			self.mazevar = self.mazevar + 1
		elseif map[x][y][3] == self.mazevar then
			
		else
			self.mazevar = 0
		end
	end
	
	--axe
	local x = math.floor(self.x+self.width/2)+1
	local y = math.floor(self.y+self.height/2)+1
	
	if self.controlsenabled then
		--check for pipe pipe pipe
		local px, py = math.floor(self.x+30/16), math.floor(self.y+self.height+20/16)
		if inmap(px, py) and self.binds.control.playerDown and not self.falling and not self.jumping then
			local t2 = map[px][py][2]
			if t2 and entitylist[t2] and entitylist[t2].t == "warppipe" and map[px][py][8] then
				--self.animationmisc2 = tonumber(map[px][py][3]) or 1
				--self.animationmisc3 = tonumber(map[px][py][4]) or 1
				--"pipe"
				--self:pipe(px, py, "down", tonumber(map[px][py][3]-1))
				--"warppipe"
				self:pipe(px, py, "down", map[px][py])
				return
			end
		end
		
		--[[@DEV:
			For this section we have to +1 py2 because apparently map is still offset crazily.
			More specifically, inmap would fail with the correct py2 and the rest of the conditions
			would be right or the inverse, referencing a block just above the correct one.
		]]
		local px2, py2 = math.floor(self.x+30/16), math.floor(self.y-self.height)
		if inmap(px2, py2) then
			local t2 = map[px2][py2+1][2]
			if t2 
			and entitylist[t2] 
			and entitylist[t2].t == "warppipe" 
			and map[px2][py2+1][8] then
				print("warp up available", py2, self.y, self.height)
				if self.binds.control.playerUp then
					--self.animationmisc2 = tonumber(map[px][py][3]) or 1
					--self.animationmisc3 = tonumber(map[px][py][4]) or 1
					--"pipe"
					--self:pipe(px, py, "down", tonumber(map[px][py][3]-1))
					--"warppipe"
					self:pipe(px2, py2+1, "up", map[px2][py2+1])
					return
				end
			end
		end
		
		
		if self.falling == false and self.jumping == false and self.size > 1 then
			if self.binds.control.playerDown then
				if self.ducking == false then
					self:duck(true)
				end
			else
				if self.ducking then
					self:duck(false)
				end
			end
		end
		
		if not underwater then
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height/2)+1
			
			if inmap(x, y) then
				if tilequads[map[x][y][1]]:getproperty("water", x, y) then
					if not self.underwater then
						self:dive(true)
					end
				else
					if self.underwater then
						self:dive(false)
					end
				end
			end
		end
		
		if not self.underwater then
			self:movement(dt)
		else
			self:underwatermovement(dt)
		end
		
		--RACCOON STUFF
		if self.char.raccoon and self.size == 2 then
			if not self.falling and not self.jumping then
				if math.abs(self.speedx) >= maxwalkspeed and self.binds.control.playerRun and ((self.binds.control.playerRight and not self.binds.control.playerLeft) or (not self.binds.control.playerRight and self.binds.control.playerLeft)) then
					if self.raccoonstarttimer < raccoonstarttime then
						self.raccoonstarttimer = self.raccoonstarttimer + dt
						if self.raccoonstarttimer >= raccoonstarttime then
							self.raccoonstarttimer = raccoonstarttime
							self.raccoonjump = true
							playsound("planemode", self.x, self.y, self.speedx, self.speedy)
						end
					end
				else
					self.raccoonjump = false
					self.raccoonstarttimer = 0
				end
			else
				self.raccoonstarttimer = math.max(0, self.raccoonstarttimer-dt)
			end
		end
		
		if not self.raccoonjump and self.raccoontimer == 0 and not soundlist["planemode"].source:isStopped() then
			soundlist["planemode"].source:stop()
		end
		
		if self.raccoonascendtimer > 0 then
			if self.raccoontimer > 0 then
				self.raccoonascendtimer = math.max(0, self.raccoonascendtimer-dt)
				self.speedy = -raccoonascendspeed
				self.falling = true
			else
				self.speedy = math.min(raccoondescendspeed, self.speedy)
				self.raccoonascendtimer = math.max(0, self.raccoonascendtimer-dt)
			end
		end
		
		if self.raccoontimer > 0 then
			self.raccoontimer = math.max(0, self.raccoontimer-dt)
			if self.raccoontimer == 0 then
				self.raccoonascendtimer = 0
			end
		end
		
		--DEATH BY PIT
		if self.gravitydirection > math.pi/4*1 and self.gravitydirection <= math.pi/4*3 then --down
			if self.y >= mapheight then
				self:murder(nil, "pit", "pit")
			end
		elseif self.gravitydirection > math.pi/4*5 and self.gravitydirection <= math.pi/4*7 then --up
			if self.y <= -1 then
				self:murder(nil, "pit", "pit")
			end
		end
		
		
		if flagx and not levelfinished and self.x+self.width >= flagx+6/16 and self.y > flagy-10.8 then
			self:flag()
		end
		
--[[		if firestartx then
			if self.x >= firestartx - 1 then
				firestarted = true
			else
				--check for all players
				local disable = true
				for i = 1, players do
					if objects["player"][i].x >= firestartx - 1 then
						disable = false
					end
				end
				
				if disable then
					firestarted = false
				end
			end
		end
]]		
		if lakitoendx and self.x >= lakitoendx then
			lakitoend = true
		end
	else
		if not self.underwater then
			self:movement(dt)
		else
			self:underwatermovement(dt)
		end
	end
	
	--drains
	local x = math.floor(self.x+self.width/2)+1
	
	if inmap(x, mapheight) and map[x][mapheight][2] and entitylist[map[x][mapheight][2]] and entitylist[map[x][mapheight][2]].t == "drain" then
		if self.speedy < drainmax then
			self.speedy = math.min( drainmax, self.speedy + drainspeed*dt)
		end
	end
	
	--out of bounds
	if self.y < 0-self.height then
		self.outofboundstimer = self.outofboundstimer+dt
	elseif self.outofboundstimer > 0 then
		self.outofboundstimer = 0
	end
	
	--@DEV: Experimental audio foolery.
	if self.playernumber == 1 then
		love.audio.setPosition(self.x, self.y, 0)
		love.audio.setVelocity(self.speedx, self.speedy, 0)
	end
	self:setquad()
end

function player:updateangle()
	if self.remote then
		return
	end
	
	if self.vine or self.animation then
		return
	end
	--UPDATE THE PLAYER ANGLE
	if self.playernumber == mouseowner and self.prefermouse then
		local scale = scale
		if shaders and shaders.scale then scale = shaders.scale end
		self.pointingangle = math.atan2(self.x+6/16-xscroll-(mouse.getX()/16/scale), (self.y-yscroll+6/16-.5)-(mouse.getY()/16/scale))
	elseif self.binds.control.playerAimX then
		local x, y = -self.binds.control.playerAimX, -self.binds.control.playerAimY
		
		if not x or not y then
			return
		end
		
		if math.abs(x) > joystickaimdeadzone or math.abs(y) > joystickaimdeadzone then
			self.pointingangle = math.atan2(x, y)
			if self.pointingangle == 0 then
				self.pointingangle = 0
				--this is really silly, but will crash the game if I don't do this. It's because it's -0 or something. I'm not good with computers.
			end
		end
	else
		--assert(false, "Player#"..self.playernumber.." has no way of knowing where he's aiming.")
	end
end

function player:movement(dt)
	local maxrunspeed = maxrunspeed
	local maxwalkspeed = maxwalkspeed
	local runacceleration = runacceleration
	local walkacceleration = walkacceleration
	--Orange gel
	--not in air
	if self.falling == false and self.jumping == false then
		local orangegel = false
		local bluegel = false
		--On Tiles
		if math.mod(self.y+self.height, 1) == 0 then
			local x = round(self.x+self.width/2+.5)
			local y = self.y+self.height+1
			--x and y in map
			if inmap(x, y) then
				--top of block orange
				if map[x][y]["gels"]["top"] == 2 then
					orangegel = true
				elseif map[x][y]["gels"]["top"] == 1 then
					bluegel = true
				end
			end
		end
		
		--On Lightbridge
		local x = round(self.x+self.width/2+.5)
		local y = round(self.y+self.height+1)
		
		for i, v in pairs(objects["lightbridgebody"]) do
			if x == v.cox and y == v.coy and v.gels.top then
				orangegel = true
			end
		end
		
		if orangegel then
			maxrunspeed = gelmaxrunspeed
			maxwalkspeed = gelmaxwalkspeed
			runacceleration = gelrunacceleration
			walkacceleration = gelwalkacceleration
		elseif bluegel then
			if math.abs(self.speedx) > maxrunspeed*1.5 then
				self.speedy = -40
				self.falling = true
			end
		end
	end
	
	if self.animationstate == "running" then
		self:runanimation(dt)
	end
	
	if self.animationstate == "jumping" then
		self.jumpanimationprogress = self.jumpanimationprogress + dt*runanimationspeed
		while self.jumpanimationprogress > self.char.jumpframes+1 do
			self.jumpanimationprogress = self.jumpanimationprogress - self.char.jumpframes
		end
		self.jumpframe = math.floor(self.jumpanimationprogress)
	end
		
	--HORIZONTAL MOVEMENT
	if self.controlsenabled and self.binds.control.playerRun then --RUNNING
		if self.controlsenabled and self.binds.control.playerRight then --MOVEMENT RIGHT
			if self.jumping or self.falling then --IN AIR
				if self.speedx < maxwalkspeed then
					if self.speedx < 0 then
						self.speedx = self.speedx + runaccelerationair*dt*airslidefactor
					else
						self.speedx = self.speedx + runaccelerationair*dt
					end
					
					if self.speedx > maxwalkspeed then
						self.speedx = maxwalkspeed
					end
				elseif self.speedx > maxwalkspeed and self.speedx < maxrunspeed then
					if self.speedx < 0 then
						self.speedx = self.speedx + runaccelerationair*dt*airslidefactor
					else
						self.speedx = self.speedx + runaccelerationair*dt
					end
					
					if self.speedx > maxrunspeed then
						self.speedx = maxrunspeed
					end
				end
					
			elseif self.ducking == false then --ON GROUND
				if self.speedx < 0 then
					if self.speedx < -maxrunspeed then
						self.speedx = self.speedx + superfriction*dt + runacceleration*dt
					else
						self.speedx = self.speedx + friction*dt + runacceleration*dt
					end
					self.animationstate = "sliding"
					self.animationdirection = "right"
				else
					if self.speedx <= maxrunspeed then
						self.speedx = self.speedx + runacceleration*dt
						self.animationstate = "running"
						self.animationdirection = "right"
					
						if self.speedx > maxrunspeed then
							self.speedx = maxrunspeed
						end
					else
						self.speedx = self.speedx - superfriction*dt
					end
				end
			end
			
		elseif self.controlsenabled and self.binds.control.playerLeft then --MOVEMENT LEFT
			if self.jumping or self.falling then --IN AIR
				if self.speedx > -maxwalkspeed then
					if self.speedx > 0 then
						self.speedx = self.speedx - runaccelerationair*dt*airslidefactor
					else
						self.speedx = self.speedx - runaccelerationair*dt
					end
					
					if self.speedx < -maxwalkspeed then
						self.speedx = -maxwalkspeed
					end
				elseif self.speedx < -maxwalkspeed and self.speedx > -maxrunspeed then
					if self.speedx > 0 then
						self.speedx = self.speedx - runaccelerationair*dt*airslidefactor
					else
						self.speedx = self.speedx - runaccelerationair*dt
					end
					
					if self.speedx < -maxrunspeed then
						self.speedx = -maxrunspeed
					end
				end
				
			elseif self.ducking == false then --ON GROUND
				if self.speedx > 0 then
					if self.speedx > maxrunspeed then
						self.speedx = self.speedx - superfriction*dt - runacceleration*dt
					else
						self.speedx = self.speedx - friction*dt - runacceleration*dt
				
					end
					self.animationstate = "sliding"
					self.animationdirection = "left"
				else
					if self.speedx >= -maxrunspeed then
						self.speedx = self.speedx - runacceleration*dt
						self.animationstate = "running"
						self.animationdirection = "left"
					
						if self.speedx < -maxrunspeed then
							self.speedx = -maxrunspeed
						end
					else
						self.speedx = self.speedx + superfriction*dt
					end
				end
			end
		
		end
		if (not self.binds.control.playerRight and not self.binds.control.playerLeft) or (self.ducking and self.falling == false and self.jumping == false) or not self.controlsenabled then  --NO MOVEMENT
			if self.jumping or self.falling then
				if self.speedx > 0 then
					self.speedx = self.speedx - frictionair*dt
					if self.speedx < minspeed then
						self.speedx = 0
						self.runframe = 1
					end
				else
					self.speedx = self.speedx + frictionair*dt
					if self.speedx > -minspeed then
						self.speedx = 0
						self.runframe = 1
					end
				end
			else
				if self.speedx > 0 then
					if self.speedx > maxrunspeed then
						self.speedx = self.speedx - superfriction*dt
					else	
						self.speedx = self.speedx - friction*dt
					end
					if self.speedx < minspeed then
						self.speedx = 0
						self.runframe = 1
						self.animationstate = "idle"
					end
				else
					if self.speedx < -maxrunspeed then
						self.speedx = self.speedx + superfriction*dt
					else	
						self.speedx = self.speedx + friction*dt
					end
					if self.speedx > -minspeed then
						self.speedx = 0
						self.runframe = 1
						self.animationstate = "idle"
					end
				end
			end
		end
		
	else --WALKING
	
		if self.controlsenabled and self.binds.control.playerRight then --MOVEMENT RIGHT
			if self.jumping or self.falling then --IN AIR
				if self.speedx < maxwalkspeed then
					if self.speedx < 0 then
						self.speedx = self.speedx + walkaccelerationair*dt*airslidefactor
					else
						self.speedx = self.speedx + walkaccelerationair*dt
					end
					
					if self.speedx > maxwalkspeed then
						self.speedx = maxwalkspeed
					end
				end
			elseif self.ducking == false then --ON GROUND
				if self.speedx < maxwalkspeed then
					if self.speedx < 0 then
						if self.speedx < -maxrunspeed then
							self.speedx = self.speedx + superfriction*dt + runacceleration*dt
						else
							self.speedx = self.speedx + friction*dt + runacceleration*dt
						end
						self.animationstate = "sliding"
						self.animationdirection = "right"
					else
						self.speedx = self.speedx + walkacceleration*dt
						self.animationstate = "running"
						self.animationdirection = "right"
					end
					
					if self.speedx > maxwalkspeed then
						self.speedx = maxwalkspeed
					end
				else
					if self.speedx > maxrunspeed then
						self.speedx = self.speedx - superfriction*dt
					else
						self.speedx = self.speedx - friction*dt
					end
					
					if self.speedx < maxwalkspeed then
						self.speedx = maxwalkspeed
					end
				end
			end
			
		elseif self.controlsenabled and self.binds.control.playerLeft then --MOVEMENT LEFT
			if self.jumping or self.falling then --IN AIR
				if self.speedx > -maxwalkspeed then
					if self.speedx > 0 then
						self.speedx = self.speedx - walkaccelerationair*dt*airslidefactor
					else
						self.speedx = self.speedx - walkaccelerationair*dt
					end
					
					if self.speedx < -maxwalkspeed then
						self.speedx = -maxwalkspeed
					end
				end
			elseif self.ducking == false then --ON GROUND
				if self.speedx > -maxwalkspeed then
					if self.speedx > 0 then
						if self.speedx > maxrunspeed then
							self.speedx = self.speedx - superfriction*dt - runacceleration*dt
						else
							self.speedx = self.speedx - friction*dt - runacceleration*dt
						end
						self.animationstate = "sliding"
						self.animationdirection = "left"
					else
						self.speedx = self.speedx - walkacceleration*dt
						self.animationstate = "running"
						self.animationdirection = "left"
					end
					
					if self.speedx < -maxwalkspeed then
						self.speedx = -maxwalkspeed
					end
				else
					if self.speedx < -maxrunspeed then
						self.speedx = self.speedx + superfriction*dt
					else
						self.speedx = self.speedx + friction*dt
					end
					
					if self.speedx > -maxwalkspeed then
						self.speedx = -maxwalkspeed
					end
				end
			end
		
		end
		if (not self.binds.control.playerRight and not self.binds.control.playerLeft) or (self.ducking and self.falling == false and self.jumping == false) or not self.controlsenabled then --no movement
			if self.jumping or self.falling then
				if self.speedx > 0 then
					self.speedx = self.speedx - frictionair*dt
					if self.speedx < 0 then
						self.speedx = 0
						self.runframe = 1
					end
				else
					self.speedx = self.speedx + frictionair*dt
					if self.speedx > 0 then
						self.speedx = 0
						self.runframe = 1
					end
				end
			else
				if self.speedx > 0 then
					if self.speedx > maxrunspeed then
						self.speedx = self.speedx - superfriction*dt
					else	
						self.speedx = self.speedx - friction*dt
					end
					if self.speedx < 0 then
						self.speedx = 0
						self.runframe = 1
						self.animationstate = "idle"
					end
				else
					if self.speedx < -maxrunspeed then
						self.speedx = self.speedx + superfriction*dt
					else	
						self.speedx = self.speedx + friction*dt
					end
					if self.speedx > 0 then
						self.speedx = 0
						self.runframe = 1
						self.animationstate = "idle"
					end
				end
			end
		end
	end
end

function player:runanimation(dt)
	self.runanimationprogress = self.runanimationprogress + (math.abs(self.speedx)+4)/5*dt*(self.char.rundelay or runanimationspeed)
	while self.runanimationprogress > self.char.runframes+1 do
		self.runanimationprogress = self.runanimationprogress - self.char.runframes
	end
	self.runframe = math.floor(self.runanimationprogress)
end

function player:underwatermovement(dt)
	if self.jumping or self.falling then
		--Swim animation
		if self.animationstate == "jumping" or self.animationstate == "falling" then
			self.swimanimationprogress = self.swimanimationprogress + runanimationspeed*dt
			while self.swimanimationprogress >= 3 do
				self.swimanimationprogress = self.swimanimationprogress - 2
			end
			self.swimframe = math.floor(self.swimanimationprogress)
			self:setquad()
		end
	else
		if self.animationstate == "running" then
			self:runanimation(dt)
		end
	end
	
	local maxrunspeed = maxrunspeed
	local maxwalkspeed = maxwalkspeed
	local runacceleration = runacceleration
	local walkacceleration = walkacceleration
	--Orange gel
	--not in air
	if self.falling == false and self.jumping == false then
		--bottom on grid
		if math.mod(self.y+self.height, 1) == 0 then
			local x = round(self.x+self.width/2+.5)
			local y = self.y+self.height+1
			--x and y in map
			if inmap(x, y) then
				--top of block orange
				if map[x][y]["gels"]["top"] == 2 then
					maxrunspeed = uwgelmaxrunspeed
					maxwalkspeed = uwgelmaxwalkspeed
					runacceleration = uwgelrunacceleration
					walkacceleration = uwgelwalkacceleration
				end
			end
		end
	end
	
	--bubbles
	self.bubbletimer = self.bubbletimer + dt
	while self.bubbletimer > self.bubbletime do
		self.bubbletimer = self.bubbletimer - self.bubbletime
		self.bubbletime = bubblestime[math.random(#bubblestime)]
		bubble:new(self.x+8/12, self.y+2/12)
	end
	
	--HORIZONTAL MOVEMENT	
	if self.controlsenabled and self.binds.control.playerRight and (self.jumping or self.falling or not self.ducking) then --MOVEMENT RIGHT
		if self.jumping or self.falling then --IN AIR
			if self.speedx < uwmaxairwalkspeed then
				if self.speedx < 0 then
					self.speedx = self.speedx + walkaccelerationair*dt*uwairslidefactor
				else
					self.speedx = self.speedx + walkaccelerationair*dt
				end
				
				if self.speedx > uwmaxairwalkspeed then
					self.speedx = uwmaxairwalkspeed
				end
			end
		else --ON GROUND
			if self.speedx < maxwalkspeed then
				if self.speedx < 0 then
					if self.speedx < -maxrunspeed then
						self.speedx = self.speedx + uwsuperfriction*dt + runacceleration*dt
					else
						self.speedx = self.speedx + uwfriction*dt + runacceleration*dt
					end
					self.animationstate = "sliding"
					self.animationdirection = "right"
				else
					self.speedx = self.speedx + walkacceleration*dt
					self.animationstate = "running"
					self.animationdirection = "right"
				end
				
				if self.speedx > maxwalkspeed then
					self.speedx = maxwalkspeed
				end
			else
				self.speedx = self.speedx - uwfriction*dt
				if self.speedx < maxwalkspeed then
					self.speedx = maxwalkspeed
				end
			end
		end
	elseif self.controlsenabled and self.binds.control.playerLeft and (self.jumping or self.falling or not self.ducking) then --MOVEMENT LEFT
		if self.jumping or self.falling then --IN AIR
			if self.speedx > -uwmaxairwalkspeed then
				if self.speedx > 0 then
					self.speedx = self.speedx - walkaccelerationair*dt*uwairslidefactor
				else
					self.speedx = self.speedx - walkaccelerationair*dt
				end
				
				if self.speedx < -uwmaxairwalkspeed then
					self.speedx = -uwmaxairwalkspeed
				end
			end
		else --ON GROUND
			if self.speedx > -maxwalkspeed then
				if self.speedx > 0 then
					if self.speedx > maxrunspeed then
						self.speedx = self.speedx - uwsuperfriction*dt - runacceleration*dt
					else
						self.speedx = self.speedx - uwfriction*dt - runacceleration*dt
					end
					self.animationstate = "sliding"
					self.animationdirection = "left"
				else
					self.speedx = self.speedx - walkacceleration*dt
					self.animationstate = "running"
					self.animationdirection = "left"
				end
				
				if self.speedx < -maxwalkspeed then
					self.speedx = -maxwalkspeed
				end
			else
				self.speedx = self.speedx + uwfriction*dt
				if self.speedx > -maxwalkspeed then
					self.speedx = -maxwalkspeed
				end
			end
		end
	
	else --NO MOVEMENT
		if self.jumping or self.falling then
			if self.speedx > 0 then
				self.speedx = self.speedx - uwfrictionair*dt
				if self.speedx < 0 then
					self.speedx = 0
					self.runframe = 1
				end
			else
				self.speedx = self.speedx + uwfrictionair*dt
				if self.speedx > 0 then
					self.speedx = 0
					self.runframe = 1
				end
			end
		else
			if self.speedx > 0 then
				if self.speedx > maxrunspeed then
					self.speedx = self.speedx - uwsuperfriction*dt
				else	
					self.speedx = self.speedx - uwfriction*dt
				end
				if self.speedx < 0 then
					self.speedx = 0
					self.runframe = 1
					self.animationstate = "idle"
				end
			else
				if self.speedx < -maxrunspeed then
					self.speedx = self.speedx + uwsuperfriction*dt
				else	
					self.speedx = self.speedx + uwfriction*dt
				end
				if self.speedx > 0 then
					self.speedx = 0
					self.runframe = 1
					self.animationstate = "idle"
				end
			end
		end
	end
	
	if self.y+self.height < uwmaxheight then
		self.speedy = uwpushdownspeed
	end
end

function player:setquad(anim, s)
	local angleframe
	if self.char.nopointing then
		angleframe = 1
	elseif not self.portalsavailable[1] and not self.portalsavailable[2] and not self.char.nogunanimations then
		angleframe = 3
	else
		angleframe = getAngleFrame(self.pointingangle, self.rotation)
	end
	
	local animationstate = anim or self.animationstate
	local size = s or self.size
	
	if size == 1 then
		if self.infunnel or animationstate == "jumping" and not self.underwater then
			self.quad = self.char.jump[angleframe][self.jumpframe]
		elseif self.underwater and (self.animationstate == "jumping" or self.animationstate == "falling") then
			self.quad = self.char.swim[angleframe][self.swimframe]
		elseif animationstate == "running" or animationstate == "falling" then
			self.quad = self.char.run[angleframe][self.runframe]
		elseif animationstate == "idle" then
			self.quad = self.char.idle[angleframe]
		elseif animationstate == "sliding" then
			self.quad = self.char.slide[angleframe]
		elseif animationstate == "climbing" then
			self.quad = self.char.climb[angleframe][self.climbframe]
		elseif animationstate == "dead" then
			self.quad = self.char.die[angleframe]
		elseif animationstate == "grow" then
			self.quad = self.char.grow[angleframe]
		end
	elseif size > 1 then
		if self.char.raccoon and self.raccoontimer > 0 and self.falling and animationstate ~= "climbing" then
			self.quad = self.char.bigcustomframe[angleframe][self.tailwagframe+9]
		elseif self.char.raccoon and self.raccoonspinframe then
			if self.falling or self.jumping then
				self.quad = self.char.bigcustomframe[angleframe][self.raccoonspinframe+12]
			else
				self.quad = self.char.bigcustomframe[angleframe][self.raccoonspinframe]
			end
		elseif self.char.raccoon and (animationstate ~= "climbing" and not self.ducking and self.falling and not self.jumping) then
			self.quad = self.char.bigcustomframe[angleframe][self.tailwagframe+3]
			
		elseif self.infunnel or (animationstate == "jumping" and not self.ducking and not self.underwater) then
			self.quad = self.char.bigjump[angleframe][self.jumpframe]
		elseif self.underwater and (self.animationstate == "jumping" or self.animationstate == "falling") then
			self.quad = self.char.bigswim[angleframe][self.swimframe]
		elseif self.ducking then
			self.quad = self.char.bigduck[angleframe]
		elseif self.fireanimationtimer < fireanimationtime then
			self.quad = self.char.bigfire[angleframe]
		else
			if animationstate == "running" or animationstate == "falling" or (self.char.raccoon and animationstate == "jumping") then
				if self.raccoonjump then
					self.quad = self.char.bigcustomframe[angleframe][self.runframe+6]
				else
					self.quad = self.char.bigrun[angleframe][self.runframe]
				end
			elseif animationstate == "idle" then
				self.quad = self.char.bigidle[angleframe]
			elseif animationstate == "sliding" then
				self.quad = self.char.bigslide[angleframe]
			elseif animationstate == "climbing" then
				self.quad = self.char.bigclimb[angleframe][self.climbframe]
			end
		end
	end
end

function gethatoffset(char, graphic, animationstate, runframe, jumpframe, climbframe, swimframe, underwater, infunnel, fireanimationtimer, ducking)
	local hatoffset
	if graphic == char.animations or graphic == char.nogunanimations then
		if not char.hatoffsets then
			return
		end
		
		if infunnel then
			hatoffset = char.hatoffsets["jumping"][jumpframe]
		elseif underwater and (animationstate == "jumping" or animationstate == "falling") then
			hatoffset = char.hatoffsets["swimming"][swimframe]
		elseif animationstate == "jumping" then
			hatoffset = char.hatoffsets["jumping"][jumpframe]
		elseif animationstate == "running" or animationstate == "falling" then
			hatoffset = char.hatoffsets["running"][runframe]
		elseif animationstate == "climbing" then
			hatoffset = char.hatoffsets["climbing"][climbframe]
		end
	else
		if not char.bighatoffsets then
			return
		end
		if infunnel or animationstate == "jumping" and not ducking then
			hatoffset = char.bighatoffsets["jumping"][jumpframe]
		elseif underwater and (animationstate == "jumping" or animationstate == "falling") then
			hatoffset = char.bighatoffsets["swimming"][swimframe]
		elseif ducking then
			hatoffset = char.bighatoffsets["ducking"]
		elseif fireanimationtimer < fireanimationtime then
			hatoffset = char.bighatoffsets["fire"]
		else
			if animationstate == "running" or animationstate == "falling" then
				hatoffset = char.bighatoffsets["running"][runframe]
			elseif animationstate == "climbing" then
				hatoffset = char.bighatoffsets["climbing"][climbframe]
			end
		end
	end
	
	if not hatoffset then
		if graphic == char.animations or graphic == char.nogunanimations then
			hatoffset = char.hatoffsets[animationstate]
		else
			hatoffset = char.bighatoffsets[animationstate]
		end
	end
	
	return hatoffset
end

function player:jump(force)
	if ((not noupdate or self.animation == "grow1" or self.animation == "grow2") and self.controlsenabled) or force then
	
		if not self.underwater then
			if self.spring then
				self.springhigh = true
				return
			end
			
			if self.raccoonjump then
				self.raccoontimer = raccoontime
				self.raccoonjump = false
				self.tailwag = true
			end
			
			if self.char.raccoon and self.size >= 2 and self.falling and not self.jumping then
				self.raccoonascendtimer = raccoonbuttondelay
				self.tailwag = true
			end
			
			if self.raccoontimer > 0 then
				self.raccoonascendtimer = raccoonbuttondelay 
				self.tailwag = true
			else
				if ((self.animation ~= "grow1" and self.animation ~= "grow2") or self.falling) and (self.falling == false or self.animation == "grow1" or self.animation == "grow2" or (self.char.dbljmppls and not self.dbljmping)) then
					if self.falling and self.char.dbljmppls then
						self.dbljmping = true
					end
					
					if self.animation ~= "grow1" and self.animation ~= "grow2" then
						if self.size == 1 then
							playsound("jump", self.x, self.y, self.speedx, self.speedy)
						else
							playsound("jumpbig", self.x, self.y, self.speedx, self.speedy)
						end
					end
					
					local force = -jumpforce - (math.abs(self.speedx) / maxrunspeed)*jumpforceadd
					force = math.max(-jumpforce - jumpforceadd, force)
					
					self.speedy = force
					
					self.jumping = true
					self.animationstate = "jumping"
					self:setquad()
				end
			end
		else
			if self.ducking then
				self:duck(false)
			end
			playsound("swim", self.x, self.y, self.speedx, self.speedy)
			
			self.speedy = -uwjumpforce - (math.abs(self.speedx) / maxrunspeed)*uwjumpforceadd
			self.jumping = true
			self.animationstate = "jumping"
			self:setquad()
		end
		
		--check if upper half is inside block
		if self.size > 1 then
			local x = round(self.x+self.width/2+.5)
			local y = round(self.y)
			
			if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) then
				if getPortal(x, y) then
					self.speedy = 0
					self.jumping = false
					self.falling = true
				else
					self:ceilcollide("tile", objects["tile"][x .. "-" .. y], "player", self)
				end
			end
		end
	end
end

function player:stopjump(force)
	if self.controlsenabled or force then
		if self.jumping == true then
			self.jumping = false
			self.falling = true
		end
	end
end

function player:rightkey()
	if self.controlsenabled and self.vine then
		if self.vineside == "left" then
			local targetx = self.x + 8/16
			if #checkrect(targetx, self.y, self.width, self.height, {"exclude", self}, true) == 0 then
				self.x = targetx
				self.pointingangle = math.pi/2
				self.animationdirection = "left"
				self.vineside = "right"
			end
		else
			self:dropvine("right")
		end
	end
end

function player:leftkey()
	if self.controlsenabled and self.vine then
		if self.vineside == "right" then
			local targetx = self.x - 8/16
			if #checkrect(targetx, self.y, self.width, self.height, {"exclude", self}, true) == 0 then
				self.x = targetx
				self.pointingangle = -math.pi/2
				self.animationdirection = "right"
				self.vineside = "left"
			end
		else
			self:dropvine("left")
		end
	end
end
--[[function player:grow()
	self.animationmisc = self.animationstate
	if self.animation and self.animation ~= "invincible" then
		return
	end
	addpoints(1000, self.x+self.width/2, self.y)
	playsound("mushroomeat", self.x, self.y, self.speedx, self.speedy)
	
	if bigmario then
		return
	end
	
	if self.size > 2 then
		
	else
		self.size = self.size + 1
		if self.size == 2 then		
			self.y = self.y - 12/16
			self.height = 24/16
		elseif self.size == 3 then
			self.colors = self.char.flowercolor or flowercolor
		end
		
		if self.size == 2 then
			self.animation = "grow1"
		else
			self.animation = "grow2"
		end
		self.drawable = true
		self.invincible = false
		self.animationtimer = 0
		noupdate = true
	end
end]]

--[[function player:shrink()
	self.animationmisc = self.animationstate
	if self.animation then
		return
	end
	if self.ducking then
		self:duck(false)
	end
	playsound("shrink", self.x, self.y, self.speedx, self.speedy)
	
	self.size = 1
	
	self.colors = mariocolors[self.playernumber]
	
	self.animation = "shrink"
	self.drawable = true
	self.invincible = true
	self.animationtimer = 0
	self.raccoontimer = 0
	self.raccoonascendtimer = 0
	
	self.y = self.y + 12/16
	self.height = 12/16
	
	noupdate = true
end]]

function player:getpowerup(poweruptype, powerdowntarget, reason)
	powerdowntarget = powerdowntarget or "death"
	reason = reason or "it is a mystery"
	if self.powerupstate == poweruptype then
		-- this is here because for whatever reason touching a mushroom doubletaps
		-- which is very bad because the animation system is fucked
		return
	end
	--self.size = size
	print("Mario got powerup '"..poweruptype.."', pd: '"..tostring(powerdowntarget).."' because "..tostring(reason).." also he is size "..tostring(self.size))
	--self:grow()
	--return false
	
	--self.powerupstate = "small"
	--self.powerdowntargetstate = "death"
	
	self.animationmisc = self.animationstate
	if self.animation --[[and self.animation ~= "invincible"]] then
		return
	end
	local pointstoadd=1000
	local soundtoplay="mushroomeat"
	local animationtodo="grow2"
	local makeinvincible=false
	local makeunduck=false
	
	self.powerupstate = poweruptype
	self.powerdowntargetstate = powerdowntarget
	
	if poweruptype == "super" then
		if self.size == 1 then
			self.y = self.y - 12/16
			animationtodo = "grow1"
		elseif self.size > 2 then
			self.colors = mariocolors[self.playernumber]
			makeinvincible = true
			soundtoplay = "shrink"
		end
		self.quadcenterY = self.char.bigquadcenterY
		self.quadcenterX = self.char.bigquadcenterX
		self.offsetY = self.char.bigoffsetY
		self.graphic = self.biggraphic
		self.size = 2
		self.height = 24/16
	elseif poweruptype == "fire" then
		if self.size == 1 then
			self.y = self.y - 12/16
			animationtodo = "grow1"
		end
		self.size = 3
		self.quadcenterY = self.char.bigquadcenterY
		self.quadcenterX = self.char.bigquadcenterX
		self.offsetY = self.char.bigoffsetY
		self.graphic = self.biggraphic
		self.height = 24/16
		self.colors = self.char.flowercolor or flowercolor
	elseif poweruptype == "small" then
		--@WARNING: incomplete
		makeinvincible = true
		self.graphic = self.smallgraphic
		self.colors = mariocolors[self.playernumber]
		self.size = 1
		self.height = 12/16
		soundtoplay = "shrink"
		animationtodo = "shrink"
		pointstoadd = false
		
		self.raccoontimer = 0
		self.raccoonascendtimer = 0
		
		self.y = self.y + 12/16
		self.height = 12/16
	elseif poweruptype == "death" then
		animationtodo=false
		soundtoplay=false
		pointstoadd=false
		self:die(reason)
	end
	
	if self.ducking and makeunduck then
		self:duck(false)
	end
	
	if animationtodo~=false then
		self.animationtimer = 0
		self.drawable = true
		self.animation = animationtodo
		noupdate = true
	end
	if pointstoadd~=false then
		self:getscore(pointstoadd, self.x+self.width/2, self.y)
	end
	if soundtoplay~=false then
		playsound(soundtoplay, self.x, self.y, self.speedx, self.speedy)
	end
	if makeinvincible then
		self:goinvincible()
	end
end

function player:washurt(reason)
	print("Mario was hurt because '"..reason.."' also he is size "..tostring(self.size))
	if self.powerdowntargetstate=="super" then
		self:getpowerup(self.powerdowntargetstate, "small", reason)
	else
		self:getpowerup(self.powerdowntargetstate, nil, reason)
	end
end

function player:floorcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "floor") then
		return false
	end
	
	self.rainboomallowed = true
	
	local anim = self.animationstate
	local jump = self.jumping
	local fall = self.falling
	
	if self.char.dbljmppls then
		self.dbljmping = false
	end
	
	if a == "spring" then
		self:hitspring(b)
		return false
	end

	if a == "pswitch" then
		self:hitpswitch(b)
		return false
	end
	
	if self.speedx == 0 then
		self.animationstate = "idle"
	else
		if self.animationstate ~= "sliding" then
			self.animationstate = "running"
		end
	end
	
	if a == "tile" then
		local x, y = b.cox, b.coy
		self.lastground = {x, y}
		if bigmario and self.speedy > 2 then
			self:destroyblock(x, y)
			self.speedy = self.speedy/10
		end
		
		--check for invisible block
		if tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
			self.jumping = jump
			self.falling = fall
			self.animationstate = anim
			return false
		end
		
		if self.falling and self.raccoontimer > 0 and self.controlsenabled then
			self.speedx = self.speedx * 0.5
			self.raccoonascendtimer = 0
		end
	end
	
	--star logic
	if self.starred or bigmario then
		if self:starcollide(a, b, c, d) then
			return false
		end
	end
	
	self.falling = false
	self.jumping = false
	
	--Make mario snap to runspeed if at walkspeed.
	--Without the ducking check, this would cause mario to slide indefinitely.
	--So if mario isn't slowing down, this might be why.
	if self.binds.control.playerRun and not self.ducking then
		if self.binds.control.playerLeft and self.speedx <= -maxwalkspeed then
			self.speedx = -maxrunspeed
			self.animationdirection = "left"
		elseif self.binds.control.playerRight and self.speedx >= maxwalkspeed then
			self.speedx = maxrunspeed
			self.animationdirection = "right"
		end
	end
	
	if b.rideable then -- Enemy Riding
		self.y = b.y - self.height
		if not self.binds.control.playerLeft and self.speedx <= b.speedx and
		self.animationstate ~= "sliding" and self.jumping == false and self.falling == false and
		self.running == false and self.walking == false	then
			self.speedx = b.speedx
			self.animationstate = "idle"
		elseif not self.binds.control.playerRight and self.speedx >= b.speedx and 
		self.animationstate ~= "sliding" and self.jumping == false and self.falling == false and
		self.running == false and self.walking == false	then
			self.speedx = b.speedx
			self.animationstate = "idle"
		end
	end
	
	if b.stompable then
		self:stompenemy(a, b, c, d)
		return false
	elseif a == "tile" then
		local x, y = b.cox, b.coy
		
		if map[x][y].gels and map[x][y].gels.top == 1 then
			if self:bluegel("top") then
				return false
			end
		end
	elseif b.kills or b.killsontop then
		if self.invincible then
			self.jumping = jump
			self.falling = fall
			self.animationstate = anim
			return false
		else
			self:murder(b, b.doesdamagetype, "enemy")
			return false
		end
	elseif a == "lightbridgebody" and b.gels.top == 1 then
		if self:bluegel("top") then
			return false
		end
	end		
	
	self.combo = 1
end

function player:bluegel(dir)
	if dir == "top" then
		if self.binds.control.playerDown == false and self.speedy > gdt*yacceleration*10 then
			self.speedy = -self.speedy
			self.falling = true
			self.animationstate = "jumping"
			self:setquad()
			self.speedy = self.speedy + (self.gravity or yacceleration)*gdt
			
			return true
		end
	elseif dir == "left" then
		if self.binds.control.playerDown == false and (self.falling or self.jumping) then
			if self.speedx > horbounceminspeedx then
				self.speedx = math.min(-horbouncemaxspeedx, -self.speedx*horbouncemul)
				self.speedy = math.min(self.speedy, -horbouncespeedy)
				
				return true
			end
		end
	elseif dir == "right" then
		if self.binds.control.playerDown == false and (self.falling or self.jumping) then
			if self.speedx < -horbounceminspeedx then
				self.speedx = math.min(horbouncemaxspeedx, -self.speedx*horbouncemul)
				self.speedy = math.min(self.speedy, -horbouncespeedy)
				
				return false
			end
		end
	end
end

function player:getcombo(val, ctype, x, y, grantlife)
	val = val or 0
	x = x or self.x
	y = y or self.y
	grantlife = grantlife or false
	--print("DEBUG: givecombo called")
	if val >= 0 then
		-- I'm not sure if this logic is faster than:
		-- local comboindex = self.combo-(self.combo%#mariocombo)
		local comboindex = 1
		if combo_enums[ctype]==nil then print("WHOA: NO COMBOTYPE FOR ", ctype) end
		local maxcombo = #combo_enums[ctype]
		if self.combos[ctype] > maxcombo then
			comboindex = maxcombo
		else
			comboindex = self.combos[ctype]
		end
		
		if comboindex == maxcombo and grantlife then
			self:getlife(1, true)
		else
			self:getscore(combo_enums[ctype][comboindex], x, y)
		end
		self.combos[ctype] = self.combos[ctype] + val
		--print("NOTE: combo is", self.combo, "was", self.combo-val)
	else -- negative one, etc destroys combo
		print("DEBUG: Combo broken via getcombo.")
		self.combos[ctype] = 1
	end
end

function player:stompenemy(a, b, c, d, side)
	--[[
		crazy parameter demystification
		
		a		== type, physics calc
		b		== reference to the object stomped
		c		== ??? physics calc
		d		== ??? physics calc
		side	== a bool as to whether or not 
	]]
	if not b then
		return
	end
	
	local bounce = false
	
	b:do_damage("stomp", self) --we do this regardless of the code paths below
	
	local combonum = 1
	if b.stompcombosuppressor then
		combonum = 0
	end
	
	if b.shellanimal then
		if b.small then	
			if b.speedx == 0 then
				print("ALERT: Crazy edge case happened, just wanted you to know.")
				--[[playsound("shot", self.x, self.y, self.speedx, self.speedy)
				addpoints(500, b.x, b.y)
				self.combo = 1]]
			end
		end
		
		if b.speedx == 0 or (b.flying and b.small == false) then
			self:getcombo(combonum, "stomp", b.x, b.y, false) --@DEV: no lives because we hate america
			
			local grav = self.gravity or yacceleration
			
			local bouncespeed = math.sqrt(2*grav*bounceheight)
			
			self.speedy = -bouncespeed
			
			self.falling = true
			self.animationstate = "jumping"
			self:setquad()
			if not side then
				self.y = b.y - self.height-1/16
			end
		elseif b.x > self.x then
			b.x = self.x + b.width + self.speedx*gdt + 0.05
			local col = checkrect(b.x, b.y, b.width, b.height, {"tile"})
			if #col > 1 then
				b.x = objects[col[1] ][col[2] ].x-b.width
				bounce = true
			end
		else
			b.x = self.x - b.width + self.speedx*gdt - 0.05
			local col = checkrect(b.x, b.y, b.width, b.height, {"tile"})
			if #col > 1 then
				b.x = objects[col[1] ][col[2] ].x+1
				bounce = true
			end
		end
	elseif b.stompable then
		self:getcombo(combonum, "stomp", b.x, b.y, true)
		--@TODO: eventually we'll want to make the bounce flag controlled by the enemy as "canbounce"
		bounce = true
	end
	
	if bounce then
		local grav = self.gravity or yacceleration
		
		local bouncespeed = math.sqrt(2*grav*bounceheight)
		
		self.animationstate = "jumping"
		self.falling = true
		self:setquad()
		
		self.speedy = -bouncespeed
	end
end

function player:rightcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "right") then
		return false
	end
	
	allowskip = self.gravitydirection == math.pi/2
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	--star logic
	if self.starred or bigmario then
		if self:starcollide(a, b, c, d) then
			return false
		end
	end
	
	if self.speedy > 2 and b.stompable then
		self:stompenemy(a, b, c, d, true)
		return false
	elseif b.kills or b.killsonsides or a == "bowser" then --KILLS
		if self.invincible then
			if b.shellanimal and b.small and b.speedx == 0 then
				b:do_damage("stomp", self, "right")
				--playsound("shot", self.x, self.y, self.speedx, self.speedy)
				--addpoints(500, b.x, b.y)
			end
			return false
		else
			if self.raccoonspinframe then
				b:do_damage("tailspin", self, "right")
				--b:shotted("right", true, true)
				--addpoints(firepoints[b.t] or 100, self.x, self.y)
				return false
			end
			
			if b.shellanimal and b.small and b.speedx == 0 then
				print("NOTE: Kicked a koopa shell, how exciting.")
				b:do_damage("stomp", self, "right")
				--playsound("shot", self.x, self.y, self.speedx, self.speedy)
				return false
			end
			
			--Check if Mario is walking off a ridable enemy, so that he can safely walk off.
			if b.rideable and self.y <= b.y - (.005 + (self.height - .75)) then 
				self.y = b.y - self.height
				self.speedy = 0
				print("Giving leeway to Mario's Position (Right)")
				print(self.height)
				return false
			end
			
			self:murder(b, b.doesdamagetype, "Enemy (rightcollide)")
			return false
		end
	elseif a == "tile" then
		local x, y = b.cox, b.coy
			
		if map[x][y].gels and map[x][y].gels.left == 1 then
			if self:bluegel("left") then
				return false
			end
		end
		
		--check for invisible block
		if tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
			return false
		end
		
		--Check if it's a pipe with pipe pipe.
		if self.falling == false and self.jumping == false and (self.binds.control.playerRight or intermission) then --but only on ground and rightkey
			local t2 = map[x][y][2]
			if t2 and entitylist[t2] and entitylist[t2].t == "warppipe" and map[x][y][8] then
				self:pipe(x, y, "right", map[x][y])
				return
			else
				if inmap(x, y+1) then
					t2 = map[x][y+1][2]
					if t2 and entitylist[t2] and entitylist[t2].t == "warppipe" and map[x][y][8] then
						self:pipe(x, y+1, "right", map[x][y+1])
						return
					end
				end
			end
		end
		
		--Check if mario should run across a gap.
		if allowskip and inmap(x, y-1) and tilequads[map[x][y-1][1]]:getproperty("collision", x, y-1) == false and self.speedy > 0 and self.y+self.height+1 < y+spacerunroom then
			self.y = b.y - self.height
			self.speedy = 0
			self.x = b.x-self.width+0.0001
			self.falling = false
			self.animationstate = "running"
			self:setquad()
			return false
		end
		
		if bigmario then
			self:destroyblock(x, y)
			return false
		end
	elseif a == "box" and self.gravitydirection == math.pi/2 then
		if self.speedx > maxwalkspeed/2 then
			self.speedx = self.speedx - self.speedx * 6 * gdt
		end
		
		--check if box can even move
		local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b}, true)
		if #out == 0 then
			b.speedx = self.speedx
			return false
		end
	elseif a == "button" then
		self.y = b.y - self.height
		self.x = b.x - self.width+0.001
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "lightbridgebody" and b.gels.left == 1 then
		if self:bluegel("left") then
			return false
		end
	end
	
	if self.falling == false and self.jumping == false then
		self.animationstate = "idle"
		self:setquad()
	end
end

function player:leftcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "left") then
		return false
	end
	
	allowskip = self.gravitydirection == math.pi/2
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	--star logic
	if self.starred or bigmario then
		if self:starcollide(a, b, c, d) then
			return false
		end
	end
	
	if self.speedy > 2 and b.stompable then
		self:stompenemy(a, b, c, d, true)
		return false
	elseif b.kills or b.killsonsides or a == "bowser" then --KILLS
		if self.invincible then
			if b.shellanimal and b.small and b.speedx == 0 then
				b:do_damage("stomp", self)
				--playsound("shot", self.x, self.y, self.speedx, self.speedy)
				--addpoints(500, b.x, b.y)
			end
			return false
		else
			if self.raccoonspinframe then
				b:do_damage("tailspin", self)
				--b:shotted("left", true, true)
				--addpoints(firepoints[b.t] or 100, self.x, self.y)
				return false
			end
			
			if b.shellanimal and b.small and b.speedx == 0 then
				b:do_damage("stomp", self)
				--playsound("shot", self.x, self.y, self.speedx, self.speedy)
				--addpoints(500, b.x, b.y)
				return false
			end
			
			--Check if Mario is walking off a ridable enemy, so that he can safely walk off.
			if b.rideable and self.y <= b.y - (.005 + (self.height - .75)) then 
				self.y = b.y - self.height
				self.speedy = 0
				print("Giving leeway to Mario's Position (Left)")
				print(self.height)
				return false
			end
			
			
			self:murder(b, b.doesdamagetype, "Enemy (leftcollide)")
			return false
		end
	elseif a == "tile" then
		local x, y = b.cox, b.coy
		
		if map[x][y].gels and map[x][y].gels.right == 1 then
			if self:bluegel("right") then
				return false
			end
		end
		
		--check for invisible block
		if tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
			return false
		end
		
		--Check if it's a pipe with pipe pipe.
		--@WARNING: If anything breaks in an intermission, it's because we did put this here.
		if not self.falling and not self.jumping and (self.binds.control.playerLeft or intermission) then --but only on ground and leftkey
			local t2 = map[x][y][2]
			if t2 and entitylist[t2] and entitylist[t2].t == "warppipe" and map[x][y][8] then
				self:pipe(x, y, "left", map[x][y])
				return
			else
				if inmap(x, y+1) then
					t2 = map[x][y+1][2]
					if t2 and entitylist[t2] and entitylist[t2].t == "warppipe" and map[x][y+1][8] then
						self:pipe(x, y+1, "left", map[x][y+1])
						return
					end
				end
			end
		end
		
		--Check if mario should run across a gap.
		if allowskip and inmap(x, y-1) and tilequads[map[x][y-1][1]]:getproperty("collision", x, y-1) == false and self.speedy > 0 and self.y+1+self.height < y+spacerunroom then
			self.y = b.y - self.height
			self.speedy = 0
			self.x = b.x+1-0.0001
			self.falling = false
			self.animationstate = "running"
			self:setquad()
			return false
		end
	
		if bigmario then
			self:destroyblock(x, y)
			return false
		end
	elseif a == "box" and self.gravitydirection == math.pi/2 then
		if self.speedx < -maxwalkspeed/2 then
			self.speedx = self.speedx - self.speedx * 6 * gdt
		end
		
		--check if box can even move
		local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b}, true)
		if #out == 0 then
			b.speedx = self.speedx
			return false
		end
	elseif a == "button" then
		self.y = b.y - self.height
		self.x = b.x + b.width - 0.001
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "lightbridgebody" and b.gels.right == 1 then
		if self:bluegel("right") then
			return false
		end
	end
	
	if self.falling == false and self.jumping == false then
		self.animationstate = "idle"
		self:setquad()
	end
end

function player:ceilcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "ceil") then
		return false
	end
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	--star logic
	if self.starred or bigmario then
		if self:starcollide(a, b, c, d) then
			return false
		end
	end
	
	if b.kills or b.killsonbottom then --STUFF THAT KILLS
		if b.shellanimal and b.small and b.speedx == 0 then
			self:stompenemy(a, b, c, d, true)
			return false
		end
		
		if self.invincible then
			return false
		else
			self:murder(b, b.doesdamagetype, "Enemy (Ceilcollided)")
			return false
		end
	elseif a == "tile" then
		local x, y = b.cox, b.coy
		local r = map[x][y]
		
		--check if it's an invisible block
		if tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
			if self.y-self.speedy <= y-1 then
				return false
			end
		else
			if bigmario then
				self:destroyblock(x, y)
				return false
			end
			
			--Check if it should bounce the block next to it, or push mario instead (Hello, devin hitch!)
			
			if self.gravitydirection == math.pi/2 then
				if self.x < x-22/16 then
					--check if block left of it is a better fit
					if x > 1 and tilequads[map[x-1][y][1]]:getproperty("collision", x-1, y) == true then
						x = x - 1
					else
						local col = checkrect(x-28/16, self.y, self.width, self.height, {"exclude", self}, true)
						if #col == 0 then
							self.x = x-28/16
							if self.speedx > 0 then
								self.speedx = 0
							end
							return false
						end					
					end
				elseif self.x > x-6/16 then
					--check if block right of it is a better fit
					if x < mapwidth and tilequads[map[x+1][y][1]]:getproperty("collision", x+1, y) == true then
						x = x + 1
					else
						local col = checkrect(x, self.y, self.width, self.height, {"exclude", self}, true)
						if #col == 0 then
							self.x = x
							if self.speedx < 0 then
								self.speedx = 0
							end
							return false
						end	
					end
				end
			end
		end

		self:hitblock(x, y)
	end
	
	self.jumping = false
	if not self.vine then
		self.falling = true
		self.speedy = headforce
	end
end

function player:globalcollide(a, b, c, d, dir)
	self.lastcollision = {a, b, c, d, dir}
	
	if a == "platform" or a == "seesawplatform" then
		if dir == "floor" then
			if self.jumping and self.speedy < -jumpforce + 0.1 then
				return true
			end
		else
			return true
		end
	end
	
	if b.collect then
		b:collect(self)
		return true
	end
	
	if a == "screenboundary" then
		if self.x+self.width/2 > b.x then
			self.x = b.x
		else
			self.x = b.x-self.width
		end
		self.speedx = 0
		if self.falling == false and self.jumping == false then
			self.animationstate = "idle"
			self:setquad()
		end
		return true
	elseif a == "vine" then
		if self.vine == false then
			self:grabvine(b)
		end
		
		return true
	elseif a == "tile" then
		--check for spikes
		if self.invincible or self.starred then
			--super mario dadada, dada-da, dada-da. dadada, dada-da, dada-da...
		else
			dir = twistdirection(self.gravitydirection, dir)
			if dir == "ceil" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesbottom", b.cox, b.coy) then
				self:murder(nil, "spike", "Spike (bottom)")
				return false
			elseif dir == "right" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesleft", b.cox, b.coy) then
				self:murder(nil, "spike", "Spike (left)")
				return false
			elseif dir == "left" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesright", b.cox, b.coy) then
				self:murder(nil, "spike", "Spike (right)")
				return false
			elseif dir == "floor" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikestop", b.cox, b.coy) then
				self:murder(nil, "spike", "Spike (top)")
				return false
			end
		end
	elseif b.ispowerup then
		self:getpowerup(b.poweruptype, b.powerdowntarget, b.t)
		return true
	elseif b.givesalife then
		if b.lifeamount then
			givemestuff["lives"] = b.lifeamount
			givemestuff["lives"] = b.lifeamount
		end
		self:getlife(b.lifeamount or 1)
		return true
	elseif b.givestime then
		if b.timeamount then
			givemestuff["time"] = b.timeamount
		end
		givetime(self.playernumber, b)
		return true
	elseif b.istrophy then
		oddjobquotas[2] = 1
		gotatrophy(self.playernumber, b)
		return true
	elseif b.givecoinoncollect then
		self:getcoin(b.givecoinoncollect)--@WARNING: I left out x, y because that would collect the coin at wherever the enemy is
		return true
	elseif b.makesmariostar then
		self:star()
		return true
	end
end

function twistdirection(gravitydir, dir)
	if not gravitydir or (gravitydir > math.pi/4*1 and gravitydir <= math.pi/4*3) then
		if dir == "floor" then
			return "floor"
		elseif dir == "left" then
			return "left"
		elseif dir == "ceil" then
			return "ceil"
		elseif dir == "right" then
			return "right"
		end
	elseif gravitydir > math.pi/4*3 and gravitydir <= math.pi/4*5 then
		if dir == "floor" then
			return "left"
		elseif dir == "left" then
			return "ceil"
		elseif dir == "ceil" then
			return "right"
		elseif dir == "right" then
			return "floor"
		end
	elseif gravitydir > math.pi/4*5 and gravitydir <= math.pi/4*7 then
		if dir == "floor" then
			return "ceil"
		elseif dir == "left" then
			return "right"
		elseif dir == "ceil" then
			return "floor"
		elseif dir == "right" then
			return "left"
		end
	else
		if dir == "floor" then
			return "right"
		elseif dir == "left" then
			return "floor"
		elseif dir == "ceil" then
			return "left"
		elseif dir == "right" then
			return "ceil"
		end
	end
end

function player:passivecollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "passive") then
		return false
	end
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	if a == "box" then
		if self.speedx < 0 then
			if self.speedx < -maxwalkspeed/2 then
				self.speedx = self.speedx - self.speedx * 0.1
			end
			
			--check if box can even move
			local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b})
			if #out == 0 then	
				b.speedx = self.speedx
				return false
			end
		else
			if self.speedx > maxwalkspeed/2 then
				self.speedx = self.speedx - self.speedx * 6 * gdt
			end
			
			--check if box can even move
			local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b})
			if #out == 0 then	
				b.speedx = self.speedx
				return false
			end
		end
	end
	if self.passivemoved == false then
		self.passivemoved = true
		if a == "tile" or a == "portalwall" then
			if a == "tile" then
				local x, y = b.cox, b.coy
				
				--check for invisible block
				if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("invisible", x, y) then
					return false
				end
			end
			if self.pointingangle < 0 then
				self.x = self.x - passivespeed*gdt
			else
				self.x = self.x + passivespeed*gdt
			end
			self.speedx = 0
		else
			--nothing, lol.
		end
	end
	
	
	self:rightcollide(a, b, c, d)
end

function player:starcollide(a, b, c, d)
	--enemies that die
	if a == "enemy" then
		b:do_damage("star",self,"right")
		--b:shotted("right", nil, nil, false, true)
		--addpoints(firepoints[b.t] or 100, self.x, self.y)
		return true
		--@DEV: we're gonna ignore those special exceptions right now
	--elseif a == "bowser" then
		--b:shotted("right")
		--return true
	--enemies (and stuff) that don't do shit
	--elseif a == "upfire" or a == "fire" or a == "hammer" or a == "fireball" or a == "castlefirefire" then
		--return true
	end
end

function player:hitspring(b)
	b:hit()
	self.springb = b
	self.springx = self.x
	self.springy = b.coy
	self.speedy = 0
	self.spring = true
	self.springhigh = false
	self.springtimer = 0
	self.gravity = 0
	self.mask[19] = true
	self.animationstate = "idle"
	self:setquad()
end

function player:hitpswitch(b)
	b:hit()
end

function player:leavespring()
	self.y = self.springy - self.height-31/16
	if self.springhigh then
		if self.springb.type == "vanilla" then  -- Regular Springboard
			self.speedy = -springhighforce
		elseif self.springb.type == "high" then  -- High Springboard
			self.speedy = -springhighhighforce
		else 
			self.speedy = -springhighforce	
		end
	else
		self.speedy = -springforce
	end
	self.animationstate = "falling"
	self:setquad()
	self.gravity = yacceleration
	self.falling = true
	self.spring = false
	self.mask[19] = false
end

function player:dropvine(dir)
	if dir == "right" then
		self.x = self.x + 8/16
	else
		self.x = self.x - 6/16
	end
	self.y = self.y - self.height + 12/16
	self.animationstate = "falling"
	self:setquad()
	self.gravity = mariogravity
	self.vine = false
	self.mask[18] = false
end

function player:grabvine(b)
	if self.ducking then
		self:duck(false)
	end
	if insideportal(self.x, self.y, self.width, self.height) then
		return
	end
	self.mask[18] = true
	self.vine = b
	self.gravity = 0
	self.speedx = 0
	self.speedy = 0
	self.animationstate = "climbing"
	self.climbframe = 2
	self.vinemovetimer = 0
	self:setquad()
	self.vinex = b.cox
	self.viney = b.coy
	if b.x > self.x then --left of vine
		self.x = b.x+b.width/2-self.width+1/16
		self.pointingangle = -math.pi/2
		self.animationdirection = "right"
		self.vineside = "left"
	else --right
		self.x = b.x+b.width/2 - 3/16
		self.pointingangle = math.pi/2
		self.animationdirection = "left"
		self.vineside = "right"
	end
end

function player:hitblock(x, y)
	hitblock(x, y, self)
end

function hitblock(x, y, t, koopa)	
	for i, v in pairs(t.world.objects.portal) do
		if v.x1 and v.x2 and v.y1 and v.y2 then
			local x1 = v.x1
			local y1 = v.y1
			
			local x2 = v.x2
			local y2 = v.y2
			
			local x3 = x1
			local y3 = y1
			
			if v.facing1 == "up" then
				x3 = x3+1
			elseif v.facing1 == "right" then
				y3 = y3+1
			elseif v.facing1 == "down" then
				x3 = x3-1
			elseif v.facing1 == "left" then
				y3 = y3-1
			end
			
			local x4 = x2
			local y4 = y2
			
			if v.facing2 == "up" then
				x4 = x4+1
			elseif v.facing2 == "right" then
				y4 = y4+1
			elseif v.facing2 == "down" then
				x4 = x4-1
			elseif v.facing2 == "left" then
				y4 = y4-1
			end
			
			if (x == x1 and y == y1) or (x == x2 and y == y2) or (x == x3 and y == y3) or (x == x4 and y == y4) then
				return
			end
		end
	end


	if editormode then
		return
	end

	if not t.world:inmap(x, y) then
		return
	end
	
	local r = t.world.map[x][y]
	if not t or not t.infunnel then
		playsound("blockhit", x-0.5, y-1)
	end
	
	if tilequads[r[1]]:getproperty("breakable") == true or tilequads[r[1]]:getproperty("coinblock") == true then --Block should bounce!
		local pblock
		local do_destroy = (koopa or (t and t.size > 1)) and 
							tilequads[r[1]]:getproperty("coinblock") == false and 
							(#r == 1 or (entitylist[r[2]] and entitylist[r[2]].t ~= "manycoins"))
		if not t.world.objects.pseudoblock[x.."-"..y] then
			pblock = pseudoblock:new(x, y, r, t.world, do_destroy)
			t.world.objects.pseudoblock[x.."-"..y] = pblock
		else
			pblock = t.world.objects.pseudoblock[x.."-"..y]
		end
		
		pblock:hit(t, do_destroy)
	end
end

function player:goinvincible()
	self.animationstate = self.animationmisc
	self.animation = "invincible"
	self.invincible = true
	noupdate = false
	if self.size==1 then
		self.quadcenterY = self.char.smallquadcenterY
		self.quadcenterX = self.char.smallquadcenterX
		self.offsetY = self.char.smalloffsetY
	else
		self.quadcenterY = self.char.bigquadcenterY
		self.quadcenterX = self.char.bigquadcenterX
		self.offsetY = self.char.bigoffsetY
	end
	self.animationtimer = 0
	
	self.drawable = true
end

function player:destroyblock(x, y)
	return destroyblock(x, y, self)
end

function destroyblock(x, y, t)
	for i = 1, players do
		local v = objects["player"][i].portal
		local x1 = v.x1
		local y1 = v.y1
		
		local x2 = v.x2
		local y2 = v.y2
		
		local x3 = x1
		local y3 = y1
		
		if v.facing1 == "up" then
			x3 = x3+1
		elseif v.facing1 == "right" then
			y3 = y3+1
		elseif v.facing1 == "down" then
			x3 = x3-1
		elseif v.facing1 == "left" then
			y3 = y3-1
		end
		
		local x4 = x2
		local y4 = y2
		
		if v.facing2 == "up" then
			y4 = y4-1
		elseif v.facing2 == "right" then
			x4 = x4+1
		elseif v.facing2 == "down" then
			y4 = y4+1
		elseif v.facing2 == "left" then
			x4 = x4-1
		end
		
		if (x == x1 and y == y1) or (x == x2 and y == y2) or (x == x3 and y == y3) or (x == x4 and y == y4) then
			return
		end
	end
	
	map[x][y][1] = 1
	objects["tile"][x .. "-" .. y] = nil
	map[x][y]["gels"] = {}
	playsound("blockbreak", x, y) --blocks don't move, we want the position of the block
	
	traceinfluence(t):getscore(score_enum.block_break, x-0.5, y-1)
	
	blockdebris:new(x, y, "right", 1)
	blockdebris:new(x, y, "right", 0)
	blockdebris:new(x, y, "left", 1)
	blockdebris:new(x, y, "left", 0)
	
	generatespritebatch()
end

function player:faithplate(dir)
	self.animationstate = "jumping"
	self.falling = true
	self:setquad()
end

function player:startfall()
	if self.falling == false then
		self.falling = true
		self.animationstate = "falling"
		self:setquad()
	end
end
function traceinfluence(b)
	if not b then return nil end
	
	if b.getcoin then
		return b
	elseif b.lastinfluence then
		return b.lastinfluence
	else
		print("CRITICAL: Couldn't trace an influence from", b)
		return b
	end
end
function player:murder(attacker, dtype, how)
	--print("moyided", traceinfluence(attacker), dtype, how)
	killfeed.new(traceinfluence(attacker), dtype, self)
	self:die(how)
end

function player:die(how)
	print("Mario was told to die because '"..how.."' also he is size "..tostring(self.size))
	if self.dead then 
		return
	end
	if editormode then
		self.y = 0
		self.speedy = 0
		return
	end
	
	
	if how ~= "pit" and how ~= "time" then
		if self.size > 1 then
			self:washurt(how)
			return
		end
	elseif how ~= "time" then
		if bonusstage then
			levelscreen_load("sublevel", 0)
			return
		end
	end
	
	self.dead = true
	
	if self.pickup then
		self:drop_held()
	end
	
	if not arcade then
		everyonedead = true
		for i = 1, players do
			if not objects["player"][i].dead then
				everyonedead = false
			end
		end
	end
	
	self.animationmisc = false
	if everyonedead then
		self.animationmisc = "everyonedead"
		love.audio.stop()
	end
	
	playsound("death", self.x, self.y) --happens at a point, therefore velocity gets binned
	
	if how == "time" then
		noupdate = false
		self.quadcenterY = self.char.smallquadcenterY
		self.graphic = self.smallgraphic
		self.size = 1
		self.quadcenterX = self.char.smallquadcenterX
		self.offsetY = self.char.smalloffsetY
		self.drawable = true
	end
	
	if how == "pit" then
		self.animation = "deathpit"
		self.size = 1
		self.drawable = false
		self.invincible = false
	else
		self.animation = "death"
		self.drawable = true
		self.invincible = false
		self.animationstate = "dead"
		self:setquad()
		self.speedy = 0
	end
	
	self.y = self.y - 1/16
	
	self.animationx = self.x
	self.animationy = self.y
	self.infunnel = false
	self.animationtimer = 0
	self.controlsenabled = false
	self.active = false
	prevsublevel = false
	
	if not levelfinished and not testlevel and not infinitelives and mariolivecount ~= false and not arcade and not mkstation then
		self.lives = self.lives - 1
	end
	return
end

function player:laser(dir)
	if self.pickup then
		if dir == "right" and self.pointingangle < 0 then
			return
		elseif dir == "left" and self.pointingangle > 0 then
			return
		elseif dir == "up" and self.pointingangle > -math.pi/2 and self.pointingangle < math.pi/2 then
			return
		elseif dir == "down" and (self.pointingangle > math.pi/2 or self.pointingangle < -math.pi/2) then
			return
		end
	end
	self:murder(nil, "laser", "Laser")
end

function getAngleFrame(angle, rotation)
	angle = angle + rotation

	if angle > math.pi then
		angle = angle - math.pi*2
	elseif angle < -math.pi then
		angle = angle + math.pi*2
	end

	local mouseabs = math.abs(angle)
	local angleframe
	
	if mouseabs < math.pi/8 then
		angleframe = 1
	elseif mouseabs >= math.pi/8 and mouseabs < math.pi/8*3 then
		angleframe = 2
	elseif mouseabs >= math.pi/8*3 and mouseabs < math.pi/8*5 then
		angleframe = 3
	elseif mouseabs >= math.pi/8*5 and mouseabs < math.pi/8*7 then
		angleframe = 4
	elseif mouseabs >= math.pi/8*7 then
		angleframe = 4
	end
	
	return angleframe
end

function player:emancipate(a)
	self:removeportals()
	
	local delete = {}
	
	for i, v in pairs(objects["portalprojectile"]) do
		if v.payload[1] == self.playernumber then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(objects["portalprojectile"], v) --remove
	end
	
	if self.pickup then
		self.pickup:emancipate()
	end
end

function player:removeportals(i)
	if self.portalsavailable[1] or self.portalsavailable[2] then
		playsound("portalfizzle", self.x, self.y, self.speedx, self.speedy) --play locally in addition to the portal positions as confirmation that it happened, otherwise, nothing
	end
	
	if self.portalsavailable[1] then
		self.portal:removeportal(1)
	end
	if self.portalsavailable[2] then
		self.portal:removeportal(2)
	end
end

function player:use(xcenter, ycenter)
	if not xcenter then
		xcenter = self.x + 6/16 - math.sin(self.pointingangle)*userange
		ycenter = self.y + 6/16 - math.cos(self.pointingangle)*userange
	end
	
	if self.pickup then
		if self.pickup.destroy then
			self.pickup = false
		else
			self:drop_held()
			return
		end
	end
	
	-- this used to be the check userect function but we murdered it
	for i, v in pairs(objects["userect"]) do
		if aabb(
			xcenter-usesquaresize/2,
			ycenter-usesquaresize/2,
			usesquaresize, usesquaresize,
			v.x, v.y, v.width, v.height) then
			v.parent:used(self)
			break
		end
	end
end

function player:pick_up(itm)
	self.pickup = itm
end

function player:drop_held()
	self.pickup:setSpeed(self.speedx, self.speedy, 0) --@WARNING: dummied Z
	self.pickup.gravitydirection = self.gravitydirection
	
	local set = false
	
	local boxx = self.x+math.sin(-self.pointingangle)*0.3
	local boxy = self.y-math.cos(-self.pointingangle)*0.3
	
	if self.pointingangle < 0 then
		if #checkrect(self.x+self.width, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x+self.width
			self.pickup.y = self.y+self.height-12/16
			set = true
		end
	else
		if #checkrect(self.x-12/16, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x-12/16
			self.pickup.y = self.y+self.height-12/16
			set = true
		end
	end
	
	if set == false then
		if #checkrect(self.x+self.width, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x+self.width
			self.pickup.y = self.y+self.height-12/16
		elseif #checkrect(self.x-12/16, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x-12/16
			self.pickup.y = self.y+self.height-12/16
		elseif #checkrect(self.x, self.y+self.height, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x
			self.pickup.y = self.y+self.height
		elseif #checkrect(self.x, self.y-12/16, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x
			self.pickup.y = self.y-12/16
		else
			self.pickup.x = self.x
			self.pickup.y = self.y
		end
	end
	
	for h, u in pairs(objects["emancipationgrill"]) do
		if u.dir == "hor" then
			if inrange(self.pickup.x+6/16, u.startx-1, u.endx, true) and inrange(u.coy-14/16, boxy, self.pickup.y, true) then
				self.pickup:emancipate(h)
			end
		else
			if inrange(self.pickup.y+6/16, u.starty-1, u.endy, true) and inrange(u.cox-14/16, boxx, self.pickup.x, true) then
				self.pickup:emancipate(h)
			end
		end
	end
	self.pickup:drop()
	self.pickup = nil
end

function player:cubeemancipate()
	self.pickup = false
end

function player:duck(ducking) --goose
	if self.infunnel then
		self.ducking = false
		return
	else
		self.ducking = ducking
	end
	
	if self.ducking then
		self.raccoonspinframe = false
		self.y = self.y + 12/16
		self.height = 12/16
		self.quadcenterY = self.char.duckquadcenterY
		self.offsetY = self.char.duckoffsetY
	else
		self.y = self.y - 12/16
		self.height = 24/16
		self.quadcenterY = self.char.bigquadcenterY
		self.offsetY = self.char.bigoffsetY
	end
end

function player:pipe(x, y, dir, ex)
	if editormode then
		return
	end
	print("piped", x, y, dir, ex)

	-- ex == the pipe data
	self.active = false
	self.infunnel = false
	self.animation = "pipe_" .. dir .."_in"
	self.invincible = false
	self.drawable = true
	self.animationx = x
	self.animationy = y
	self.animationtimer = 0
	if ex then
		self.animationmisc = ex
	end
	self.controlsenabled = false
	playsound("pipe", x, y) --pipe cancels out movement, using velocity would be "throwing one's voice"
	
	if intermission then
		respawnsublevel = i
	end
	
	if dir == "down" then
		if self.size > 1 then
			self.animationy = y - self.height + 12/16
		end
		self.animationstate = "idle"
		self.customscissor = {x-4, y-3, 6, 2}
	elseif dir == "right" then
		self.y = self.animationy-1/16 - self.height
		self.animationstate = "running"
		self.customscissor = {x-2, y-5, 1, 6}
	elseif dir == "left" then
		self.y = self.animationy-1/16 - self.height
		self.animationstate = "running"
		self.customscissor = {x, y-5, 1, 6}
	elseif dir == "up" then
		self.animationy = y - 20/16
		self.animationstate = "idle"
		self.customscissor = {x+2.5, y+4, -6, -4}
	end
	
	self:setquad()
end

function player:savereplaydata()
	local i = 1
	while love.filesystem.exists("replay" .. i .. ".txt") do
		i = i + 1
	end
	
	local rep = {data=livereplaydata[self.playernumber]}
	
	local s = JSON:encode(rep)
	love.filesystem.write("replay" .. i .. ".txt", s)
	
	
	for j = 2, #rep.data do
		for k, v in pairs(rep.data[j-1]) do
			if rep.data[j][k] == nil then
				rep.data[j][k] = v
			end
		end
	end
	
	table.insert(replaydata, rep)
	
	replaytimer[#replaydata] = 0
	replayi[#replaydata] = 0
	replaychar[#replaydata] = characters.mario
	
	for i = 1, #replaydata do
		replayi[i] = 1
	end
end

function player:flag()	
	for i = 1, players do
		objects["player"][i].invincible = true
	end
	
	if levelfinished then
		return
	end
	
	self.raccoontimer = 0
	self.ducking = false
	self.animation = "flag"
	self.drawable = true
	self.controlsenabled = false
	self.animationstate = "climbing"
	self.pointingangle = -math.pi/2
	self.animationdirection = "right"
	self.animationtimer = 0
	self.speedx = 0
	self.speedy = 0
	self.x = flagx-2/16
	self.gravity = 0
	self.climbframe = 2
	self.active = false
	self.infunnel = false
	self:setquad()
	levelfinished = true
	levelfinishtype = "flag"
	subtractscore = false
	dofirework = false
	castleflagy = castleflagstarty
	objects["screenboundary"]["flag"].active = false
	
	--get score
	flagscore = flagscores[1]
	for i = 1, #flagvalues do
		if self.y < flagvalues[i]-13+flagy then
			flagscore = flagscores[i+1]
		else
			break
		end
	end
	
	self:getscore(flagscore)
	
	--get firework count
	fireworkcount = tonumber(string.sub(math.ceil(mariotime), -1, -1))
	if fireworkcount ~= 1 and fireworkcount ~= 3 and fireworkcount ~= 6 then
		fireworkcount = 0
	end
	
	if portalbackground then
		fireworkcount = 0
	end
	
	love.audio.stop()
	
	
	playsound("levelend", self.x, self.y, self.speedx, self.speedy)
end

function player:vineanimation()
	self.infunnel = false
	self.animation = "vine"
	self.invincible = false
	self.drawable = true
	self.controlsenabled = false
	self.animationx = self.x
	self.animationy = vineanimationstart
	self.animationmisc = map[self.vinex][self.viney][3]-1
	self.active = false
	self.vine = false
end

function player:star()
	self:getscore(score_enum.collect_star)
	self.startimer = 0
	self.colors = self.profile.starcolors[1]
	self.starred = true
	w:stopmusic()
	w:playmusic("starmusic.ogg")
end

function player:fire()
	if (not noupdate and self.animation ~= "grow1" and self.animation ~= "grow2") and self.char.raccoon and self.size >= 2 and not self.ducking and not self.raccoonspinframe then --Wiggle wiggle wag wag
		self.raccoonspinframe = 1
		self.raccoonspintimer = 0
		
		self:spinhit(self.x+self.width+.75, self.y+self.height-.5, "right")
		self:spinhit(self.x-.75, self.y+self.height-.5, "left")
	end
	if (not noupdate and self.animation ~= "grow1" and self.animation ~= "grow2") and self.controlsenabled and self.powerupstate == "fire" and self.ducking == false then
		if self.fireballcount < maxfireballs then
			local dir = "right"
			local mul = 1
			if (self.portalsavailable[1] or self.portalsavailable[2]) then
				if self.pointingangle > 0 then
					dir = "left"
					mul = -1
				end
			else
				if self.animationdirection == "left" then
					dir = "left"
					mul = -1
				end
			end
			
			fireball:new(self.x, self.y, dir, self)
			
			self.fireballcount = self.fireballcount + 1
			self.fireanimationtimer = 0
			self:setquad()
		end
	end
end

function player:spinhit(x, y, dir)
	local col = checkrect(x, y, 0, 0, "all", true)
	for i = 1, #col, 2 do
		local a = col[i]
		local b = objects[a][col[i+1]]
		if a == "tile" then
			hitblock(b.cox, b.coy, self)
		else
			b:do_damage("spin", self)
			--b:shotted(dir, true, true)
			--addpoints(b.firepoints or 200, self.x, self.y)
		end
	end
end

function player:fireballcallback()
	self.fireballcount = self.fireballcount - 1
	if self.fireballcount < 0 then
		self.fireballcount = 0
		print("NOTICE: Fireball counter was bounded up to zero.")
	end
end

function player:getscore(val, x, y)
	self.score = self.score + val
	if not x and not y then
		-- score appears above us, not anywhere else
		x = self.x
		y = self.y
	end
	--@TODO: make scrollingscores a (sane/based)entity
	
	scrollingtext:new(x, y, val)
end

function player:getlife(val, x, y)
	--@WARNING: x/y underutilized
	self.lives = self.lives + val
	for i=1, val do
		playsound("oneup", self.x, self.y, self.speedx, self.speedy)
	end
end

function player:getcoin(val, x, y, passx, passy)
	if x and y and inmap(x, y) then
		-- we collected a map coin, alter it accordingly
		coinmap[x][y] = false
	end
	self:getscore(score_enum.coin, passx, passy)
	playsound("coin", self.x, self.y, self.speedx, self.speedy) --making "stick to player" because doppler is weird
	self.coins = self.coins + (val or 1)
	
	--@WARNING: this branch of code should be moved to gamemode object
	self:getlife((self.coins - (self.coins % 100))/100, x, y)
	--@NOTE: do hook trigger here for shared lives
	self.coins = self.coins % 100
end

function player:portaled(daportal, entereddir, exitdir)
	if self.pickup then
		self.pickup:portaled()
	end
	
	-- I'm not sorry for this monster, not in the slightest.
	if cheats_active.rainboom and 
		self.rainboomallowed and 
		((exitdir == "up" and self.speedy < -rainboom.basespeed) or
		(exitdir == "left" and self.speedx < -rainboom.basespeed) or
		(exitdir == "right" and self.speedx > rainboom.basespeed) or
		(exitdir == "down" and self.speedy < -rainboom.basespeed)) then
		
		rainboom:new(self.x+self.width/2, self.y+self.height/2, exitdir, self)
	end
end

function player:respawn()
	if mariolivecount ~= false and (self.lives == 0 or levelfinished) then
		return
	end
	
	local i = 1
	while i <= players and (objects["player"][i].dead or (self.playernumber == i and not arcade)) do
		i = i + 1
	end
	
	fastestplayer = objects["player"][i]
	
	local spawnx, spawny
	
	if fastestplayer then
		for i = 2, players do
			if objects["player"][i].x > fastestplayer.x and not objects["player"][i].dead then
				fastestplayer = objects["player"][i]
			end
		end
	end
	
	if fastestplayer then
		spawnx = fastestplayer.x
		spawny = fastestplayer.y + fastestplayer.height-12/16
	elseif pipestartx then
		spawnx = pipestartx-6/16
		spawny = pipestarty-1-1-12/16
	elseif startx and startx[1] then
		spawnx = startx[1]-6/16
		spawny = starty[1]-12/16
	else
		spawnx = 3
		spawny = 12
	end
	
	--Check checkpoints to see if there was a non-all checkpoint!
	if not arcade then
		local checkid = self.playernumber
		if checkid > 4 then
			checkid = 5
		end
		
		if checkpointx[checkid] then
			local checkspawn = false
			for i = 1, 5 do
				if checkpointx[i] ~= checkpointx[checkid] or checkpointy[i] ~= checkpointy[checkid] then
					checkspawn = true
					break
				end
			end
			
			if checkspawn then
				fastestplayer = {x=checkpointx[checkid], y=checkpointy[checkid],height=0}
			end
		end
	end
	
	self.colors = mariocolors[self.playernumber]
	self.speedy = 0
	self.speedx = 0
	self.dead = false
	self.quadcenterY = self.char.smallquadcenterY
	self.height = 12/16
	self.graphic = self.smallgraphic
	self.size = 1
	self.quadcenterX = self.char.smallquadcenterX
	self.offsetY = self.char.smalloffsetY
	self.drawable = true
	self.animationstate = "idle"
	self:setquad()
	
	self.animation = "invincible"
	self.invincible = true
	self.animationtimer = 0
	
	self.y = spawny
	self.x = spawnx
	
	self.jumping = false
	self.falling = true
	self.ducking = false
	
	self.controlsenabled = true
	self.active = true
end

function player:dive(water)
	if water then
		self.gravity = uwgravity
		self.underwater = true
		self.speedx = self.speedx*waterdamping
		self.speedy = self.speedy*waterdamping
	else
		self.gravity = mariogravity
		if not underwater then
			self.underwater = false
		end
		if self.speedy < 0 then
			self.speedy = -waterjumpforce
		end
	end
	self:setquad()
end

function player:enteredfunnel(inside)
	if inside then
		if self.ducking then
			self:duck(false)
		end
		self.infunnel = true
	else
		self.infunnel = false
	end
end

function player:animationwalk(dir)
	self.animation = "animationwalk"
	self.animationstate = "running"
	self.animationmisc = dir
end

function player:stopanimation()
	self.animation = false
end

function player:portalpickup(i)
	self.lastportal = i
	
	if not self.portalsavailable[1] and not self.portalsavailable[2] then
		self.biggraphic = self.char.biganimations
		self.smallgraphic = self.char.animations
		if self.size == 1 then
			self.graphic = self.smallgraphic
		else
			self.graphic = self.biggraphic
		end
	end
	
	self.portalsavailable[i] = true
end