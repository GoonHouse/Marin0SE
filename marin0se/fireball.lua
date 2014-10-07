fireball = class("fireball")

function fireball:init(x, y, dir, v)
	--PHYSICS STUFF
	self.y = y+4/16
	self.speedy = 0
	if dir == "right" then
		self.speedx = fireballspeed
		self.x = x+6/16
	else
		self.speedx = -fireballspeed
		self.x = x
	end
	self.width = 8/16
	self.height = 8/16
	self.active = true
	self.static = false
	self.category = 13
	
	self.mask = {	true,
					false, true, false, false, true,
					false, true, false, true, false,
					false, true, false, true, false,
					true, true, false, false, false,
					false, true, false, false, true,
					false, false, false, false, true}
					
	self.destroy = false
	self.destroysoon = false
	--self.gravity = 40
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = fireballimg
	self.quad = fireballquad[1]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
	
	self.fireballthrower = v
	
	self.rotation = 0 --for portals
	self.gravitydirection = math.pi/2
	self.timer = 0
	self.quadi = 1
	
	self.emancipatecheck = true
end

function fireball:update(dt)
	--rotate back to 0 (portals)
	self.rotation = 0
	
	--animate
	self.timer = self.timer + dt
	if self.destroysoon == false then
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	else
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 8 then
				self.destroy = true
				self.quadi = 7
			end
			
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	end
	
	if self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight and self.active then
		self.fireballthrower:fireballcallback()
		self.destroy = true
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function fireball:leftcollide(a, b)
	self.x = self.x-.5
	self:hitstuff(a, b)
	
	self.speedx = fireballspeed
	return false
end

function fireball:rightcollide(a, b)
	self:hitstuff(a, b)
	
	self.speedx = -fireballspeed
	return false
end

function fireball:floorcollide(a, b)
	if a ~= "tile" and a ~= "portalwall" then
		self:hitstuff(a, b)
	end
	
	self.speedy = -fireballjumpforce
	return false
end

function fireball:ceilcollide(a, b)
	self:hitstuff(a, b)
end

function fireball:passivecollide(a, b)
	self:ceilcollide(a, b)
	return false
end

function fireball:hitstuff(a, b)
	if a == "tile" or a == "bulletbill" or a == "portalwall" or a == "spring" then
		self:explode()
		playsound("blockhit")
		
	elseif a == "enemy" or a == "bowser" then
		if b:shotted("right", false, false, true) ~= false then
			if a ~= "bowser" then
				addpoints(b.firepoints or 200, self.x, self.y)
			end
		end
		self:explode()
	end
end

function fireball:explode()
	if self.active then
		self.fireballthrower:fireballcallback()
		
		self.destroysoon = true
		self.quadi = 5
		self.quad = fireballquad[self.quadi]
		self.active = false
	end
end

function fireball:emancipate()
	if not self.kill then
		table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, self.speedx, self.speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self.kill = true
		self.drawable = false
	end
end