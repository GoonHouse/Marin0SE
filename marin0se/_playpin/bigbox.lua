local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

thisclass.static.UNI_SIZE			= {24, 24, 24}

thisclass.static.MAPPABLE_CENTERX = true
thisclass.static.MAPPABLE_FLUSHY = true
thisclass.static.GRAPHIC_SIGS = {
	[classname] = thisclass.static.UNI_SIZE,
	[classname.."_companion"] = thisclass.static.UNI_SIZE,
}
--@NOTE: These aren't used yet.
thisclass.static.EDITOR_ENTDEX		= 21
thisclass.static.EDITOR_CATEGORY	= "portal elements"
thisclass.static.EDITOR_DESC		= "place on empty tile - big weighted storage cube"
thisclass.static.EDITOR_ICONAUTHOR	= "alesan99"
thisclass.static.EDITOR_RCM			= {
	{t="text", value="variant:"},
	{t="submenu", entries={"weighted", "companion"}, default="weighted", width=9, name="variant", actualvalue=true},
}

-- get some mixins
thisclass:include(CanDamage) --before physics so that we maintain 

thisclass:include(HasPhysics)
thisclass:include(HasGraphics)
thisclass:include(HasOutputs)

thisclass:include(CanEmancipate)
thisclass:include(CanInfluence)
thisclass:include(CanPortal)
thisclass:include(CanCarry)
thisclass:include(CanFunnel)

thisclass:include(IsMappable) --must be preceeded by HasGraphics and optionally HasOutputs

function thisclass:init(x, y, r)
	baseentity.init(self, x, y, 0, r)
	--PHYSICS STUFF
	self.category = 9
	self.mask = {	true,
					false, false, false, false, false,
					false, true, false, true, true,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true}
	self.friction = 20
	self.base_friction = 20
	
	if self.variant and self.variant == "companion" then
		self:setGraphic("box_companion", true)
	end
	
	
	
	-- custom vars
	self.portaledframe = false
	-- whether we were pushed by the player
	self.pushed = false --this *should* be further up the chain, but, being pushable isn't demonstrated with any other object
	--self.userect = userect:new(self.x, self.y, self.class.PHYS_SIZE[1], self.class.PHYS_SIZE[2], self)
end

function thisclass:update(dt)
	baseentity.update(self, dt) --remember: this modifies self.destroy + returns it
	
	-- not sure if this is necessary, I think it should be elevated to 
	if not self.pushed then
		if self.speedx > 0 then
			self.speedx = self.speedx - self.friction*dt
			if self.speedx < 0 then
				self.speedx = 0
			end
		else
			self.speedx = self.speedx + self.friction*dt
			if self.speedx > 0 then
				self.speedx = 0
			end
		end
	else
		self.pushed = false
	end
	
	return self.destroy
end

function thisclass:globalcollide(a, b, c, d, dir)
	if a == "platform" or a == "seesawplatform" then
		if dir == "floor" then
			if self.jumping and self.speedy < -jumpforce + 0.1 then
				return true
			end
		else
			return true
		end
	end
end

function thisclass:ceilcollide(a, b)
	if self:globalcollide(a, b, c, d, "ceil") then
		return false
	end
end

function thisclass:leftcollide(a, b)
	if self:globalcollide(a, b, c, d, "left") then
		return false
	end

	if a == "button" then
		self.y = b.y - self.height
		self.x = b.x + b.width - 0.01
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "player" then
		self.pushed = true
		return false
	end
end

function thisclass:rightcollide(a, b)
	if self:globalcollide(a, b, c, d, "right") then
		return false
	end
	
	if a == "button" then
		self.y = b.y - self.height
		self.x = b.x - self.width+0.01
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "player" then
		self.pushed = true
		return false
	end
end

function thisclass:floorcollide(a, b)
	if self:globalcollide(a, b, c, d, "floor") then
		return false
	end
	
	if self.falling then
		self.falling = false
	end
	
	if a == "enemy" and b.stompable then
		self:doDamage(b)
		--addpoints(200, self.x, self.y)
		--playsound("stomp", self.x, self.y, self.speedx, self.speedy)
		self.falling = true
		self.speedy = -10
		return false
	end
end

--[[@NOTE: this is here because boxes, when shoved, weren't properly evaluating emancipation rects,
			it's still broken, but, now it's less broken
function debugbox()
	for k,v in pairs(objects["box"]) do
		print("box#", k, "is", v.pushed, "at", v.x, v.y, v.cox, v.coy)
		local u = objects["emancipationgrill"][1]
		if u.dir == "hor" then
			print("grill was hor")
			print("test1", inrange(v.x+6/16, u.startx-1, u.endx, true))
			print("test2", inrange(u.coy-14/16, v.y, v.y+v.speedy*gdt, true))
		else
			print("grill was ver")
			local b1 = u.cox-14/16
			local b2 = v.x-14/16
			local b3 = v.x+v.speedx*gdt+14/16
			print("test1", inrange(v.y+6/16, u.starty-1, u.endy, true))
			print("test2", inrange(b1, b2, b3, true)) --
			print("inv", b1, b2, b3)
		end
	end
end
]]

function thisclass:passivecollide(a, b)
	if self:globalcollide(a, b, c, d, "passive") then
		return false
	end
	
	if a == "player" then
		if self.x+self.width > b.x+b.width then
			self.x = b.x+b.width
		else
			self.x = b.x-self.width
		end
	end
end


function thisclass:remove()
	self.userect.destroy = true --need a better way of handling this, but userects aren't their own entity yet
	self.destroy = true
	self:toggle_all_outputs()
end

-- custom methods
function thisclass:onbutton(s)
	-- this is making the assumption that lighting up has no animation
	if s then
		self:setQuad(1)
	else
		self:setQuad(2)
	end
end