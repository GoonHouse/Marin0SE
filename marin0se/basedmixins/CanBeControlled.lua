CanBeControlled = {
	binds = nil,
	controls = nil,
	
	controlLookups = {}, --table of actions to perform on signal, keyed by names, values are arrays of functions to run on self
}

function CanBeControlled.inithook(self, t) --t is the named parameters for baseentity's init method
	local k = t.class.static
	self.binder = neubind:new(k.CONTROL_LOOKUP)
	self.binder.controlPressed = function(n, control) self:controlPressed(n, control) end
	self.binder.controlReleased = function(n, control) self:controlReleased(n, control) end
	self:setControlLookupFromStatic(k.CONTROL_LOOKUP_MYSTERY)
end

function CanBeControlled:setControlLookup(controlTable)
	self.controlLookups = controlTable
end

function CanBeControlled:setControlLookupFromStatic(staticControlTable)
	self.controlLookups = {}
	for controlName, controlFunction in pairs(staticControlTable) do
		print(controlName, controlFunction)
		if not self.controlLookups[controlName] then
			self.controlLookups[controlName] = {}
		end
		table.insert(self.controlLookups[controlName], self[controlFunction])
	end
end

function CanBeControlled:registerControl(controlName, controlFunction, ...)
	table.insert(self.controlLookups[controlName], controlFunction)
end

function CanBeControlled:controlPressed(binder, control)
	for _, controlFunction in pairs(self.controlLookups[control]) do
		controlFunction(self, true)
	end
end

function CanBeControlled:controlReleased(binder, control)
	for _, controlFunction in pairs(self.controlLookups[control]) do
		controlFunction(self, false)
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

function CanBeControlled:included(klass)
	registerInitHook(klass, CanBeControlled.inithook)
end