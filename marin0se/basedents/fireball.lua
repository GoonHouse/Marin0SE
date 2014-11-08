local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.fireballspeed = 15
thisclass.static.fireballjumpforce = 12
thisclass.static.frametime = 0.04
thisclass.static.deadtable = {"tile", "portalwall", "spring"}
-- bulletbill was once in this list, but since he was promoted to an enemy, ignore that

-- engine stuff
thisclass.static.image_sigs = {
	fireball = {8,8},
	fireball_explosion = {16,16}
}
thisclass.static.sound_sigs = {
	fireball = {},
	blockhit = {},
}
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
	self.width = 8/16
	self.height = 8/16
	self.static = false
	self.category = 13
	self.mask = {	true,
					false, true, false, false, true,
					false, true, false, true, false,
					false, true, false, true, false,
					true, true, false, false, false,
					false, true, false, false, true,
					false, false, false, false, true}
	self.emancipatecheck = true
	self.offsetX, self.offsetY = 4, 4
	self.quadcenterX, self.quadcenterY = 4, 4
	self.timermax = thisclass.frametime
	self.influencable = true
	self.doesdamagetype = "fireball"
	--self.gravity = 40
	--unused, because we get a better value elsewhere I guess
	
	-- custom vars
	self.exploded = false
	-- used for when the fireball hits something
	-- we do this because it's not implemented into baseentity yet, it's the player that caused this
	
	self:playsound(classname, false, true)
end

function thisclass:timercallback()
	if self.quadi > globalimages[self.graphicid].frames then
		--print("rolling back", self.exploded, self.quadi, globalimages[self.graphicid].frames)
		if self.exploded then
			self.destroy = true
			--self.quadi = globalimages[self.graphicid].frames
		end
	end
	
	self:setQuad(self.quadi)
	-- we're technically a frame behind, but, meh
	self.quadi = self.quadi + 1
end

function thisclass:offscreencallback()
	self.parent:fireballcallback()
	self.destroy = true
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
		self:playsound("blockhit", true, false)
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