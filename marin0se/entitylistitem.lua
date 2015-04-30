entitylistitem = class("entitylistitem")

function entitylistitem:init(t, i)
	self.x = x
	self.y = y
	self.t = t
	self.i = i 
	self.startx = 5
	self.starty = 38
	self.offy = 0
end

function entitylistitem:gethighlight(x, y)
	x = x/scale-self.startx
	y = y/scale-self.starty+self.offy/scale
	
	return x >= self.x and x < self.x+16 and y >= self.y and y < self.y+16
end

function entitylistitem:calibrate(startx, starty, offy)
	self.startx = startx
	self.starty = starty
	self.offy = offy
end