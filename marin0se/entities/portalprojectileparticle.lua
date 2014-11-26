portalprojectileparticle = class("portalprojectileparticle")

function portalprojectileparticle:init(x, y, color, r, g, b)
	self.x = x
	self.y = y
	self.color = color
	
	
	self.speedx = math.random(-10, 10)/70
	self.speedy = math.random(-10, 10)/70
	
	self.alpha = 150
	
	self.timer = 0
end

function portalprojectileparticle:update(dt)
	self.timer = self.timer + dt
	
	self.speedx = self.speedx + math.random(-10, 10)/70
	self.speedy = self.speedy + math.random(-10, 10)/70
	
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	
	self.alpha = self.alpha - dt*300
	if self.alpha < 0 then
		self.alpha = 0
		return true
	end
end

function portalprojectileparticle:draw()
	local r, g, b = unpack(self.color)
	love.graphics.setColor(r, g, b, self.alpha)
	
	love.graphics.draw(portalprojectileparticleimg, math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale, 2, 2)
end