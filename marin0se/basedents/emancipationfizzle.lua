local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.frametime = 0.4

-- engine stuff
thisclass.static.image_sigs = {
	fizzle = {4,2}
}

function thisclass:init(x, y, speedx, speedy)
	--baseentity.init(self, thisclass, classname, x-.5, y-.5, 0, nil, parent)
	self.x = x
	self.y = y
	self.r = math.random()*math.pi*2
	self.rotspeed = (math.random()-.5)*2
	self.speedx = speedx+(math.random()-.5)*1
	self.speedy = speedy+(math.random()-.5)*1
	
	self.static = true
	self.mask = {true, false}
	self.category = 1
	self.width, self.height = 16, 8
	self.offsetX, self.offsetY = self.width/2, self.height/2
	self.quadcenterX, self.quadcenterY = self.width/2, self.height/2
	self.width, self.height = 16/16, 8/16
	self.graphicid = "fizzle"
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	-- the comment below about self.quad also applies here
	self.quadi = 1
	self.quad = globalimages[self.graphicid].quads[self.quadi]
	self.drawable = false
	self.active = true
	self.timermax = thisclass.frametime
	self.timer = 0
	
	table.insert(objects[classname], self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	self.r = self.r + self.rotspeed*dt
	
	return self.destroy
end

function thisclass:timercallback()
	self.destroy = true
end

function thisclass:draw()
	local da = 255*(1-self.timer/thisclass.frametime)
	love.graphics.setColor(da, da, da, da)
	love.graphics.draw(
		self.graphic,
		(self.x-xscroll)*16*scale,
		(self.y-yscroll-.5)*16*scale,
		self.r, scale, scale, 2, 1
	)
end