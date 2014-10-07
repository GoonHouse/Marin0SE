--[[
	We're going to use this to experiment with the concept of hookable events.
	If we play our cards right we won't die!
	
	You make a hook available by using hook.Call("YerHookName", args)
	People can subscribe to this by using hook.Add("YerHookName", "MyIdentifier", functionReference)
	
	This is modeled after the hook library in gmod:
		http://wiki.garrysmod.com/page/hook
	
	We don't do any type checking so if someone goofs the whole thing comes toppling down.
]]

hook = {hookTable={}}
-- this is where we store our hooks and the things that latch on to them like greedy little hellions

function hook.Add( eventName, identifier, func )
	--string, string, function
	if hook.hookTable[eventName]==nil then
		hook.hookTable[eventName]={}
	end
	hook.hookTable[eventName][identifier] = func
end

function hook.Call( eventName, ... )
	--string, varargs
	if hook.hookTable[eventName]==nil then
		-- skip processing the hook because nobody's listening
		return nil
	else
		local results
		for identifier,func in pairs(hook.hookTable[eventName]) do
			local results = table.pack(func({...}))
			results.n = nil
			if #results>0 then
				-- potential problems if relying on sandwiching a nil in the return results
				return results
			end
		end
	end
end

function hook.GetTable()
	return hook.hookTable()
end

function hook.Remove( eventName, identifier )
	--[[string, string]]
	if hook.hookTable[eventName]==nil or hook.hookTable[eventName][identifier]==nil then
		return false
	else
		hook.hookTable[eventName][identifier]=nil
	end
	-- see if the table is empty and nil it for the benefit of hook.Call's optimization
	for k,v in pairs(hook.hookTable[eventName]) do
		-- we found something, exit the function
		return true
	end
	-- if we reach this far then the table must've been empty
	hook.hookTable[eventName] = nil
	return true
end