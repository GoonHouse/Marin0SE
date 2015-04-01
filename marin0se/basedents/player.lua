local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]
--thisclass.inithooks = {}

thisclass.static.PHYS_BODY_MASS						= 1 --kg
thisclass.static.PHYS_BODY_CENTER_OF_MASS	= {16, 16} --X px, Y px
thisclass.static.PHYS_BODY_TYPE						= "dynamic"
thisclass.static.PHYS_BODY_LINEAR_DAMPING	= 10 --???
thisclass.static.PHYS_SHAPE								= "rectangle"
thisclass.static.PHYS_SHAPE_SIZE						= {32, 32} --px

thisclass.static.ANIM_SIGS = {
	jumpman_super_2hgun_0_idle = {
		frames = {1},
		grids = {1,1},
		size = {32, 32},
	},
	jumpman_super_2hgun_0_duck = {
		frames = {1},
		grids = {1,1},
		size = {32, 32},
	},
	jumpman_super_2hgun_0_jump = {
		frames = {1},
		grids = {1,1},
		size = {32, 32},
	},
	jumpman_super_2hgun_0_swim = {
		frames = {0.3,0.3},
		grids = {'1-2',1},
		size = {32, 32},
	},
	jumpman_super_2hgun_0_walk = {
		frames = {0.2, 0.2, 0.2, 0.2},
		grids = {'1-4',1},
		size = {32, 32},
	},
}

thisclass.static.GRAPHIC_SIGS = {
	[classname] = thisclass.static.PHYS_SHAPE_SIZE
}

thisclass.static.CONTROL_LOOKUP_MYSTERY	= {
	playerJump = "jump",
	playerDebug = "debug",
	playerRun = "run",
	playerReload = "removeportals",
	playerUse = "use",
	playerDuck = "duck",
	playerSuicide = "suicide",
	playerLeft = "leftkey",
	playerRight = "rightkey",
	playerPrimaryFire = "primaryFire",
	playerSecondaryFire = "secondaryFire",
	doug = "doug",
}

thisclass.static.CONTROL_LOOKUP = {
	playerLeft = {
		itype = "key",
		const = "a",
	},
	playerRight = {
		itype = "key",
		const = "d",
	},
	playerJump = {
		itype = "key",
		const = "w",
	},
	playerDuck = {
		itype = "key",
		const = "s",
	},
	doug = {
		itype = "key",
		const = " ",
	},
	comboDebug = {
		{
			itype = "key",
			const = "x",
		},
		{
			itype = "key",
			const = "c",
		},
	},
}

thisclass:include(CanBeControlled)
--[[


thisclass:include(CanDamage) --before physics so that we maintain 
]]
--thisclass:include(IsWorldObject) -- before advanced physics
thisclass:include(AdvancedPhysics)
thisclass:include(AdvancedGraphics)
thisclass:include(CanBeControlled)
thisclass:include(HasAnimations)
--[[
thisclass:include(CanCollect)
thisclass:include(CanUsePowerUp)
thisclass:include(CanUseWeapon)


thisclass:include(CanEmancipate)
thisclass:include(CanInfluence)
thisclass:include(CanPortal)
--thisclass:include(CanCarry)
thisclass:include(CanFunnel)

--thisclass:include(IsMappable) --must be preceeded by HasGraphics and optionally HasOutputs
]]
function thisclass:init(world, x, y, z)
	baseentity.init(self, world, x, y, z)
	--self:setWorld(world)
	--self:setPosition(x, y, z)
	self.width = 32
	self.height = 32
	
	self.character = "jumpman"
	self.powerupstate = "super"
	self.holdtype = "2hgun"
	self.aimangle = 0
	self.animname = "walk"
	
	
	self.vx = 0
	self.vy = 0
	self.movemap = {false, false, false, false} --left right up down
	--self:setControlLookupFromStatic(thisclass.static.CONTROL_LOOKUP)
end
local forcemult = 64000

function thisclass:draw(...)
	baseentity.draw(self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	local vx, vy = 0, 0
	if self.movemap[1] then
		vx = vx - forcemult*dt
	end
	if self.movemap[2] then
		vx = vx + forcemult*dt
	end
	if self.movemap[3] then
		vy = vy - forcemult*dt
	end
	if self.movemap[4] then
		vy = vy + forcemult*dt
	end
	self.body:applyForce(vx, vy)
end

function thisclass:leftkey(st)
	self.movemap[1] = st
end

function thisclass:rightkey(st)
	self.movemap[2] = st
end

function thisclass:jump(st)
	self.movemap[3] = st
end

function thisclass:duck(st)
	self.movemap[4] = st
end

function thisclass:doug(st)
	if st then
		self:setAnimation("jumpman_super_2hgun_0_swim")
	else
		self:setAnimation("jumpman_super_2hgun_0_walk")
	end
end