IsMappable = {}
--[[
	REQUIRES ATTRIBUTES:
	r
	
	EXPECTED STATIC PROPERTIES:
	
]]

--[[Takes inputs similarly to how we save the data through the editor, where signature is:
	{t="optiontype", 
]]
function IsMappable:getBasicInput(vartoset)
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

-- this shouldn't be used on include but I'll leave it dummied for fun
--[[function IsMappable:included(klass)
	-- Go through the input map
	for k,v in pairs(klass.INPUT_MAP) do
		self:getBasicInput(v)
	end
end]]