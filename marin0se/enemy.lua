enemy = class("enemy")

function enemy:init(x, y, t, a)
	if not enemiesdata[t] then
		return nil
	end
	
	self.t = t
	if a then
		self.a = {unpack(a)}
	else
		self.a = {}
	end
	
	--Some standard values..
	self.rotation = 0
	self.active = true
	self.static = false
	self.mask = {}
	self.gravitydirection = math.pi/2
	
	self.combo = 1
	
	self.falling = false
	
	self.shot = false
	self.outtable = {}
	
	self.speedx = 0
	self.speedy = 0
	
	--Get our enemy's properties from the property table
	for i, v in pairs(enemiesdata[self.t]) do
		self[i] = v
	end
	
	if self.customtimer then
		self.customtimertimer = 0
		self.currentcustomtimerstage = 1
	end
	
	--Decide on a random movement if it's random..
	if self.movementrandoms then
		self.movement = self.movementrandoms[math.random(#self.movementrandoms)]
	end
	
	self.x = x-.5-self.width/2+(self.spawnoffsetx or 0)
	self.y = y-self.height+(self.spawnoffsety or 0)
	
	if self.animationtype == "mirror" then
		self.animationtimer = 0
		self.animationdirection = "left"
	elseif self.animationtype == "frames" then
		self.quadi = self.animationstart
		self.quad = self.quadgroup[self.quadi]
		self.animationtimer = 0
	end
	
	if self.stompanimation then
		self.deathtimer = 0
	end
	
	if self.shellanimal then
		self.upsidedown = false
		self.resettimer = 0
		self.wiggletimer = 0
		self.wiggleleft = true
	end
	
	if self.customscissor then
		self.customscissor = {unpack(self.customscissor)}
		self.customscissor[1] = self.customscissor[1] + x - 1
		self.customscissor[2] = self.customscissor[2] + y - 1
	end
	
	if self.starttowardsplayerhorizontal then --Prize for best property name
		local closestplayer = 1
		self.animationdirection = "right"
		local closestdist = math.huge
		for i = 1, #objects["player"] do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
			
		if objects["player"][closestplayer] then
			if objects["player"][closestplayer].x < self.x then
				self.speedx = -math.abs(self.speedx)
				self.animationdirection = "right"
			else
				self.speedx = math.abs(self.speedx)
				self.animationdirection = "left"
			end
		end
	end
	
	self.spawnallow = true
	self.spawnedenemies = {}
	if self.movement == "piston" then
		self.pistontimer = self.pistonretracttime
		self.pistonstate = "retracting"
		
		if self.spawnonlyonextended then
			self.spawnallow = false
		end
	elseif self.movement == "flyvertical" or self.movement == "flyhorizontal" then
		self.flyingtimer = 0
		self.startx = self.x
		self.starty = self.y
	elseif self.movement == "squid" then
		self.squidstate = "idle"
	end
	
	if self.speedxtowardsplayer then
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		
		if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
			self:leftcollide("", {}, "", {})
			self.speedx = math.abs(self.speedx)
		else
			self:rightcollide("", {}, "", {})
			self.speedx = -math.abs(self.speedx)
		end
	end
	
	if self.lifetime and self.lifetime > 0 then
		self.lifetimer = self.lifetime
	end
	
	if self.jumps then
		self.jumptimer = 0
	end
	
	self.firstmovement = self.movement
	self.firstanimationtype = self.animationtype
	self.startoffsetY = self.offsetY
	self.startquadcenterY = self.quadcenterY
	self.startoffsetY = self.offsetY
	self.startx = self.x
	self.starty = self.y
	self.startgravity = self.gravity
	
	if self.spawnsenemy then
		self.spawnenemytimer = 0
		self.spawnenemydelay = self.spawnenemydelays[math.random(#self.spawnenemydelays)]
	end
	
	self.throwanimationstate = 0
	
	if self.chasetime then
		self.chasetimer = 0
	end
	
	--enemy collide transform trigger
	if self.transforms then
		if string.sub(self.transformtrigger, 0, 11)  == "collidewith" then
			self.transformtriggerenemycollide = string.sub(self.transformtrigger, 12, string.len(self.transformtrigger))
		end
	end
	
	if self.spawnsound then
		playsound(self.spawnsound)
	end
	
	self.outtable = {}
end

function enemy:update(dt)
	--Funnels and fuck
	if self.funnel and not self.infunnel then
		self:enteredfunnel(true)
	end
	
	if self.infunnel and not self.funnel then
		self:enteredfunnel(false)
	end
	
	self.funnel = false
	if self.lifetimer then
		self.lifetimer = self.lifetimer - dt
		if self.lifetimer <= 0 then
			self:output()
			self.dead = true
			
			return true
		end
	end
	
	if self.kill then
		self:output()
		self.dead = true
		
		return true
	end
	
	if self.stompanimation and self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > 0.5 then
			self:output()
			
			return true
		else
			return false
		end
	end
	
	if not self.doesntunrotate then
		self.rotation = unrotate(self.rotation, self.gravitydirection, dt)
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	end
	
	if self.animationtype == "mirror" then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > self.animationspeed do
			self.animationtimer = self.animationtimer - self.animationspeed
			if self.animationdirection == "left" then
				self.animationdirection = "right"
			else
				self.animationdirection = "left"
			end
		end
	elseif self.animationtype == "frames" then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > self.animationspeed do
			self.animationtimer = self.animationtimer - self.animationspeed
			self.quadi = self.quadi + 1
			if self.quadi > self.animationstart + self.animationframes - 1 then
				self.quadi = self.quadi - self.animationframes
			end
			self.quad = self.quadgroup[self.quadi]
		end
		
		if self.speedx > 0 then
			self.animationdirection = "left"
		else
			self.animationdirection = "right"
		end
	end
	
	if self.spawnsenemy then
		self.spawnenemytimer = self.spawnenemytimer + dt
		while self.spawnenemytimer >= self.spawnenemydelay and self.spawnallow and (not self.spawnmax or self:getspawnedenemies() < self.spawnmax) do
			if self.spawnsenemyrandoms then
				self.spawnsenemy = self.spawnsenemyrandoms[math.random(#self.spawnsenemyrandoms)]
			end
			self:spawnenemy(self.spawnsenemy)
			self.spawnenemytimer = 0
			self.spawnenemydelay = self.spawnenemydelays[math.random(#self.spawnenemydelays)]
			self.throwanimationstate = 0
			if self.animationtype == "frames" then
				self.quad = self.quadgroup[self.quadi + self.throwanimationstate]
			end
		end
		
		if self.throwpreparetime and self.spawnenemytimer >= (self.spawnenemydelay - self.throwpreparetime) then
			self.throwanimationstate = self.throwquadoffset
			if self.animationtype == "frames" then
				self.quad = self.quadgroup[self.quadi + self.throwanimationstate]
			end
		end
	end	
	
	if self.movement == "truffleshuffle" then
		if self.speedx > 0 then
			if self.speedx > self.truffleshufflespeed then
				self.speedx = self.speedx - self.truffleshuffleacceleration*dt*2
				if self.speedx < self.truffleshufflespeed then
					self.speedx = self.truffleshufflespeed
				end
			elseif self.speedx < self.truffleshufflespeed then
				self.speedx = self.speedx + self.truffleshuffleacceleration*dt*2
				if self.speedx > self.truffleshufflespeed then
					self.speedx = self.truffleshufflespeed
				end
			end
		else
			if self.speedx < -self.truffleshufflespeed then
				self.speedx = self.speedx + self.truffleshuffleacceleration*dt*2
				if self.speedx > -self.truffleshufflespeed then
					self.speedx = -self.truffleshufflespeed
				end
			elseif self.speedx > -self.truffleshufflespeed then
				self.speedx = self.speedx - self.truffleshuffleacceleration*dt*2
				if self.speedx < -self.truffleshufflespeed then
					self.speedx = -self.truffleshufflespeed
				end
			end
		end
		
		if self.turnaroundoncliff and self.falling == false then
			--check if nothing below
			local x = math.floor(self.x + self.width/2+1)
			local y = math.floor(self.y + self.height+1.5)
			if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) == false and ((inmap(x+.5, y) and tilequads[map[math.ceil(x+.5)][y][1]]:getproperty("collision", math.ceil(x+.5), y)) or (inmap(x-.5, y) and tilequads[map[math.floor(x-.5)][y][1]]:getproperty("collision", math.floor(x-.5), y))) then
				if self.speedx < 0 then
					self.x = x-self.width/2
				else
					self.x = x-1-self.width/2
				end
				self.speedx = -self.speedx
			end
		end
		
	elseif self.movement == "shell" then
		if self.small then
			if self.wakesup then
				if math.abs(self.speedx) < 0.0001 then
					self.resettimer = self.resettimer + dt
					if self.resettimer > self.resettime then
						self.offsetY = self.startoffsetY
						self.quadcenterY = self.startquadcenterY
						self.quad = self.quadgroup[self.animationstart]
						self.small = false
						self.speedx = -self.truffleshufflespeed
						self.resettimer = 0
						self.upsidedown = false
						self.kickedupsidedown = false
						self.movement = self.firstmovement
						self.animationtype = self.firstanimationtype
						
						if self.chasemarioonwakeup then
							local px = objects["player"][getclosestplayer(x)].x
							if px > self.x then
								self.speedx = -self.speedx
							end
						end
					elseif self.resettimer > self.resettime-self.wiggletime then
						self.wiggletimer = self.wiggletimer + dt
						while self.wiggletimer > self.wiggledelay do
							self.wiggletimer = self.wiggletimer - self.wiggledelay
							if self.wiggleleft then
								self.x = self.x + 1/16
							else
								self.x = self.x - 1/16
							end
							self.wiggleleft = not self.wiggleleft
						end
					end
				else
					self.resettimer = 0
				end
			end
		end
		
	elseif self.movement == "follow" then
		local nearestplayer = 1
		while objects["player"][nearestplayer] and objects["player"][nearestplayer].dead do
			nearestplayer = nearestplayer + 1
		end
		
		if objects["player"][nearestplayer] then
			local nearestplayerx = objects["player"][nearestplayer].x
			for i = 2, players do
				local v = objects["player"][i]
				if v.x > nearestplayerx and not v.dead then
					nearestplayer = i
				end
			end
			
			nearestplayerx = nearestplayerx + objects["player"][nearestplayer].speedx*self.distancetime
			
			local distance = math.abs(self.x - nearestplayerx)
			
			--check if too far in wrong direciton
			if (not self.direction or self.direction == "left") and self.x < nearestplayerx-self.followspace then
				self.direction = "right"
				self.animationdirection = "right"
			elseif self.direction == "right" and self.x > nearestplayerx+self.followspace then
				self.direction = "left"
				self.animationdirection = "left"
			end
			
			if self.direction == "right" then
				self.speedx = math.max((self.followspeed or 2), round((distance-3)*2))
			else
				self.speedx = -(self.followspeed or 2)
			end
		end
	elseif self.movement == "piston" then
		self.pistontimer = self.pistontimer + dt
		
		if self.pistonstate == "extending" then		
			--move X
			if self.x > self.startx + self.pistondistx then
				self.x = self.x - self.pistonspeedx*dt
				if self.x < self.startx + self.pistondistx then
					self.x = self.startx + self.pistondistx
				end
			elseif self.x < self.startx + self.pistondistx then
				self.x = self.x + self.pistonspeedx*dt
				if self.x > self.startx + self.pistondistx then
					self.x = self.startx + self.pistondistx
				end
			end
			
			--move Y
			if self.y > self.starty + self.pistondisty then
				self.y = self.y - self.pistonspeedy*dt
				if self.y < self.starty + self.pistondisty then
					self.y = self.starty + self.pistondisty
				end
			elseif self.y < self.starty + self.pistondisty then
				self.y = self.y + self.pistonspeedy*dt
				if self.y > self.starty + self.pistondisty then
					self.y = self.starty + self.pistondisty
				end
			end
			
			if self.x == self.startx + self.pistondistx and self.y == self.starty + self.pistondisty and not self.spawnallow then
				self.spawnallow = true
				self.spawnenemytimer = self.spawnenemydelay
			end
			
			if self.pistontimer > self.pistonextendtime then
				self.pistontimer = 0
				self.spawnallow = false
				self.pistonstate = "retracting"
			end
			
			
		else --retracting			
			--move X
			if self.x > self.startx then
				self.x = self.x - self.pistonspeedx*dt
				if self.x < self.startx then
					self.x = self.startx
				end
			elseif self.x < self.startx then
				self.x = self.x + self.pistonspeedx*dt
				if self.x > self.startx then
					self.x = self.startx
				end
			end
			
			--move Y
			if self.y > self.starty then
				self.y = self.y - self.pistonspeedy*dt
				if self.y < self.starty then
					self.y = self.starty
				end
			elseif self.y < self.starty then
				self.y = self.y + self.pistonspeedy*dt
				if self.y > self.starty then
					self.y = self.starty
				end
			end
			
			if self.inactiveonretracted and self.x == self.startx and self.y == self.starty then
				self.active = false
			end
			
			if self.pistontimer > self.pistonretracttime then
				local playernear = false
				for i = 1, players do
					local v = objects["player"][i]
					if inrange(v.x+v.width/2, self.x+self.width/2-(self.dontpistondist or 3), self.x+self.width/2+(self.dontpistondist or 3)) then
						playernear = true
					end
				end
				
				if not self.dontpistonnearplayer or not playernear then
					self.pistontimer = 0
					self.pistonstate = "extending"
					self.active = true
				end
			end
		end
	elseif self.movement == "wiggle" then
		if self.speedx < 0 then
			if self.x < self.startx-self.wiggledistance then
				self.speedx = self.wigglespeed or 1
			end
		elseif self.speedx > 0 then
			if self.x > self.startx then
				self.speedx = -self.wigglespeed or 1
			end
		else
			self.speedx = self.wigglespeed or 1
		end
		
	elseif self.movement == "verticalwiggle" then
		if self.speedy < 0 then
			if self.y < self.starty-self.verticalwiggledistance then
				self.speedy = self.verticalwigglespeed or 1
			end
		elseif self.speedy > 0 then
			if self.y > self.starty then
				self.speedy = -self.verticalwigglespeed or 1
			end
		else
			self.speedy = self.verticalwigglespeed or 1
		end
		
	elseif self.movement == "rocket" then
		if self.y > self.starty+(self.rocketdistance or 15) and self.speedy > 0 then
			self.y = self.starty+(self.rocketdistance or 15)
			
			self.speedy = -math.sqrt(2*(self.gravity or yacceleration)*(self.rocketdistance or 15))
		end
		
		if self.speedy < 0 then
			self.upsidedown = false
		else
			self.upsidedown = true
		end
		
	elseif self.movement == "squid" then
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		
		if self.squidstate == "idle" then
			self.speedy = self.squidfallspeed
			
			--get if change state to upward
			if (self.y+self.speedy*dt) + self.height + 0.0625 >= (objects["player"][closestplayer].y - (24/16 - objects["player"][closestplayer].height)) then
				self.squidstate = "upward"
				self.upx = self.x
				self.speedx = 0
				self.speedy = 0
				
				if self.animationtype == "squid" then
					self.quad = self.quadgroup[2]
				end
				
				--get if to change direction
				if true then--math.random(2) == 1 then
					if self.direction == "right" then
						if self.x > objects["player"][closestplayer].x then
							self.direction = "left"
						end
					else
						if self.x < objects["player"][closestplayer].x then
							self.direction = "right"
						end
					end
				end
			end
			
		elseif self.squidstate == "upward" then
			if self.direction == "right" then
				self.speedx = self.speedx + self.squidacceleration*dt
				if self.speedx > self.squidxspeed then
					self.speedx = self.squidxspeed
				end
			else
				self.speedx = self.speedx - self.squidacceleration*dt
				if self.speedx < -self.squidxspeed then
					self.speedx = -self.squidxspeed
				end
			end
			
			self.speedy = self.speedy - self.squidacceleration*dt
			
			if self.speedy < -self.squidupspeed then
				self.speedy = -self.squidupspeed
			end
			
			if math.abs(self.x - self.upx) >= (self.squidhordistance or 2) then
				self.squidstate = "downward"
				self.downy = self.y
				self.speedx = 0
			end
			
		elseif self.squidstate == "downward" then
			self.speedy = self.squidfallspeed
			if self.y > self.downy + self.squiddowndistance then
				self.squidstate = "idle"
			end
			
			if self.animationtype == "squid" then
				self.quad = self.quadgroup[1]
			end
		end
		
	elseif self.movement == "targety" then
		if self.y > self.targety then
			self.y = self.y - self.targetyspeed*dt
			if self.y < self.targety then
				self.y = self.targety
			end
		elseif self.y < self.targety then
			self.y = self.y + self.targetyspeed*dt
			if self.y > self.targety then
				self.y = self.targety
			end
		end
	elseif self.movement == "flyvertical" then
		self.flyingtimer = self.flyingtimer + dt
		
		while self.flyingtimer > (self.flyingtime or 7) do
			self.flyingtimer = self.flyingtimer - (self.flyingtime or 7)
		end
		
		local newy = self:func(self.flyingtimer/(self.flyingtime or 7))*(self.flyingdistance or 7.5) + self.starty
		self.y = newy
	elseif self.movement == "flyhorizontal" then
		self.flyingtimer = self.flyingtimer + dt
		
		while self.flyingtimer > (self.flyingtime or 7) do
			self.flyingtimer = self.flyingtimer - (self.flyingtime or 7)
		end
		
		local newx = self:func(self.flyingtimer/(self.flyingtime or 7))*(self.flyingdistance or 7.5) + self.startx
		self.x = newx
	end
	
	if self.jumps then
		self.jumptimer = self.jumptimer + dt
		if self.jumptimer > self.jumptime then
			self.jumptimer = self.jumptimer - self.jumptime
			--decide whether up or down
			local dir
			if self.y > 12 then
				dir = "up"
			elseif self.y < 6 then
				dir = "down"
			else
				if math.random(2) == 1 then
					dir = "up"
				else
					dir = "down"
				end
			end
			
			if dir == "up" then
				self.speedy = -self.jumpforce
				self.mask[2] = true
				self.jumping = "up"
			else
				self.speedy = -self.jumpforcedown
				self.mask[2] = true
				self.jumping = "down"
				self.jumpingy = self.y
			end
		end
		
		if self.jumping then
			if self.jumping == "up" then
				if self.speedy > 0 then
					self.jumping = false
					self.mask[2] = false
				end
			elseif self.jumping == "down" then
				if self.y > self.jumpingy + self.height+1.1 then
					self.jumping = false
					self.mask[2] = false
				end
			end
		end
	end
	
	if self.facesplayer then
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		
		if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
			self.animationdirection = "left"
		else
			self.animationdirection = "right"
		end
	end
	
	if self.chasetime then
		if self.chasetimer > self.chasetime then
			local closestplayer = 1
			local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
			for i = 2, players do
				local v = objects["player"][i]
				local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
				if dist < closestdist then
					closestdist = dist
					closestplayer = i
				end
			end
			
			if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 < self.x + self.width/2 then
				self.speedx = -(self.chasespeed or 1.5)
			else
				self.chasetimer = 0
				self.startx = self.x
			end
		else
			self.chasetimer = self.chasetimer + dt
		end
	end
	
	if self.customtimer then
		self.customtimertimer = self.customtimertimer + dt
		while self.customtimertimer > self.customtimer[self.currentcustomtimerstage][1] do
			if self.customtimer[self.currentcustomtimerstage][2] and self.customtimer[self.currentcustomtimerstage][3] then
				self:customtimeraction(self.customtimer[self.currentcustomtimerstage][2], self.customtimer[self.currentcustomtimerstage][3])
			elseif self.customtimer[self.currentcustomtimerstage][2] then
				self:customtimeraction(self.customtimer[self.currentcustomtimerstage][2])
			end
			self.currentcustomtimerstage = self.currentcustomtimerstage + 1
			if self.currentcustomtimerstage > #self.customtimer then
				self.currentcustomtimerstage = 1
			end
			self.customtimertimer = 0
		end
	end
end

function enemy:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function enemy:shotted(dir, below, high, fireball, star)
	if fireball and self.resistsfire then
		return false
	end
	
	if star and self.resistsstar then
		return false
	end
	
	if self.health then
		if self.health > 0 then
			self.health = self.health - 1
			return
		end
	end
	
	if self.givecoinwhenshot then
		collectcoin(nil, nil, 1)
	end
	
	if self.transforms and (self.transformtrigger == "shot" or self.transformtrigger == "death") then
		self:transform(self.transformsinto)
		return
	end
	
	playsound("shot")
	
	self.speedy = -(self.shotjumpforce or shotjumpforce)
	if high then
		self.speedy = self.speedy*2
	end
	self.direction = dir or "right"
	self.gravity = shotgravity
	
	if self.direction == "left" then
		self.speedx = -(self.shotspeedx or shotspeedx)
	else
		self.speedx = self.shotspeedx or shotspeedx
	end
	
	if self.shellanimal then
		self.small = true
		self.quad = self.quadgroup[self.smallquad]
		if below then
			self.upsidedown = true
			self.kickedupsidedown = true
			self.offsetY = 4
			self.movement = self.smallmovement
			self.animationtype = "none"
		else
			self.shot = true
			self.active = false
		end
	else
		self.shot = true
		self.active = false
	end
	
	if self.doesntflyawayonfireball then
		self.kill = true
		self.drawable = false
	end
	
	return true
end

function enemy:customtimeraction(action, arg)
	if action == "bounce" then
		self.speedy = -(arg or 10)
	elseif action == "playsound" then
		playsound(arg)
	elseif action == "setframe" then
		self.quad = self.quadgroup[arg]
	elseif string.sub(action, 0, 3) == "set" then
		if not arg then --if arg is nil set it to false
			self[string.sub(action, 4, string.len(action))] = false
		else
			self[string.sub(action, 4, string.len(action))] = arg
		end
	end
end

function enemy:func(i) -- 0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function enemy:globalcollide(a, b, c, d, dir)
	if a == "tile" then
		if not self.resistsspikes then
			dir = twistdirection(self.gravitydirection, dir)
			if dir == "ceil" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesbottom", b.cox, b.coy) then
				self:shotted()
				return false
			elseif dir == "right" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesleft", b.cox, b.coy) then
				self:shotted()
				return false
			elseif dir == "left" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesright", b.cox, b.coy) then
				self:shotted()
				return false
			elseif dir == "floor" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikestop", b.cox, b.coy) then
				self:shotted()
				return false
			end
		end
	end

	if a == "platform" or a == "seesawplatform" then
		if dir == "floor" then
			if self.jumping and self.speedy < -jumpforce + 0.1 then
				return true
			end
		else
			return true
		end
	end
	
	if a == "player" and self.removeonmariocontact then
		self.kill = true
		self.drawable = false
		return true
	end

	if a == "player" then
		return true
	end
	
	if self.killsenemies and a == "enemy" then
		return true
	end
	
	if a == "fireball" and self.resistsfire then
		return true
	end
	
	if b.killsenemies then
		local dir = "right"
		if b.speedx < 0 then
			dir = "left"
		end
		self:shotted(dir)
		
		addpoints((firepoints[self.t] or 200), self.x, self.y)
		return true
	end
	
	if self.transforms and (self.transformtrigger == "globalcollide" or self.transformtrigger == "collide") then
		self:transform(self.transformsinto)
	end
	
	if self.breaksblocks then
		if self.breakblockside == "global" and a == "tile" then
			hitblock(b.cox, b.coy, self, true)
		end
	end
	
	if self.transforms then
		if a == self.transformtriggerenemycollide then
			self:transform(self.transformsinto)
		end
	end
	
	if self.nocollidestops or b.nocollidestops then
		return true
	end
end

function enemy:leftcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "left") then
		return false
	end
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	if self.transforms and self.transformtrigger == "leftcollide" then
		self:transform(self.transformsinto)
	end
	
	if self.reflects then
		self.speedx = -self.speedx
	end
	
	if self.breaksblocks then
		if (self.breakblockside == "sides" or self.breakblockside == "left") and a == "tile" then
			hitblock(b.cox, b.coy, self, true)
		end
	end
	
	if self.movement == "truffleshuffle" then
		self.speedx = self.truffleshufflespeed
		if not self.dontmirror then
			self.animationdirection = "left"
		end
		return false
	elseif self.small then
		if a ~= "enemy" then
			self.speedx = self.smallspeed
			
			if a == "tile" then
				hitblock(b.cox, b.coy, self, true)
			else
				playsound("blockhit")
			end
			return false
		end
	end
end

function enemy:rightcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "right") then
		return false
	end
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	if self.transforms and self.transformtrigger == "rightcollide" then
		self:transform(self.transformsinto)
	end
	
	if self.reflects then
		self.speedx = -self.speedx
	end
	
	if self.breaksblocks then
		if (self.breakblockside == "sides" or self.breakblockside == "right") and a == "tile" then
			hitblock(b.cox, b.coy, self, true)
		end
	end
	
	if self.movement == "truffleshuffle" then
		self.speedx = -self.truffleshufflespeed
		if not self.dontmirror then
			self.animationdirection = "right"
		end
		return false
	elseif self.small then
		if a ~= "enemy" then
			self.speedx = -self.smallspeed
			
			if a == "tile" then
				hitblock(b.cox, b.coy, self, true)
			else
				playsound("blockhit")
			end
			return false
		end
	end
end

function enemy:ceilcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "ceil") then
		return false
	end
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
	
	if self.transforms and self.transformtrigger == "ceilcollide" then
		self:transform(self.transformsinto)
	end
	
	if self.reflects then
		self.speedy = -self.speedy
	end
	
	if self.breaksblocks then
		if self.breakblockside == "ceil" and a == "tile" then
			hitblock(b.cox, b.coy, self, true)
		end
	end
end

function enemy:floorcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "floor") then
		return false
	end
	
	if self.transforms and self.transformtrigger == "floorcollide" then
		self:transform(self.transformsinto)
	end
	
	if self.reflects then
		self.speedy = -self.speedy
	end
	
	if self.bounces then
		self.speedy = -(self.bounceforce or 10)
	end
	
	if self.kickedupsidedown then
		self.speedx = 0
		self.kickedupsidedown = false
	end
	
	self.falling = false
end

function enemy:passivecollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "passive") then
		return false
	end
	
	if a == "tile" then
		if tilequads[map[b.cox][b.coy][1]]:getproperty("platform", b.cox, b.coy) then
			return false
		end
	end
end

function enemy:startfall()
	self.falling = true
end

function enemy:stomp(x, b)
	if self.stompable then
		if self.health then
			if self.health > 0 then
				self.health = self.health - 1
				return
			end
		end
	
		if self.transforms and (self.transformtrigger == "stomp" or self.transformtrigger == "death") then
			self:transform(self.transformsinto)
			return
		end
		
		if self.givecoinwhenstomped then
			collectcoin(nil, nil, 1)
		end
		
		if self.shellanimal then
			if not self.small then
				self.quadcenterY = 19
				self.offsetY = 0
				self.quad = self.quadgroup[self.smallquad]
				self.small = true
				self.movement = self.smallmovement
				self.speedx = 0
				self.animationtype = "none"
			elseif self.speedx == 0 then
				if self.x > x then
					self.speedx = self.smallspeed
					self.x = x+12/16+self.smallspeed*gdt
					if b then
						self.size = b.size
					else
						self.size = 1
					end
					self.killsenemies = true
				else
					self.speedx = -self.smallspeed
					self.x = x-self.width-self.smallspeed*gdt
					if b then
						self.size = b.size
					else
						self.size = 1
					end
					self.killsenemies = true
				end
			else
				self.speedx = 0
				self.combo = 1
			end
		else
			self.active = false
			if self.stompanimation then
				self.quad = self.quadgroup[self.stompedframe]
				if self.fallswhenstomped then
					self.shot = true
					self.gravity = shotgravity
				else
					self.dead = true
				end
			else
				self.shot = true
				self.gravity = shotgravity
			end
		end
	end
end

function enemy:autodeleted()
	self.dead = true
	self:output()
end

function enemy:output()
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input("toggle", self.outtable[i][2])
		end
	end
end

function enemy:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function enemy:portaled()
	if self.killsenemiesafterportal then
		self.killsenemies = true
	end
end

function enemy:spawnenemy(t)
	local speedx, speedy = 0, 0
	if self.spawnenemyspeedx then
		speedx = self.spawnenemyspeedx
	end
	if self.spawnenemyspeedy then
		speedy = self.spawnenemyspeedy
	end
	
	if (self.spawnenemyspeedxrandomstart and self.spawnenemyspeedxrandomend) then
		speedx = math.random()*(self.spawnenemyspeedxrandomend-self.spawnenemyspeedxrandomstart) + self.spawnenemyspeedxrandomstart
	end
	
	if (self.spawnenemyspeedyrandomstart and self.spawnenemyspeedyrandomend) then
		speedy = math.random()*(self.spawnenemyspeedyrandomend-self.spawnenemyspeedyrandomstart) + self.spawnenemyspeedyrandomstart
	end
	
	local closestplayer = 1
	local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
	for i = 2, players do
		local v = objects["player"][i]
		local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
		if dist < closestdist then
			closestdist = dist
			closestplayer = i
		end
	end

	if self.spawnenemytowardsplayer then
		
		local a = -math.atan2(objects["player"][closestplayer].x-self.x, objects["player"][closestplayer].y-self.y)+math.pi/2
		
		speedx = math.cos(a)*self.spawnenemyspeed
		speedy = math.sin(a)*self.spawnenemyspeed
	end
	
	if self.spawnenemyspeedxtowardsplayer then
		if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
			speedx = math.abs(speedx)
		else
			speedx = -math.abs(speedx)
		end
	end
	
	local xoffset = self.spawnenemyoffsetx or 0
	local yoffset = self.spawnenemyoffsety or 0
	
	local temp = enemy:new(self.x+self.width/2+.5+xoffset, self.y+self.height+yoffset, t, {})
	table.insert(objects["enemy"], temp)
	
	temp.speedx = speedx
	temp.speedy = speedy
	
	if temp.movement == "truffleshuffle" and temp.speedx > 0 then
		temp.animationdirection = "left"
	end
	
	table.insert(self.spawnedenemies, temp)
	temp.spawner = self
end

function enemy:transform(t)
	local xoffset = self.transformsoffsetx or 0
	local yoffset = self.transformsoffsety or 0

	local temp = enemy:new(self.x+self.width/2+.5+xoffset, self.y+self.height+yoffset, t, {})
	table.insert(objects["enemy"], temp)
	
	if self.spawner then
		table.insert(self.spawner.spawnedenemies, temp)
	end
	
	self.kill = true
end

function enemy:emancipate()
	if not self.kill then
		table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, self.speedx, self.speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self.kill = true
		self.drawable = false
	end
end

function enemy:laser(guns, pewpew)
	if not self.laserresistant then
		self:shotted()
	end
end

function enemy:enteredfunnel(inside)
	if inside then
		self.infunnel = true
	else
		self.infunnel = false
		self.gravity = self.startgravity
	end
end

function enemy:getspawnedenemies()
	local count = 0
	for i, v in pairs(self.spawnedenemies) do
		if not v.dead then
			count = count + 1
		end
	end
	
	return count
end