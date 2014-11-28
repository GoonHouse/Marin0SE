function saveconfig()
	local sets = {}
	
	for k,v in pairs(default_settings) do
		if _G[k] ~= nil then
			sets[k] = _G[k]
		else
			print("WARNING: Setting value `"..tostring(k).."` was not found in global scope for saving.")
			sets[k] = v
		end
	end
	
	love.filesystem.write("options.json", JSON:encode_pretty(sets))
end

function loadconfig()
	for k,v in pairs(default_settings) do
		_G[k] = v
	end
	
	if not love.filesystem.exists("options.json") then
		return
	end
	
	local sets = JSON:decode(love.filesystem.read("options.json"))
	
	for k,v in pairs(sets) do
		_G[k] = v
	end
end

