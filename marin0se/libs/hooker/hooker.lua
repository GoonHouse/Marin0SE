--[[
	EntranceJew made this.
	https://github.com/EntranceJew/hooker
]]

hooker = {
	hookTable = {},
	hookIter = pairs
	-- override this if you want globally deterministic hook iteration
}
-- this is where we store our hooks and the things that latch on to them like greedy little hellions

function hooker.Add( eventName, identifier, func )
	--string, any, function
	if hooker.hookTable[eventName]==nil then
		hooker.hookTable[eventName] = {}
	end
	hooker.hookTable[eventName][identifier] = func
end

function hooker.Call( eventName, ... )
	--string, varargs
	if hooker.hookTable[eventName]==nil then
		-- skip processing the hook because nobody's listening
		return nil
	else
		local results
		for identifier,func in hooker.hookIter(hooker.hookTable[eventName]) do
			results = table.pack(func(...))
			results.n = nil
			if #results>0 then
				-- potential problems if relying on sandwiching a nil in the return results
				return unpack(results)
			end
		end
	end
end

function hooker.GetTable()
	return hooker.hookTable()
end

function hooker.Remove( eventName, identifier )
	--[[string, string]]
	if hooker.hookTable[eventName]==nil or hooker.hookTable[eventName][identifier]==nil then
		return false
	else
		hooker.hookTable[eventName][identifier] = nil
	end
	-- see if the table is empty and nil it for the benefit of hook.Call's optimization
	for k,v in pairs(hooker.hookTable[eventName]) do
		-- we found something, exit the function
		return true
	end
	-- if we reach this far then the table must've been empty
	hooker.hookTable[eventName] = nil
	return true
end