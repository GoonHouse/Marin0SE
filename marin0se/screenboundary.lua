screenboundary = class("screenboundary")

function screenboundary:init(x)
	self.x = x
	self.y = -1000	
	self.width = 0
	self.height = 1000+mapheight
	self.static = true
	self.active = true
	self.category = 10
	self.mask = {true}
end 