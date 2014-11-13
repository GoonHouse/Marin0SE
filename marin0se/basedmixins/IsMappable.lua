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
		print("CRITICAL: Entity wasn't able to read data from the r table.")
		-- we did not get the data correctly
		return false
	end
end

-- this shouldn't be used on include but I'll leave it dummied for fun
function IsMappable:included(klass)
	-- list entry
	if entitylist then
		entitylist[klass.EDITOR_ENTDEX] = {
			t=klass.name,
			category=klass.EDITOR_CATEGORY,
			description=klass.EDITOR_DESC,
			iconauthor=klass.EDITOR_ICONAUTHOR,
		}
	else
		print("CRITICAL: Mixin IsMappable tried to set entitylist but it didn't exist.")
	end
	
	-- tooltip image
	if tooltipimages then
		local path = "entitytooltips/" .. klass.name .. ".png"
		tooltipimages[klass.EDITOR_ENTDEX] = love.graphics.newImage(path)
	else
		print("CRITICAL: Mixin IsMappable tried to set tooltipimages but it didn't exist.")
	end
	
	-- rightclick menus
	if rightclickmenues then
		rightclickmenues[klass.name] = klass.EDITOR_RCM
	else
		print("CRITICAL: Mixin IsMappable tried to set rightclickmenues but it didn't exist.")
	end
	
	-- entity quads
	if entityquad_overloads then
		entityquad_overloads[klass.EDITOR_ENTDEX] = entity:new(
			globalimages[klass.name].img,
			globalimages[klass.name].quads[1]
		)
		entityquad_overloads[klass.EDITOR_ENTDEX].t = klass.name
	else
		print("CRITICAL: Mixin IsMappable tried to set entityquads but it didn't exist.")
	end
	
	-- consider incremeting this, but not really 
	--entitiescount
end

