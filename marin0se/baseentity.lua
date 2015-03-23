baseentity = class('baseentity')
baseentity.mixedins = {}
-- these variables are only available to "baseentity", not its children

--[[@NOTE FOR WHEN I WAKEUP:
	instead of dynamically hooking the update/draw we can use a class table of conditions
	called "mixedins" that conditions based on the presence of a mixin
]]

--[[
	RESERVED SPECIAL PROPERTIES FOR MIDDLECLASS:
	name,
	class,
	super,
	static,
	included,
	__mixins,
	init,
	__instanceDict,
]]

--[[
	SIGNIFICANT STATICS:
	since these will never change, we make use of this data per-class,
	
	DEFINED IN EACH CLASS:
	image_sigs
]]

--[[
	SPECIAL CLASSES MADE USE OF BY MIXINS:
	CanEmancipate:	emancipateanimation->emancipationfizzle
	CanCarry:		userect
]]

function baseentity:init(x, y, z, r, parent)
	local mix = self.class.__mixins
	self.parent = parent --(or nil)
	
	if r then
		self.r = {}
		for k,v in ipairs(r) do
			if k > 2 then
				--1 = ???
				--2 = entity lookup id
				table.insert(self.r, v)
			end
		end
	end
	
	if mix[HasGraphics] then
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
	end
	
	if mix[HasPhysics] then
		local size = self.class.UNI_SIZE or self.class.PHYS_SIZE
		if self.class.UNI_SIZE then
			self:setSize(size[1]/16, size[2]/16, size[3]/16)
		else
			self:setSize(size[1], size[2], size[3])
		end
		local posoff = {-1, -1, 0}
		if self.class.MAPPABLE_CENTERX then
			local multi = math.ceil(self.width)*16
			--[[
				this is to correct for objects larger than 16 units,
				finding the nearest multiple of 16 to apply against
			]]
			posoff[1] = posoff[1] + (multi%self.width)/2
		end
		if self.class.MAPPABLE_FLUSHY then
			posoff[2] = posoff[2] + (math.ceil(self.height)-self.height)
		end
		self:setPosition(x+posoff[1], y+posoff[2], z+posoff[3])
	end
	
	if mix[CanCarry] then
		self.userect = userect:new(self.x, self.y, self.width, self.height, self)
	end
	
	if mix[Base] then
		local size = self.class.BASE_SIZE
		--self:setSize(size[1], size[2], size[3])
		self:setPosition(x, y, z)
		--self:setCo(x, y, z)
	end
	
	if mix[CanInfluence] then
		self:setInfluence(parent)
	end
	
	
	-- if it has a an orientation, you should use this to set it. should be a direction enum key.
	self.dir = "right"
	
	-- TIME TRACKING
	--self.timer = 0
	-- the once timer gets to this, we clear and do timercallback
	--self.timermax = 1
	
	-- should we destroy ourselves in the next update
	self.destroy = false
	-- self-manage our copy in the right tables
	if mix[IsMappable] then
		-- use the existence of the name attribute to map a variable to self
		for k,v in pairs(self.class.EDITOR_RCM) do
			if v.name then
				self:getBasicInput(v.name)
			end
		end
	else
		-- mapped entities are already inserted
		table.insert(objects[self.class.name], self)
	end
end

--[[function baseentity:timercallback()
	-- this gets called whenever the internal timer gets this big
	-- usually this is just for animation
	self:setQuad(self.quadi)
	self.quadi = self.quadi + 1
end]]

function baseentity:update(dt)
	local mix = self.class.__mixins
	
	if mix[CanBeControlled] then
		self.binds:update()
	end
	
	--[[this came from fireball, not sure if it's global:
		rotate back to 0 (portals)
	]]
	if mix[CanPortal] then
		--self.rotation = unrotate(self.rotation, self.gravitydirection, dt)
	end
	
	--[[self.timer = self.timer + dt
	
	if self.timer > self.timermax then
		self.timer = self.timer % self.timermax
		self:timercallback()
	end]]
	
	if self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight and self.active then
		self:offscreencallback()
	end
	
	--MIXIN CASES
	if mix[HasPhysics] then
		if self.falling then
			self.friction = 0 --self.base_friction*self.base_friction_air_multiplier
		else
			self.friction = self.base_friction
		end
	end
	
	if mix[CanFunnel] then
		if self.funnel and not self.infunnel then
			self:funnelcallback(true)
		elseif not self.funnel and self.infunnel then
			self:funnelcallback(false)
		end
		--[[
			this is the default, but iirc I thought funnel managed
			this bool on objects it handles/releases
		]]
		self.funnel = false 
	end
	
	-- handle carried objects, arguably, this should be in the player's update method
	if mix[CanCarry] then
		if self.carrier then
			local oldx = self.x
			local oldy = self.y
			
			self.x = self.carrier.x+math.sin(-self.carrier.pointingangle)*0.3+(self.carrier.speedx*dt)
			self.y = self.carrier.y-math.cos(-self.carrier.pointingangle)*0.3+(self.carrier.speedy*dt)
			if self.portaledframe == false then
				--@WARNING: this code is basically checkforemances in physics.lua \o/
				for h, u in pairs(objects["emancipationgrill"]) do
					if u.active then
						if u.dir == "hor" then
							if inrange(self.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, oldy, self.y, true) then
								print("trying to emancipate self because carrier")
								self:emancipate(h)
							end
						else
							if inrange(self.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, oldx, self.x, true) then
								print("trying to emancipate self because carrier")
								self:emancipate(h)
							end
						end
					end
				end
			end
			
			self.rotation = self.carrier.rotation
		end
		self.userect:setPos(self.x+self.speedx*dt, self.y+self.speedy*dt)
		self.portaledframe = false
	end
	
	
	--MIXIN
	if mix[HasSounds] then
		for k,v in pairs(self.activesounds) do
			if v.moves then
				v.source:setPosition(self.x, self.y, self.z)
			end
			if v.use_velocity then
				v.source:setVelocity(self.speedx, self.speedy, self.speedz)
			end
		end
		
		-- run a filtered deletion on sounds that are completed
		--@NOTE: Consider converting this to the more general filter library.
		if #self.activesounds > 0 then
			table.fdelete(self.activesounds, self.filters.delete_sounds)
		end
	end
	
	
	if self.destroy then
		--prepare for the cold embrace of death
		self:remove()
	end
	
	-- let us know we're going to die
	return self.destroy
end

function baseentity:remove()
	-- in the event that an entity utilizes special resources that must be released
	if timer.Exists(self) then
		timer.Destroy(self)
	end
	self.destroy = true --but we can also use it to delete ourselves if we weren't going to
end


-- WONDERFUL COLLECTION OF CALLBACKS
function baseentity:offscreencallback()
	-- do something if we're no longer visible, usually it's disappear
	self:remove()
end

--[[ no special draw instructions, the engine supplies it if we lack it
function baseentity:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.graphic, self.quad, math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end]]