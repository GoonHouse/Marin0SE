local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.basespeed = 45
thisclass.static.colortable = {
	{242, 111, 51},
	{251, 244, 174},
	{95, 186, 76},
	{29, 151, 212},
	{101, 45, 135},
	{238, 64, 68},
}
thisclass.static.effectstripes = 24
thisclass.static.frametime = 0.03
thisclass.static.effectframes = 49
thisclass.static.effectearthquake = 50

-- engine stuff
thisclass.static.GRAPHIC_QUADCENTER = {102,91,0}
thisclass.static.GRAPHIC_OFFSET = {102,91,0}
thisclass.static.GRAPHIC_SIGS = {
	rainboom = {204,182}
}
thisclass.static.SOUND_SIGS = {
	rainboom = {}
}

thisclass:include(Base)
thisclass:include(HasGraphics)
thisclass:include(HasSounds)

function thisclass:init(x, y, dir, parent)
	baseentity.init(self, x, y, 0, nil, parent)
	
	--@WARNING: we touched a global and feel filthy
	earthquake = thisclass.effectearthquake
	
	if parent then
		parent.rainboomallowed = false
		-- dio brando the horse shaped husbando
		parent.hats = {34}
	end
	
	-- due to a technicality, everything that is visible is also everything this player knows about
	--@WARNING: When we make a method to get things visible, use it here.
	for i, v in pairs(objects["enemy"]) do
		v:do_damage("pow", parent)
		--parent:getscore(firepoints[v.t] or 100, v.x, v.y)
	end
	
	self.roll = 0 
	if dir == "up" then
		self.roll = -math.pi/2
	elseif dir == "down" then
		self.roll = math.pi/2
	elseif dir == "left" then
		self.roll = math.pi
	end
	
	self.drawable=false --@WARNING: prevent the global drawhandler for now
	
	timer.Create(self, thisclass.frametime, 0,
		function()
			if self.quadi > globalimages[self.graphicid].frames then
				self.destroy = true
			else
				self:nextFrame()
			end
		end
	)
	timer.Start(self)
	
	self:playSound(classname, false, true)
end

function thisclass:draw()
	love.graphics.draw(self.graphic, self.quad, (self.x-xscroll)*16*scale, (self.y-yscroll-0.5)*16*scale, self.roll, scale, scale, 29, 92)
end