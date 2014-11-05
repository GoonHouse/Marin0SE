box = class("box")

function box:init(x, y)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-14/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 9
	self.parent = nil
	self.portaloverride = true

	self.mask = {	true,
					false, false, false, false, false,
					false, true, false, true, true,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true}
					
	self.emancipatecheck = true

	self.userect = adduserect(self.x, self.y, 12/16, 12/16, self)
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = boximg
	self.quad = boxquad[1]
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 6
	self.quadcenterY = 6
	
	self.rotation = 0 --for portals
	self.gravitydirection = math.pi/2
	
	self.falling = false
	self.destroying = false
	self.outtable = {}
	self.portaledframe = false
end

function box:update(dt)
	local friction = boxfrictionair
	if self.falling == false then
		friction = boxfriction
	end
	
	--Funnels and fuck
	if self.funnel and not self.infunnel then
		self:enteredfunnel(true)
	end
	
	if self.infunnel and not self.funnel then
		self:enteredfunnel(false)
	end
	
	self.funnel = false
	
	if not self.pushed then
		if self.speedx > 0 then
			self.speedx = self.speedx - friction*dt
			if self.speedx < 0 then
				self.speedx = 0
			end
		else
			self.speedx = self.speedx + friction*dt
			if self.speedx > 0 then
				self.speedx = 0
			end
		end
	else
		self.pushed = false
	end
	
	self.rotation = 0
	
	if self.parent then
		local oldx = self.x
		local oldy = self.y
		
		self.x = self.parent.x+math.sin(-self.parent.pointingangle)*0.3
		self.y = self.parent.y-math.cos(-self.parent.pointingangle)*0.3
		
		if self.portaledframe == false then
			for h, u in pairs(objects["emancipationgrill"]) do
				if u.active then
					if u.dir == "hor" then
						if inrange(self.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, oldy, self.y, true) then
							self:emancipate(h)
						end
					else
						if inrange(self.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, oldx, self.x, true) then
							self:emancipate(h)
						end
					end
				end
			end
		end
		
		self.rotation = self.parent.rotation
	end
	
	self.userect.x = self.x
	self.userect.y = self.y

	--check if offscreen
	if self.y > mapheight+2 then
		self:destroy()
	end
	
	self.portaledframe = false
	
	if self.destroying then
		return true
	else
		return false
	end
end

function box:globalcollide(a, b, c, d, dir)
	if a == "platform" or a == "seesawplatform" then
		if dir == "floor" then
			if self.jumping and self.speedy < -jumpforce + 0.1 then
				return true
			end
		else
			return true
		end
	end
end

function box:ceilcollide(a, b)
	if self:globalcollide(a, b, c, d, "ceil") then
		return false
	end
end

function box:leftcollide(a, b)
	if self:globalcollide(a, b, c, d, "left") then
		return false
	end

	if a == "button" then
		self.y = b.y - self.height
		self.x = b.x + b.width - 0.01
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "player" then
		self.pushed = true
		return false
	end
end

function box:rightcollide(a, b)
	if self:globalcollide(a, b, c, d, "right") then
		return false
	end
	
	if a == "button" then
		self.y = b.y - self.height
		self.x = b.x - self.width+0.01
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "player" then
		self.pushed = true
		return false
	end
end

function box:floorcollide(a, b)
	if self:globalcollide(a, b, c, d, "floor") then
		return false
	end
	
	if self.falling then
		self.falling = false
	end
	
	if a == "enemy" and b.killedbyboxes then
		b:stomp()
		addpoints(200, self.x, self.y)
		playsound("stomp", self.x, self.y, self.speedx, self.speedy)
		self.falling = true
		self.speedy = -10
		return false
	end
end

function box:passivecollide(a, b)
	if self:globalcollide(a, b, c, d, "passive") then
		return false
	end
	
	if a == "player" then
		if self.x+self.width > b.x+b.width then
			self.x = b.x+b.width
		else
			self.x = b.x-self.width
		end
	end
end

function box:startfall()
	self.falling = true
end

function box:emancipate()
	if not self.destroying then
		local speedx, speedy = self.speedx, self.speedy
		if self.parent then
			self.parent:cubeemancipate()
			speedx = speedx + self.parent.speedx
			speedy = speedy + self.parent.speedy
		end
		table.insert(objects["emancipateanimation"], emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, speedx, speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self:destroy()
	end
end

function box:destroy()
	self.userect.delete = true
	self.destroying = true
	
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input("toggle", self.outtable[i][2])
		end
	end
end

function box:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function box:used(id)
	self.parent = objects["player"][id]
	self.active = false
	objects["player"][id]:pickupbox(self)
end

function box:dropped()
	self.parent = nil
	self.active = true
end

function box:portaled()
	self.portaledframe = true
end

function box:enteredfunnel(inside)
	if inside then
		self.infunnel = true
	else
		self.infunnel = false
		self.gravity = nil
	end
end

function box:faithplate(dir)
	self.falling = true
end

function box:onbutton(s)
	if s then
		self.quad = boxquad[2]
	else
		self.quad = boxquad[1]
	end
end