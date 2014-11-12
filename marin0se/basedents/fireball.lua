local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

thisclass.static.PHYS_SIZE			= {8/16, 8/16, 8/16}

thisclass.static.GRAPHIC_QUADCENTER = {4,4,0}
thisclass.static.GRAPHIC_OFFSET = {4,4,0}
thisclass.static.GRAPHIC_SIGS = {
	fireball = {8,8},
	fireball_explosion = {16,16}
}

thisclass.static.SOUND_SIGS = {
	fireball = {},
	blockhit = {},
}


-- custom stuff
thisclass.static.fireballspeed = 15 --15 was good before making it physical, now it bounces too far with a gravity of 40 7.5
thisclass.static.fireballjumpforce = 12 --12 was good, toning it down 10
thisclass.static.frametime = 0.04
thisclass.static.deadtable = {"tile", "portalwall", "spring"}
-- bulletbill was once in this list, but since he was promoted to an enemy, ignore that

-- get some mixins
thisclass:include(HasPhysics)
thisclass:include(HasGraphics)
thisclass:include(HasSounds)

thisclass:include(CanEmancipate)
thisclass:include(CanInfluence)
thisclass:include(CanPortal)
thisclass:include(CanFunnel)

function thisclass:init(x, y, dir, parent)
	baseentity.init(self, thisclass, classname, x, y, 0, nil, parent)
	
	-- baseentity overrides
	self.y = y-4/16 --this was positive, now it's negative so that firing on top of a single block is accurate
	self.dir = dir or self.dir
	if self.dir == "right" then
		self.speedx = thisclass.fireballspeed
		self.x = x+6/16
	elseif self.dir == "left" then
		self.speedx = -thisclass.fireballspeed
		self.x = x
	else
		print("WARNING: Tried to spawn a fireball in a nonstandard direction: ", dir)
	end
	self.category = 13
	self.mask = {	true,
					false, true, false, false, true,
					false, true, false, true, false,
					false, true, false, true, false,
					true, true, false, false, false,
					false, true, false, false, true,
					false, false, false, false, true}
	self.doesdamagetype = "fireball"
	--self.gravity = 40
	--unused, because we get a better value elsewhere I guess
	
	-- custom vars
	self.exploded = false
	-- used for when the fireball hits something
	
	timer.Create(self, thisclass.frametime, 0,
		function()
			if self.exploded and self.quadi > globalimages[self.graphicid].frames then
				self.destroy = true
			end
			
			self:nextFrame()
		end
	)
	timer.Start(self)
	
	self:playSound(classname, false, true)
end

function thisclass:remove()
	if not self.exploded then
		self.parent:fireballcallback()
	end
	baseentity.remove(self)
end

function thisclass:update(dt)
	return baseentity.update(self, dt)
end

--@NOTE: I'm not even sure all these collides are necessary, but here we are
function thisclass:leftcollide(a, b)
	self.x = self.x-.5
	self:hitstuff(a, b)
	
	self.speedx = thisclass.fireballspeed
	return false
end

function thisclass:rightcollide(a, b)
	self:hitstuff(a, b)
	
	self.speedx = -thisclass.fireballspeed
	return false
end

function thisclass:floorcollide(a, b)
	if not table.contains(thisclass.deadtable, a) then
		self:hitstuff(a, b)
		if a=="spring" then
			print("ALERT: The code for fireballs and springs is unverified, please ensure nothing terrible happened.")
		end
	end
	
	self.speedy = -thisclass.fireballjumpforce
	return false
end

function thisclass:ceilcollide(a, b)
	self:hitstuff(a, b)
end

function thisclass:passivecollide(a, b)
	self:ceilcollide(a, b)
	return false
end

-- custom methods
function thisclass:hitstuff(a, b)
	if table.contains(thisclass.deadtable, a) then
		self:explode()
		self:playSound("blockhit", true, false)
	elseif a == "enemy" then
		--@NOTE: If we don't do damage here, we could make a koopa shell turn around post-explosion.
		b:do_damage(self.doesdamagetype, self.lastinfluence, self.dir)
		self:explode()
	--else
		--print("NOTE: Investigating collisions, fireball went past a", a)
	end
end

function thisclass:explode()
	if self.active then
		self.parent:fireballcallback()
		
		self.exploded = true
		self:setGraphic("fireball_explosion")
		self.active = false
	end
end