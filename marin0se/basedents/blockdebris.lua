local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.frametime = 0.1
thisclass.static.basexspeed = 3.5
thisclass.static.baseyspeed = -14
thisclass.static.yspeedstep = 9
thisclass.static.gravity = 80

-- engine stuff
thisclass.static.GRAPHIC_QUADCENTER = {4,4,0}
thisclass.static.GRAPHIC_OFFSET = {4,4,0}
thisclass.static.GRAPHIC_SIGS = {
	blockdebris = {8,8}
}

thisclass:include(Base)
thisclass:include(HasGraphics)

function thisclass:init(x, y, dir, forcemultiplier)
	baseentity.init(self, x-.5, y-.5, 0, nil, parent)
	forcemultiplier = forcemultiplier or 0
	
	self.dir = dir or self.dir
	if self.dir == "right" then
		self.speedx = thisclass.basexspeed
	elseif self.dir == "left" then
		self.speedx = -thisclass.basexspeed
	end
	self.speedy = thisclass.baseyspeed-(thisclass.yspeedstep*forcemultiplier)
	
	timer.Create(self, thisclass.frametime, 0,
		function()
			self:nextFrame()
		end
	)
	timer.Start(self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	self.speedy = self.speedy + thisclass.gravity*dt
	
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	
	
	if self.y > mapheight then
		self:remove()
	end
	
	return self.destroy
end