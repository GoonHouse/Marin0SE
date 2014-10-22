leaf = class("leaf")

function leaf:init(x, y)
	self.x = x
	self.y = y
	self.frame = math.random(1,2) --random leaf bro!
	
end

function leaf:update(dt)
	self.x = self.x + .50
	if self.x > width or self.y > mapheight then
		self.destroy = true
		return true
	end
	return false
end

function leaf:draw()
	love.graphics.draw(leafimg, leafquad[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale, 2, 2)
end