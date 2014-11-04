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

function baseentity:init(x, y, r)
	-- if we have a parent, it's good to know
	self.parent = parent
	-- x and y are used for physics calculations against the world
	self.x, self.y = x, y
	-- z is unused, but we plan on using it, so everything exists on depth 0
	self.z = 0
	-- cox and coy generally the starting position, the place in the map where the entity was placed
	self.cox, self.coy = x, y
	-- visibility determines whether the draw method is called -- drawable I'm not sure where it's even used
	self.visible, self.drawable = true, true
	-- r is a general purpose set of packaged parameters in an explicit order that can be made use of
	-- usually for setting the rightclick attributes of placed map entities
	self.r = {unpack(r)}
	-- we dump the first two values of r because they are [read the wiki]
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
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
	self.gravity = 0
	self.gravitydirection = math.pi/2
	-- whether or not this object should be emancipatable
	self.emancipationcheck = false
	-- static means that it doesn't intend on moving, therefore, it will save us some calculations
	self.static = true
	-- this will make it so that the object can be collided with and will invoke its update method
	self.active = true
	-- @TODO
	self.category = 22
	self.mask = {true}
	-- if it has a an orientation, you should use this to set it. should be a direction enum key.
	self.dir = "down"
	
	
	-- THIS ALL HAS TO DO WITH THE GRAPHICS ON LEVEL 3
	-- if we need to be offset from the x/y for drawing
	self.offsetX, self.offsetY = 0, 0
	-- make the center of rotation
	self.quadcenterX, self.quadcenterY = 0, 0
	-- ex
	self.rotation = 0
	-- if we only utilize a single simple image then we can reference this
	self.graphic = missinggraphicimg
	
	
	
	-- if you need to make use of first-run data
	self.initial = true
	
	
	
	--table.insert(objects["weapon"], self)
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
local filter_delete_sound = function(k, v)
	return v.source:tell("samples") >= v.samplecount
end
function baseentity:update(dt)
	if self.primaryAttackDelay and self.primaryAttackTimer and self.primaryAttackTimer > 0 then
		self.primaryAttackTimer = self.primaryAttackTimer - dt
	end
	
	if self.secondaryAttackDelay and self.secondaryAttackTimer and self.secondaryAttackTimer > 0 then
		self.secondaryAttackTimer = self.secondaryAttackTimer - dt
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
end

function baseentity:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(andgateimg, math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function baseentity:emancipate(a)
	-- determine what to do when emancipated
end

function baseentity:collect(ply)
	-- the presence of this will cause the player that collides with it to invoke it,
	-- usually this should be the same as destroy but with context of being player-oriented
	-- additionally it prevents having to employ custom handlers
end