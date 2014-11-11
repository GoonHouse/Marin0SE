local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

thisclass.static.image_sigs = {
	box = {12,12},
}
-- data for editor
thisclass.static.category		= "portal elements"
thisclass.static.description	= "place on empty tile - weighted storage cube"
thisclass.static.iconauthor		= "alesan99"
thisclass.static.hasOutput		= true
thisclass.static.rightclickmenu	= {
	{t="text", value="type:"},
	{t="submenu", entries={"weighted", "companion"}, default=1, width=9},
}
-- get some mixins
thisclass:include(baseentity_mixins.HasOutputs)
--thisclass:include(baseentity_mixins.IsMappable)
function thisclass:init(x, y, r)
	baseentity.init(self, thisclass, classname, x, y, 0, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-14/16
	self.y = y-12/16
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.category = 9
	self.portaloverride = true
	self.mask = {	true,
					false, false, false, false, false,
					false, true, false, true, true,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true}
	self.emancipatecheck = true
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 6
	self.quadcenterY = 6
	self.base_friction = 20
	self.can_funnel = true
	self.carriable = true
	self.influencable = true
	self.lastinfluence = parent
	self.doesdamagetype = "physics"
	
	-- custom vars
	self.portaledframe = false
	-- whether we were pushed by the player
	self.pushed = false --this *should* be further up the chain, but, being pushable isn't demonstrated with any other object
	self.userect = userect:new(self.x, self.y, 12/16, 12/16, self)
	--self:getBasicInput("variant") --reads input from "r" as variable "variant"
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
	
	-- update our userect
	self.userect:setPos(self.x, self.y)
	
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
	
	if a == "enemy" and b.killedbyboxes then
		b:do_damage(self.doesdamagetype, self)
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

function thisclass:portaled()
	self.portaledframe = true
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