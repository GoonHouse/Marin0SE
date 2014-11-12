HasPhysics = {
	-- keep in mind that x/y are linked to draw positions 
	x = 0, roll  = 0, width  = 0, speedx = 0, centerx = 0,
	y = 0, pitch = 0, height = 0, speedy = 0, centery = 0,
	z = 0, yaw   = 0, depth  = 0, speedz = 0, centerz = 0,
	--[[
		"center" attributes are provided as a convenience
		if you offset them I'll break your fingers, you monster
	]]
	
	mass = 0, --this is here because supplying gravity as a number makes no sense
	
	-- gravity should be a product of these things here
	gravity = 80, --added/subtracted across x/y/z
	gravitydirection = math.pi/2, --(in radians) the angle to apply gravity to
	friction = 14, --14 is the player's base friction, the box is 20
	friction_airmult = 0, --calculated from friction to get air friction
	
	-- is this falling? should gravity be applied?
	falling = true,
	
	-- if the player and other things can push 
	pushable = false,
	-- a flag for whether or not we're actively being pushed
	pushed = false,
	
	-- regardless of influence we do this
	doesdamagetype = "physics",
	
	-- collision
	category = 1,
	mask = {true},
	
	--[[
		these both control physics updates
		
		moves is used to discriminate against checkrect
		active is used to determine whether it should be considered for physupdate
	]]
	active = true, --this is meant to be turned on and off
	moves = true, --man what does this do
}

function HasPhysics:setPosition(nx, ny, nz)
	if type(nx) == "table" then
		nz = nx[3]
		ny = nx[2]
		nx = nx[1]
	end
	self.x = nx or 0
	self.y = ny or 0
	self.z = nz or 0
end

function HasPhysics:setSpeed(nx, ny, nz)
	if type(nx) == "table" then
		nz = nx[3]
		ny = nx[2]
		nx = nx[1]
	end
	self.speedx = nx or 0
	self.speedy = ny or 0
	self.speedz = nz or 0
end

function HasPhysics:setSize(nw, nh, nd)
	if type(nw) == "table" then
		nd = nd[3]
		nh = nh[2]
		nw = nw[1]
	end
	self.width  = nw or 0
	self.height = nh or 0
	self.depth  = nd or 0
	
	self.centerx = self.width/2
	self.centery = self.height/2
	self.centerz = self.depth/2
end



--[[Takes inputs similarly to how we save the data through the editor, where signature is:
	{t="optiontype", 
]]
--[[function IsMappable:included(klass)
	-- Go through the input map
	for k,v in pairs(klass.INPUT_MAP) do
		self:getBasicInput(v)
	end
end]]