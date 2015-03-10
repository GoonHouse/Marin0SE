hooker
======
A simple lua hooking library that mimics the [gmod hook library](http://wiki.garrysmod.com/page/hook). Expose and call hooks.

This was written for use in love2d games but is general enough to work in any compatible lua environment.

Requirements
------------
- Lua >= 5.1

Usage
-----
You can call a hook anywhere in your code and create an event to hook.
```lua
function computeDistance(a,b)
	hooker.Call("preComputeDistance", a, b)
	--[[
		by putting this hook here, we can subscribe to any calls to computeDistance
		and we can make use of the vars a and b without overwriting the function
	]]
	local distance = math.abs(a - b)
	hooker.Call("midComputeDistance")
	-- we don't have to provide any arguments if we don't need to
	
	local hookresults = hooker.Call("postComputeDistance", distance) or nil
	-- if we want the hook to be able to control program flow, we have to catch its returns
	if hookresults then
		-- if a hook returns anything, we override the regular return with its data
		return hookresults
	else
		return distance
	end
end

-- this will print 6
print(computeDistance(3, 9))
--[[
	here we're going to create a simple listener that just traces all uses of computeDistance
	
	we pass it a reference to the print function that will simply print all arguments it is passed
	the identifier "precomSnooper" doesn't matter, as long as it is unique -- that way we can
	delete it or update it as necessary
]]
hooker.Add("preComputeDistance", "precomSnooper", print)

-- allow our hook to print the arguments for us
print(computeDistance(3, 9))
-- this will print 3, 9 and then 6

-- define a function for our post-hook
function embiggen(n)
	return n*n+1000
end

--[[
	add a hook for postComputeDistance
	
	this will allow us to interrupt the return (because we told it to)
]]
hooker.Add("postComputeDistance", "makeNumbersHuge", embiggen)

-- this should print 3, 9 and then 1036
print(computeDistance(3, 9))

--[[
	add another hook for postComputeDistance, the function can be anonymous
	
	hooks are evaluated in whatever order that pairs() processes them, so
	the order may not always be what you expect unless you override
	hooker.hookIter with a different iteration function
	
	because our hook "makeNumbersHuge" will run first (in this case)
	and it has a return value, other hooks listening to the 
	postComputeDistance hook will not be run
]]
hooker.Add("postComputeDistance", "makeNumbersLessHuge", function(d) return d/2 end)

-- this should print 3, 9 and then 1036
print(computeDistance(3, 9))

-- remove our first hook to investigate the return value of this new hook
hooker.Remove("postComputeDistance", "makeNumbersHuge")

-- test that makeNumbersLessHuge is functioning
-- this should print 3, 9 and then 3
print(computeDistance(3, 9))
```