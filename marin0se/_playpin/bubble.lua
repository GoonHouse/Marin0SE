local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

thisclass.static.bubblesmaxy = 2.5
thisclass.static.bubblesspeed = 2.3
thisclass.static.bubblesmargin = 0.5
thisclass.static.bubblestime = {1.2, 1.6}

thisclass.static.GRAPHIC_QUADCENTER = {2,2,0}
thisclass.static.GRAPHIC_OFFSET = {2,2,0}
thisclass.static.GRAPHIC_SIGS = {
	[classname] = {4,4}
}

thisclass:include(Base)
thisclass:include(HasGraphics)

function thisclass:init(x, y)
	baseentity.init(self, x-.5, y-.5, 0, nil, parent)
	
	self.speedy = -self.class.bubblesspeed
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	-- what the heck is going on here
	self.speedy = self.speedy + (math.random()-0.5)*dt*100
	
	if self.speedy < -self.class.bubblesspeed-self.class.bubblesmargin then
		self.speedy = -self.class.bubblesspeed-self.class.bubblesmargin
	elseif self.speedy > -self.class.bubblesspeed+self.class.bubblesmargin then
		self.speedy = -self.class.bubblesspeed+self.class.bubblesmargin
	end
	
	self.y = self.y + self.speedy*dt
	
	if underwater then
		if self.y < self.class.bubblesmaxy then
			self:remove()
		end
	else
		local x = math.floor(self.x)+1
		local y = math.floor(self.y)+1
		
		if not inmap(x, y) then
			self:remove()
		end
		
		if not tilequads[map[x][y][1]]:getproperty("water", x, y) then
			self:remove()
		end
	end
	
	return self.destroy
end

function bubble:draw()
	love.graphics.draw(self.graphic, self.quad, math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale, 2, 2)
end