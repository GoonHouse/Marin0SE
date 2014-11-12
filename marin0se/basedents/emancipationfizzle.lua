local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.frametime = 0.4

-- engine stuff
thisclass.static.GRAPHIC_QUADCENTER = {2,1,0}
thisclass.static.GRAPHIC_OFFSET = {2,1,0}
thisclass.static.GRAPHIC_SIGS = {
	emancipationfizzle = {4,2}
}

thisclass:include(Base)
thisclass:include(HasGraphics)

function thisclass:init(x, y, speedx, speedy)
	baseentity.init(self, thisclass, classname, x-.5, y-.5, 0)
	self.r = math.random()*math.pi*2
	self.rotspeed = (math.random()-.5)*2
	self.speedx = speedx+(math.random()-.5)*1
	self.speedy = speedy+(math.random()-.5)*1
	
	self.drawable = false
	
	timer.Create(self, thisclass.frametime, 0,
		function()
			self:remove()
		end
	)
	timer.Start(self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	self.r = self.r + self.rotspeed*dt
	
	return self.destroy
end

function thisclass:draw()
	local da = 255*(1-timer.TimeLeft(self)/thisclass.frametime)
	love.graphics.setColor(da, da, da, da)
	love.graphics.draw(
		self.graphic,
		(self.x-xscroll)*16*scale,
		(self.y-yscroll-.5)*16*scale,
		self.r, scale, scale, 2, 1
	)
end