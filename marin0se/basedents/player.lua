local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

thisclass.static.UNI_SIZE			= {16, 16, 16}

thisclass.static.GRAPHIC_SIGS = {
	[classname] = thisclass.static.UNI_SIZE,
	[classname.."_companion"] = thisclass.static.UNI_SIZE,
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

thisclass:include(CanDamage) --before physics so that we maintain 

thisclass:include(IsWorldObject) -- before advanced physics

thisclass:include(AdvancedPhysics)
thisclass:include(HasGraphics)

thisclass:include(CanCollect)
thisclass:include(CanUsePowerUp)
thisclass:include(CanUseWeapon)


thisclass:include(CanEmancipate)
thisclass:include(CanInfluence)
thisclass:include(CanPortal)
--thisclass:include(CanCarry)
thisclass:include(CanFunnel)

--thisclass:include(IsMappable) --must be preceeded by HasGraphics and optionally HasOutputs

function thisclass:init(world, x, y, z)
	--baseentity.init(self, x, y, z)
	self:setWorld(world.pworld)
	self:setPosition(x, y, z)
	self.width = 16
	self.height = 16
	self:newSimplePhysics()
	
	self:setGraphic(self.class.name, true)
	self:setCo(x, y, z)
	if self.class.UNI_SIZE then
		local size = self.class.UNI_SIZE
		self:setOffset(size[1]/2, (16-size[2])*.5, size[3]/2)
		self:setQuadCenter(size[1]/2, size[2]/2, size[3]/2)
	else
		self:setOffset(self.class.GRAPHIC_OFFSET)
		self:setQuadCenter(self.class.GRAPHIC_QUADCENTER)
	end
	
	self:setControlLookupFromStatic(thisclass.static.CONTROL_LOOKUP)
end

function thisclass:update(dt)
	return baseentity.update(self, dt)
end