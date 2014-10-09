spring = class("spring")

function spring:init(x, y)
	self.cox = x
	self.coy = y
	
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-32/16
	self.width = 16/16
	self.height = 32/16
	self.static = true
	self.active = true
	
	self.drawable = false
	
	self.timer = springtime
	
	self.category = 19
	
	self.mask = {true}
	
	self.frame = 1
end

function spring:update(dt)
	if self.timer < springtime then
		self.timer = self.timer + dt
		if self.timer > springtime then
			self.timer = springtime
		end
		self.frame = math.ceil(self.timer/(springtime/3)+0.001)+1
		if self.frame > 3 then
			self.frame = 6-self.frame
		end
	end
end

function spring:draw()
	if spring == "high" then
		love.graphics.drawq(springgrnimg, springgrnquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16-8)*scale, 0, scale, scale)
	else
		love.graphics.drawq(springimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16-8)*scale, 0, scale, scale)
	end
end

function spring:hit()
	self.timer = 0
	playsound("spring")
end