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
thisclass.static.image_sigs = {
	blockdebris = {8,8}
}

function thisclass:init(x, y, dir, forcemultiplier)
	--baseentity.init(self, thisclass, classname, x-.5, y-.5, 0, nil, parent)
	forcemultiplier = forcemultiplier or 0
	
	self.x = x-.5
	self.y = y-.5
	
	self.dir = dir or self.dir
	if self.dir == "right" then
		self.speedx = thisclass.basexspeed
	elseif self.dir == "left" then
		self.speedx = -thisclass.basexspeed
	end
	self.speedy = thisclass.baseyspeed-(thisclass.yspeedstep*forcemultiplier)
	
	self.width = 8/16
	self.height = 8/16
	self.static = true
	self.nospritesets = true
	self.mask = {true, false}
	self.category = 1
	self.offsetX, self.offsetY = 4, 4
	self.quadcenterX, self.quadcenterY = 4, 4
	self.graphicid = classname
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	-- the comment below about self.quad also applies here
	self.quadi = 1
	self.quad = globalimages[self.graphicid].quads[self.quadi]
	self.drawable = true
	self.active = true
	self.timermax = thisclass.frametime
	self.timer = self.timermax
	
	table.insert(objects[classname], self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	self.speedy = self.speedy + thisclass.gravity*dt
	
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	
	
	if self.y > mapheight then
		return true
	end
	
	return false
end

function thisclass:timercallback()
	self:setQuad(self.quadi)
	self.quadi = self.quadi + 1
end