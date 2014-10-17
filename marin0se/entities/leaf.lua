leaf = class("leaf")

function leaf:init(x, y)
	self.x = x
	self.y = y
	self.speedy = 0
	self.speedx = 50
	self.width = 1
	self.height = 1
	self.static = false
	self.active = true
	self.category = 29
	self.portalable = false
	self.gravity = 0
	
	self.mask = {true}
	
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
	
	self.falling = false
end

function leaf:update(dt)
	self.x = self.x + 0.75
	if self.x > width or self.y > mapheight then
		return true
	end
	return false
end

function leaf:draw()
	love.graphics.draw(leafimg, leafquad[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale, 2, 2)
end