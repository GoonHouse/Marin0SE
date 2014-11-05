baseentity = class('baseentity')
-- these variables are only available to "baseentity", not its children
baseentity.static.isSane = true

--[[
	first time, for each class:
		* imagelist, all graphic parts
		* soundlist, all sounds introduced by this entity
		* objects[classname], gotta do the do
		* quadsmatrix, graphics are useless without sizes
]]

-- the following are mixins used to imbue properties to a class without being a child of another class
-- OtherClass:include(HasOutputs) gives it all elements of that table
local HasInputs = {
	inputTable = {},
	link = function(self)
		while #self.r > 3 do
			for j, w in pairs(outputs) do -- factor this out please
				for i, v in pairs(objects[w]) do -- this also seems unnecessary
					--check if the coordinates match a linked object
					if tonumber(self.r[3]) == v.cox and tonumber(self.r[4]) == v.coy then
						-- alert the item that they have a new listener
						v:addOutput(self, self.r[2])
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

local HasOutputs = {
	outputTable = {},
	addOutput = function(self, a, t)
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
}

local HasCustomColliders = {
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

--[[
	SIGNIFICANT STATICS:
	since these will never change, we make use of this data per-class,
	I'm not even sure how middleclass will handle attempting to mess with them
	
	DEFINED IN EACH CLASS:
	image_sigs --used to provide info for allocate_image
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
	-- visibility determines whether the draw method is called -- drawable I'm not sure where it's even used
	self.visible, self.drawable = true, true
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
	-- ie: gravity is tweaked differently in physics.lua
	--self.gravity = 0
	self.gravitydirection = math.pi/2
	-- whether or not this object should be emancipatable
	self.emancipationcheck = false
	-- this will be used to prevent further updates once emancipated
	self.was_emancipated = false
	-- static means that it doesn't intend on moving, therefore, it will save us some calculations
	self.static = true
	-- this will make it so that the object can be collided with and will invoke its update method
	self.active = true
	-- @TODO
	self.category = 22
	self.mask = {true}
	-- if it has a an orientation, you should use this to set it. should be a direction enum key.
	self.dir = "down"
	
	
	-- THIS ALL HAS TO DO WITH ENGINE TRAITS
	-- whether the object can be carried and held in the player's hands like a box
	self.carriable = false
	-- who is carrying the this, if anybody at all
	self.carrier = nil
	-- should we destroy ourselves in the next update
	self.destroy = false
	
	-- THIS ALL HAS TO DO WITH THE GRAPHICS ON LEVEL 3
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
	-- do something if we're no longer visible
end

function baseentity:timercallback()
	-- this gets called whenever the internal timer gets this big
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
	
	-- check each sound to update its positions
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

--[[ no special draw instructions \o/
function baseentity:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.graphic, self.quad, math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end]]

function baseentity:emancipate()
	if not self.was_emancipated then
		table.insert(objects["emancipateanimation"], emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, self.speedx, self.speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self.was_emancipated = true
		self.drawable = false
	end
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
		ply:carry(self)
	end
end

function baseentity:dropped()
	if self.carriable then
		self.carrier = nil
		self.active = true
	else
		print("WARNING: baseentity was dropped but it wasn't supposed to be carried in the first place.")
	end
end