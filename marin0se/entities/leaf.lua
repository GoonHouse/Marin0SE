leaf = class("leaf")

function leaf:init(x, y)
	self.x = x
	self.y = y
	self.speedx = 0
	self.speedy = 0
	self.static = false
	self.active = true
	self.category = 1
	self.mask = {false}
	self.height = 1
	self.width = 1
	self.gravity = 0
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = leafimage
	self.frame = math.random(1,2) --random leaf bro!
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 3
	self.quadcenterY = 3	
	self.rotation = 0 --for portals
	self.direction = "left"
	
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