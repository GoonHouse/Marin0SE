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
thisclass.static.image_sigs = {
	rainboom = {204,182}
}
thisclass.static.sound_sigs = {
	rainboom = {}
}

function thisclass:init(x, y, dir, parent)
	baseentity.init(self, thisclass, classname, x, y, 0, nil, parent)
	
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
	self.static = true
	self.width, self.height = 204, 182
	self.offsetX, self.offsetY = self.width/2, self.height/2
	self.quadcenterX, self.quadcenterY = self.width/2, self.height/2
	self.graphicid = classname
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	-- the comment below about self.quad also applies here
	self.quadi = 1
	self.quad = globalimages[self.graphicid].quads[self.quadi]
	self.drawable = false
	self.active = true
	self.timermax = thisclass.frametime
	self.timer = self.timermax
	
	self.r = 0 
	if dir == "up" then
		self.r = -math.pi/2
	elseif dir == "down" then
		self.r = math.pi/2
	elseif dir == "left" then
		self.r = math.pi
	end
	
	table.insert(objects[classname], self)
	self:playsound(classname, false, true)
end

function thisclass:timercallback()
	self.quadi = self.quadi + 1
	if self.quadi > globalimages[self.graphicid].frames then
		self.destroy = true
	else
		self:setQuad(self.quadi)
	end
end

function rainboom:draw()
	love.graphics.draw(self.graphic, self.quad, (self.x-xscroll)*16*scale, (self.y-yscroll-0.5)*16*scale, self.r, scale, scale, 29, 92)
end