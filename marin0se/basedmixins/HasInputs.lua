-- OtherClass:include(HasInputs) gives it all elements of that table
HasInputs = {
	inputTable = {},
}

function HasInputs:link()
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
end

function HasInputs:input(signaltype, inputindex)
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
end