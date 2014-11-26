coinblockanimation = class("coinblockanimation")

function coinblockanimation:init(x, y)
	self.x = x
	self.y = y
	
	self.timer = 0
	self.frame = 1
end 

function coinblockanimation:update(dt)
	self.timer = self.timer + dt
	while self.timer > coinblockdelay do
		self.frame = self.frame + 1
		self.timer = self.timer - coinblockdelay
	end
	
	if self.frame >= 31 then
		--addpoints(-200, self.x, self.y)
		--@WARNING: I'm not sure why this is here. At all.
		return true
	end
	
	return false
end

function coinblockanimation:draw()
	love.graphics.draw(coinblockanimationimg, coinblockanimationquads[self.frame], math.floor((self.x - xscroll)*16*scale), math.floor(((self.y-yscroll)*16-8)*scale), 0, scale, scale, 4, 54)
end