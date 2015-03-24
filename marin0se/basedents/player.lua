local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]
--thisclass.inithooks = {}

thisclass.static.PHYS_BODY_MASS						= 1 --kg
thisclass.static.PHYS_BODY_CENTER_OF_MASS	= {8, 8} --X px, Y px
thisclass.static.PHYS_BODY_TYPE						= "dynamic"
thisclass.static.PHYS_BODY_LINEAR_DAMPING	= 10 --???
thisclass.static.PHYS_SHAPE								= "rectangle"
thisclass.static.PHYS_SHAPE_SIZE						= {16, 16} --px

thisclass.static.GRAPHIC_SIGS = {
	[classname] = thisclass.static.PHYS_SHAPE_SIZE
}

thisclass.static.CONTROL_LOOKUP	= {
	playerJump = "jump",
	playerDebug = "debug",
	playerRun = "run",
	playerReload = "removeportals",
	playerUse = "use",
	playerSuicide = "suicide",
	playerLeft = "leftkey",
	playerRight = "rightkey",
	playerPrimaryFire = "primaryFire",
	playerSecondaryFire = "secondaryFire",
	doug = "doug",
}

thisclass:include(CanBeControlled)
--[[


thisclass:include(CanDamage) --before physics so that we maintain 
]]
--thisclass:include(IsWorldObject) -- before advanced physics
thisclass:include(AdvancedPhysics)
thisclass:include(AdvancedGraphics)
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
	self.width = 16
	self.height = 16
	--self:setControlLookupFromStatic(thisclass.static.CONTROL_LOOKUP)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
end