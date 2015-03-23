CanBeControlled = {
	binds = nil,
	controls = nil,
	
	controlLookups = {}, --table of actions to perform on signal, keyed by names, values are arrays of functions to run on self
}

function CanBeControlled:setControlLookup(controlTable)
	self.controlLookups = controlTable
end

function CanBeControlled:setControlLookupFromStatic(staticControlTable)
	local controlTable = {}
	for controlName, controlFunction in pairs(staticControlTable) do
		if not controlTable[controlName] then
			controlTable[controlName] = {}
		end
		table.insert(controlTable[controlName], self[controlFunction])
	end
	self:setControls(controlTable)
end

function CanBeControlled:registerControl(controlName, controlFunction, ...)
	table.insert(self.controlLookups[controlName], controlFunction)
end

function CanBeControlled:controlPressed(control)
	for _, controlFunction in pairs(self.controlLookups[control]) do
		controlFunction(self)
	end
end

function CanBeControlled:controlReleased(control)
	for _, controlFunction in pairs(self.controlLookups[control]) do
		controlFunction(self)
	end
end

function CanBeControlled:setControls(controlsTable)
	self.binds, self.controls = TLbind.giveInstance(controlsTable)
	self.binds.controlPressed = function(control)
		self:controlPressed(control)
	end
	self.binds.controlReleased = function(control)
		self:controlReleased(control)
	end
end

-- use the following to re-implement network polls
--[[
if onlinemp and not fromnetwork then
	client_send("controlupdate", {control=control,direction="press"})
end
if fromnetwork then
	print("network-pressed: "..control)
	self.controls[control]=true
	self.controls.tap[control]=true
	self.controls.release[control]=true
end
]]