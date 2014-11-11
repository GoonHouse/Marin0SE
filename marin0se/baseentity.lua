baseentity = class('baseentity')
-- these variables are only available to "baseentity", not its children
baseentity.static.isSane = true

--[[@NOTE FOR WHEN I WAKEUP:
	instead of dynamically hooking the update/draw we can use a class table of conditions
	called "mixedins" that conditions based on the presence of a mixin
]]

baseentity_mixins = {} -- make these global so they can be applied in class definitions
--[[
	first time, for each class:
		* imagelist, all graphic parts
		* soundlist, all sounds introduced by this entity
		* objects[classname], gotta do the do
		* quadsmatrix, graphics are useless without sizes
]]

-- the following are mixins used to imbue properties to a class without being a child of another class
-- OtherClass:include(HasOutputs) gives it all elements of that table
baseentity_mixins.HasInputs = {
	inputTable = {},
	link = function(self)
		while #self.r > 3 do
			for j, w in pairs(outputs) do -- factor this out please
				for i, v in pairs(objects[w]) do -- this also seems unnecessary
					--check if the coordinates match a linked object
					if tonumber(self.r[3]) == v.cox and tonumber(self.r[4]) == v.coy then
						-- alert the item that they have a new listener
						v:addoutput(self, self.r[2])
						-- initialize the input table index with nothing
						self.inputTable[tonumber(self.r[2])] = "off"
					end
				end
			end
			table.remove(self.r, 1)
			table.remove(self.r, 1)
			table.remove(self.r, 1)
			table.remove(self.r, 1)
		end
	end,
	input = function(self, signaltype, inputindex)
		local inp = tonumber(inputindex)
		if inp then
			if signaltype == "toggle" then
				if self.inputTable[inp] == "on" then
					self.inputTable[inp] = "off"
				else
					self.inputTable[inp] = "on"
				end
			else
				-- assuming that this is either "on" or "off"
				self.inputTable[inp] = signaltype
			end
			
			-- if we want to have a purely reactive element, we would signal outputs here
			-- instead of doing it on next update
		else
			print("WARNING: Entity received an input signal that wasn't valid.")
		end
	end,
}

baseentity_mixins.HasOutputs = {
	outputTable = {},
	hasOutput = true,
	addoutput = function(self, a, t)
		table.insert(self.outputTable, {a, t})
	end,
	out = function(self, t)
		for i = 1, #self.outputTable do
			-- if it has an input method, feed it the data
			if self.outputTable[i][1].input then
				self.outputTable[i][1]:input(t, self.outputTable[i][2])
			end
			-- if it doesn't, how did it get here to begin with?
		end
	end,
	toggle_all_outputs = function(self)
		for i = 1, #self.outputTable do
			if self.outputTable[i][1].input then
				self.outputTable[i][1]:input("toggle", self.outputTable[i][2])
			end
		end
	end,
}

baseentity_mixins.HasCustomColliders = {
	leftcollide = function(self, a, b)
		return true
	end,
	rightcollide = function(self, a, b)
		return true
	end,
	ceilcollide = function(self, a, b)
		return true
	end,
	floorcollide = function(self, a, b)
		return true
	end,
}

