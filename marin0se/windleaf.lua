windleaf = class("windleaf")

function windleaf:init(x, y)
	self.x = x
	self.y = y
	self.speedy = 0
	self.speedx = 50
	self.width = -100000000
	self.height = -100000000
	self.static = false
	self.active = true
	self.category = 29
	self.portalable = false
	self.gravity = 0
	
	self.mask = {true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = windleafimage
	self.quad = windleafquad[spriteset][math.random(1,2)] --random leaf bro!
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 3
	self.quadcenterY = 3
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	
	self.falling = false
end

function windleaf:update(dt)
	if self.x > xscroll+width+1 or self.y > mapheight and self.active then --check if off screen
		return true
	else
		return false
	end
end