--[[
	Here's the foundation for a bind system that works with LOVE 0.9.1 
	It requires the following features:
		* An input from any device sends a signal, which is traditionally a bind.
		* One input to many signals.
		* Comboing signals to produce a new signal.
		* Mouse virtualization to input pairs.
		* Convert digital signals 
]]

--[[@NOTES:
	when interfacing with this, mapping controller IDs to names:
	save the controller name and its current ID,
	try to find a controller with stored name -- fallback on existing ID if found
]]

local enum_itypes = {
	"key",
	"mouseaxis",
	"mousebtn",
	--mousegesture ???
	"joyaxis",
	"joybtn",
	"joyhat",
}

--[[
	a complete set of examples of valid itypes
	
	key = {
		itype = "key",
		const = "x", --https://www.love2d.org/wiki/KeyConstant
	},
	joyaxis = {
		itype = "joyaxis",
		joystick = 1, --the id of the joystick to use
		axis = 1, --the axis id of the joystick to probe
	}
]]

local example_keymap = {
	config = {
		-- are we using any joysticks?
		useJoysticks = false,
	},
	
	controls = {
		-- standard name = {table of properties}
		-- OR
		-- standard name = {{key1}, {key2}}
		--[[
			itype		=	input_enum
		]]
		playerDebug = {
			itype = "key",
			const = "x",
		},
	}
}

neubind = class("neubind")

function neubind:init(inputtable)
	if love.joystick then
		-- go through all connected joysticks and get their signatures
		self.joysigs = {}
		self.joys = love.joystick.getJoysticks()
		for i, joystick in ipairs(self.joys) do
			self.joysigs[i] = {
				axis_init = {joystick:getAxes()},
				
				num_axes = joystick:getAxisCount(),
				num_buttons = joystick:getButtonCount(),
				num_hats = joystick:getHatCount(),
				
				guid = joystick:getGUID(),
				name = joystick:getName(),
				id = {joystick:getID()},
				
				can_vibrate = joystick:isVibrationSupported(),
				is_gamepad = joystick:isGamepad(),
			}
		end
	end
	
	self.promptTimer = 0
	self.isPrompting = false
	
	self.controlTable = inputtable or {} --the table of controls to monitor
	
	-- condense any non-table items into tables
	for k,v in pairs(self.controlTable) do
		if not v[1] then
			self.controlTable[k] = {v}
		end
	end
	
	self.controls = {}	--this is for checking the exact value of a control
	self.tapped = {}	--like above, but only active for a frame after being pressed
	self.released = {}	--like above, but only active for a frame after being released
end

-- add a control if it didn't already exist
function neubind:addControl(controlname, controlsets)
	if not self.controlTable[controlname] then
		if not controlsets[1] then
			self.controlTable[controlname] = {controlsets}
		else
			self.controlTable[controlname] = controlsets
		end
		return true
	else
		return false
	end
end

-- emulate a keypress, mostly for netplay foolery
function neubind:remotePressed(control)
	
end

function neubind:remoteReleased(control)
	
end

function neubind:update(dt)
	--print("neu update")
	-- iterate through controls and think
	
	--improvement ideas: snapshot every control state at the beginning and then backreference them
	
	for control, sets in pairs(self.controlTable) do
		local active = false
		
		for i,stub in pairs(sets) do
			if stub.itype == "key" and love.keyboard then
				active = self:check_key(stub.const)
			else
				assert(false, "CRITICAL: Tried to process input of unknown type: "..stub.itype.."!")
			end
			
			if not active then
				-- not active, cry
				break
			end
		end
		
		self.controls[control] = active
		
		if active then
			self.released[control] = false
			if self.tapped[control]==false then 
				self.tapped[control]=true
				if self.controlPressed then
					self:controlPressed(control)
				end
			elseif self.tapped[control]==true then
				self.tapped[control]=nil
			end
		else
			self.tapped[control] = false
			if self.released[control]==false then
				self.released[control]=true 
				if self.controlReleased then
					self:controlReleased(control)
				end
			elseif self.released[control]==true then
				self.released[control]=nil
			end
		end
	end
end

function neubind:check_key(const)
	return love.keyboard.isDown(const)
end


-- callback stub
function neubind:controlPressed(control)
	print("im pressed and gay", control)
end

-- callback stub
function neubind:controlReleased(control)
	print("im released and gay", control)
end

-- tell the system to catch the next signal
function neubind:promptStart(duration)
	self.promptTimer = duration or -1
	self.isPrompting = true
end

-- tell the system to stop trying to catch signals
function neubind:promptStop()
	self.promptTimer = 0
	self.isPrompting = false
end

-- callback to send a signal when something is captured via prompt
function neubind:promptCallback(controlname, controlid)
	--@controlname == string that describes a control
	--@controlid == the id of the control
end