baseentity_mixins.IsMappable = {
	--[[Takes inputs similarly to how we save the data through the editor, where signature is:
		{t="optiontype", 
	]]
	getBasicInput = function(self, vartoset)
		--vartoset corresponds to a local variable to overwrite
		if #self.r > 0 and self.r[1] ~= "link" then
			self[vartoset] = self.r[1]
			table.remove(self.r, 1)
			-- we got the data correctly
			return true
		else
			-- we did not get the data correctly
			return false
		end
	end
}

--@TODO: Make these userect things a mixin, they were previously in the global scope.

--[[
	SIGNIFICANT STATICS:
	since these will never change, we make use of this data per-class,
	I'm not even sure how middleclass will handle attempting to mess with them
	
	DEFINED IN EACH CLASS:
	image_sigs --used to provide info for allocate_image
		{imagename = {dimx, dimy}, ...}
		where dimx/y is the gridsize of the image, therefore the size of the largest possible sprite
	sound_sigs --not implemented, to provide info for allocate_sound
		{soundname = {}, ...}
		it's assumed pitch/octave/volume properties will be put here eventually, but, not now
]]

-- this is only here temporarily
function allocate_image(imgname, dimx, dimy)
	globalimages[imgname] = {quads = {}, dims={dimx,dimy}}
	local gl = globalimages[imgname]
	
	gl.img = love.image.newImageData(imgname..".png")
	local timg = love.graphics.newImage(gl.img)
	local w, h = math.floor(timg:getWidth()/dimx), math.floor(timg:getHeight()/dimy)
	gl.img = timg
	gl.frames=w*h
	for y = 1, h do
		-- Yeah, I'm not entirely certain why I'm allowing the use of y>1, but here we are.
		for x = 1, w do
			table.insert(gl.quads, love.graphics.newQuad((x-1)*dimx, (y-1)*dimy, dimx, dimy, timg:getDimensions()))
		end
	end
end

--[[ helper methods to write
	setCenter
	x setGraphic
	setOffset
	setPos
	x setQuad (by index)
	setSize
]]
-- BUNDLES OF HELPER METHODS

function baseentity:setGraphic(id, quadwrap)
	-- if quadwrap is true, we'll modulo the current quadi to the new graphic, else, reset to 1
	self.graphicid = id
	self.graphic = globalimages[self.graphicid].img
	if not quadwrap then
		self.quadi = 1
	end
	self:setQuad(self.quadi)
	-- worst case scenario, this call is redundant; best: we wrap number that's too big/small
end

function baseentity:setQuad(ind)
	ind = ind or self.quadi
	-- set the quad based on the current graphics set
	self.quadi = ind%(globalimages[self.graphicid].frames+1)
	if self.quadi == 0 then
		--the only thing modulo and 1-indexed languages weren't prepared for
		self.quadi = 1
	end
	self.quad = globalimages[self.graphicid].quads[self.quadi]
end

function baseentity:setInfluence(inf)
	if self.influencable then
		self.lastinfluence = inf
		return true
	else
		return false
	end
end

function baseentity:init(origclass, classname, x, y, z, r, parent)
	-- anonymous mapping gets confusing sometimes
	self.origclass = origclass
	self.classname = classname
	
	x = x or 0
	y = y or 0
	z = z or 0
	
	-- if we have a parent, it's good to know
	self.parent = parent --(or nil)
	-- x and y are used for physics calculations against the world
	self.x, self.y = x, y
	-- z is unused, but we plan on using it, so everything exists on depth 0
	self.z = z
	-- cox and coy generally the starting position, the place in the map where the entity was placed
	self.cox, self.coy = x, y
	-- r is a general purpose set of packaged parameters in an explicit order that can be made use of
	-- usually for setting the rightclick attributes of placed map entities
	if r~= nil then
		self.r = {unpack(r)}
		-- we dump the first two values of r because they are [read the wiki]
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
	
	--assets
	self.sounds = {} --a table of names of sounds to make use of
	self.activesounds = {} --table of clones from the global soundlist
	
	--THIS ALL HAS TO DO WITH PHYSICS
	-- the size of the bounding box to perform physics checks against
	self.width, self.height = 1, 1
	-- how fast we're moving in a particular direction
	self.speedx, self.speedy = 0, 0
	-- same as above, eventually we want to use z
	self.speedz = 0
	-- how quickly we're moved towards the direction of gravity regardless of speedx/y
	-- left out, because code elsewhere will supply a different value
	-- gravity, if nil, will be defaulted to global "yacceleration" for physics calculation
	self.gravity = 80
	-- (in radians) the angle to apply gravity to
	self.gravitydirection = math.pi/2
	--@WARNING: not fully implemented into physics.lua, byob
	self.base_friction = 14
	self.friction = self.base_friction
	--@WARNING: same as above applies, the number to multiply our friction value by while airborne
	self.base_friction_air_multiplier = 0
	self.friction_air_multiplier = self.base_friction_air_multiplier
	-- whether or not this object should be emancipatable
	self.emancipatecheck = false
	-- whether or not we override the default portal method with a local one
	self.portaloverride = false
	-- this will be used to prevent further updates once emancipated
	self.was_emancipated = false
	
	-- do faithplates care about this?
	self.can_faithplate = false
	-- is this falling? should gravity be applied?
	self.falling = false
	
	-- can the object be funneled?
	self.can_funnel = false
	-- true when this is being handled by a funnel
	self.funnel = false
	-- this is an edge-switch against funnel so that we can detect entry/exit
	self.infunnel = false
	
	-- static means that it doesn't intend on moving, therefore, it will save us some calculations
	self.static = true
	-- this will make it so that the object can be collided with and will invoke its update method
	self.active = true
	-- @TODO
	self.category = 22
	self.mask = {true}
	-- if it has a an orientation, you should use this to set it. should be a direction enum key.
	self.dir = "right"
	
	-- THIS ALL HAS TO DO WITH ENGINE TRAITS
	-- whether the object can be carried and held in the player's hands like a box
	self.carriable = false
	-- who is carrying the this, if anybody at all
	self.carrier = nil
	-- this has to do with being carried and portalability, I don't know, it's confusing
	self.portaledframe = false
	
	-- if the player and other things can push 
	self.pushable = false
	-- a flag for whether or not we're actively being pushed
	self.pushed = false
	-- should we destroy ourselves in the next update
	self.destroy = false
	
	-- if this is capable of being influenced by a player to kill someone
	self.influencable = false
	-- last player to touch this, or nobody
	self.lastinfluence = parent --nil==world
	
	-- what kind of damage this does
	self.doesdamagetype = "toilet"
	
	
	-- THIS ALL HAS TO DO WITH THE GRAPHICS ON LEVEL 3
	-- visibility determines whether the draw method is called
	-- drawable determines whether we use the base drawing method or overwrite with our own, having this and a draw method will cause double vision
	self.visible, self.drawable = true, true
	-- if we need to be offset from the x/y for drawing
	self.offsetX, self.offsetY = 0, 0
	-- make the center of rotation
	self.quadcenterX, self.quadcenterY = 0, 0
	-- ex
	self.rotation = 0
	-- the name to reference in our statics
	self.graphicid = classname
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	-- the comment below about self.quad also applies here
	self.quadi = 1
	self.quad = globalimages[self.graphicid].quads[self.quadi]
	-- I'm not even entirely certain referencing the quad manually is necessary if we are based around the indexes / images
	-- as it stands, only the emancipation routine makes use of this
	
	-- TIME TRACKING
	self.timer = 0
	-- the once timer gets to this, we clear and do timercallback
	self.timermax = 1
	
	
	-- if you need to make use of first-run data, we don't handle this in the base in the event
	-- we need to do the standard run
	self.initial = true
	
	
	
	--table.insert(objects["weapon"], self)
end

-- WONDERFUL COLLECTION OF CALLBACKS
function baseentity:offscreencallback()
	-- do something if we're no longer visible, usually it's disappear
	self.destroy = true
end

function baseentity:timercallback()
	-- this gets called whenever the internal timer gets this big
	-- usually this is just for animation
	self:setQuad(self.quadi)
	self.quadi = self.quadi + 1
end

function baseentity:funnelcallback(entering)
	-- if we go into a funnel, this is what we do
	if entering then
		self.infunnel = true
	else
		self.infunnel = false
		self.gravity = nil
	end
end

function baseentity:playsound(sound, is_static, use_velocity)
	if not soundlist[sound] then
		print("WARNING: Entity tried to play nonexistant sound: "..soundname)
		return
	end

	if soundenabled then
		if delaylist[sound] then
			local currenttime = love.timer.getTime()
			if currenttime-soundlist[sound].lastplayed > delaylist[sound] then
				soundlist[sound].lastplayed = currenttime
			else
				return
			end
		end
		local soundclone = table.combine(soundlist[sound])
		soundclone.source = soundlist[sound].source:clone()
		soundclone.static = false
		soundclone.use_velocity = false
		if is_static then
			soundclone.static = true
		end
		soundclone.source:setRelative(false)
		soundclone.source:setPosition(self.x, self.y, self.z)
		if use_velocity then
			-- velocity has the potential to sound weird, so, it's optional
			soundclone.use_velocity = true
			soundclone.source:setVelocity(self.speedx, self.speedy, self.speedz)
		else
			soundclone.source:setVelocity(0, 0, 0)
		end
		soundclone.source:play()
		table.insert(self.activesounds, soundclone)
	end
end
local function filter_delete_sounds(k, v)
	return v.source:tell("samples") >= v.samplecount
end
function baseentity:update(dt)
	--[[this came from fireball, not sure if it's global:
		rotate back to 0 (portals)
	]]
	self.rotation = 0
	self.timer = self.timer + dt
	
	if self.timer > self.timermax then
		self.timer = self.timer % self.timermax
		self:timercallback()
	end
	
	if self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight and self.active then
		self:offscreencallback()
	end
	
	-- PHYSICS HELPERS
	if self.falling then
		self.friction = self.base_friction*self.base_friction_air_multiplier
	else
		self.friction = self.base_friction
	end
	
	-- funnel magic
	if self.can_funnel then
		if self.funnel and not self.infunnel then
			self:funnelcallback(true)
		elseif not self.funnel and self.infunnel then
			self:funnelcallback(false)
		end
		self.funnel = false --this is the default, but iirc I thought funnel managed this bool on objects it handles/releases
	end
	
	-- handle carried objects, arguably, this should be in the player's update method
	if self.carriable then
		if self.carrier then
			local oldx = self.x
			local oldy = self.y
			
			self.x = self.carrier.x+math.sin(-self.carrier.pointingangle)*0.3
			self.y = self.carrier.y-math.cos(-self.carrier.pointingangle)*0.3
			if self.portaledframe == false then
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
		self.portaledframe = false
	end
	
	-- check each sound to update its positions
	if self.activesounds then
		for k,v in pairs(self.activesounds) do
			if not v.static then
				v.source:setPosition(self.x, self.y, self.z)
			end
			if v.use_velocity then
				v.source:setVelocity(self.speedx, self.speedy, self.speedz)
			end
		end
		-- run a filtered deletion on sounds that are completed
		if #self.activesounds > 0 then
			table.fdelete(self.activesounds, filter_delete_sounds)
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
end

function baseentity:portaled()
	-- this is only triggered if we have portaloverride
end

--[[ no special draw instructions, the engine supplies it if we lack it
function baseentity:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.graphic, self.quad, math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end]]

function baseentity:emancipate()
	print("baseentity told to emancipate")
	if not self.was_emancipated then
		local speedx, speedy = self.speedx, self.speedy
		if self.carrier then
			speedx = speedx + self.carrier.speedx
			speedy = speedy + self.carrier.speedy
			self.carrier:drop_held()
			self.carrier = nil --in the event that our carrier doesn't call our dropped method
		end
		table.insert(objects["emancipateanimation"], emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, speedx, speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self:remove()
		self.was_emancipated = true
		self.drawable = false
	end
end

function baseentity:faithplate(dir)
	self.falling = true
end

function baseentity:startfall() -- this is presumably used by a faithplate as a callback, I can't be sure
	self.falling = true
end

function baseentity:collect(ply)
	-- the presence of this will cause the player that collides with it to invoke it,
	-- usually this should be the same as destroy but with context of being player-oriented
	-- additionally it prevents having to employ custom handlers
end

function baseentity:used(ply)
	-- where ply is a reference to the player object
	if self.carriable then
		self.carrier = ply
		self.active = false
		ply:pick_up(self)
		self:setInfluence(ply) 
	end
end

function baseentity:drop()
	if self.carriable then
		self.carrier = nil
		self.active = true
	else
		print("WARNING: baseentity was dropped but it wasn't supposed to be carried in the first place.")
	end
end