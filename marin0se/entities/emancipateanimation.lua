emancipateanimation = class("emancipateanimation")

function emancipateanimation:init(x, y, width, height, img, quad, speedx, speedy, rotation, offsetX, offsetY, quadcenterX, quadcenterY)
	
	-- this would be static but it's not, call the cops
	self.effectdelay = 0.05
	self.effecttime = 0.4
	self.effectanimtime = 0.6
	self.effectfadeouttime = 0.2
	
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.img = img
	self.quad = quad
	self.speedx = speedx
	self.speedy = speedy
	self.rotation = rotation
	self.offsetX = offsetX
	self.offsetY = offsetY
	self.quadcenterX = quadcenterX
	self.quadcenterY = quadcenterY
	self.emancemaxspeed = 3
	self.emanceaccel = 20
	
	self.speedx = math.max(-self.emancemaxspeed, math.min(self.emancemaxspeed, self.speedx))
	
	self.speedy = math.max(-self.emancemaxspeed, math.min(self.emancemaxspeed, self.speedy))
	
	self.rotationspeed = (math.random()-.5)*8
	self.timer = 0
	self.timer2 = 0
end

function emancipateanimation:update(dt)
	self.speedx = self.speedx + (math.random()-.5)*dt*self.emanceaccel
	self.speedy = self.speedy + (math.random()-.5)*dt*self.emanceaccel

	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	
	self.rotation = self.rotation + self.rotationspeed*dt
	
	if self.timer < self.effecttime-self.effectfadeouttime then
		self.timer2 = self.timer2 + dt
		while self.timer2 > self.effectdelay do
			emancipationfizzle:new(self.x+math.random()*self.width, self.y+math.random()*self.height, self.speedx, self.speedy)
			self.timer2 = self.timer2 - self.effectdelay
		end
	end
	
	self.timer = self.timer + dt
	if self.timer > self.effectanimtime then
		return true
	else
		return false
	end
end

function emancipateanimation:draw()
	local black = 1-self.timer/self.effectanimtime
	local a = math.min(1, 1-(self.timer-(self.effectanimtime-self.effectfadeouttime))/self.effectfadeouttime)

	love.graphics.setColor(255*black, 255*black, 255*black, 255*a)
	if self.quad then
		love.graphics.draw(self.img, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), self.rotation, scale, scale, self.quadcenterX, self.quadcenterY)
	else
		love.graphics.draw(self.img, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), self.rotation, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end