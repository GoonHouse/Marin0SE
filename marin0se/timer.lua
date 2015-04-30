--[[
	Modeled after garry's mod's timer implementation.
	
	http://wiki.garrysmod.com/page/Category:timer
]]

timer = {
	namedTimers = {},
	--[[
		active,
		delay,
		delayTimer, --dt gets added to it until it is delay
		repetitions,
		repetitionsDone, --gets added to each cycle, 
		func,
	]]
	simpleTimers = {},
	--[[
		delay,
		delayTimer, --dt gets added to it until it is delay
		func,
	]]
}
--timer.namedTimers[identifier]
-- repetitions=0 for infinity
function timer.Adjust(identifier, delay, repetitions, func)
	if timer.namedTimers[identifier] then
		timer.namedTimers[identifier].delay = delay
		-- check for lower?
		timer.namedTimers[identifier].repetitions = repetitions
		-- check for lower?
		timer.namedTimers[identifier].func = func
		return true
	else
		return false
	end
end
timer.Check = timer.Update
function timer.Update(dt)
	for k,v in pairs(timer.namedTimers) do
		if v.active then
			v.delayTimer = v.delayTimer + dt
			if v.delayTimer >= v.delay then
				v.func()
				v.repetitionsDone = v.repetitionsDone + 1
				if v.repetitions ~= 0 and v.repetitionsDone >= v.repetitions then
					timer.namedTimers[k] = nil
				else
					v.delayTimer = 0
				end
			end
		end
	end
	for k,v in pairs(timer.simpleTimers) do
		v.delayTimer = v.delayTimer + dt
		if v.delayTimer >= v.delay then
			v.func()
			timer.simpleTimers[k]=nil
		end
	end
end --[[internal: go through all functions and do whatever is done]]
function timer.Create(identifier, delay, repetitions, func)
	if delay <= 0 then return false end
	timer.namedTimers[identifier] = {
		active = false,
		delay = delay,
		delayTimer = delay,
		repetitions = repetitions or 0,
		repetitionsDone = repetitions or 0,
		func = func
	}
end 
function timer.Destroy(identifier) 
	timer.namedTimers[identifier] = nil
end
function timer.Exists(identifier)
	return timer.namedTimers[identifier]~=nil
end
function timer.Pause(identifier)
	if timer.namedTimers[identifier] and timer.namedTimers[identifier].active then
		timer.namedTimers[identifier].active = false
		return true
	else
		return false
	end
end
timer.Remove = timer.Destroy
function timer.RepsLeft(identifier) 
	if timer.namedTimers[identifier] then
		return timer.namedTimers[identifier].repetitionsLeft
	end
end
function timer.Simple(delay, func)
	table.insert(timer.simpleTimers, {delay=delay,delayTimer=0,func=func})
end
function timer.Start(identifier) 
	if timer.namedTimers[identifier] then
		timer.namedTimers[identifier].active = true
		timer.namedTimers[identifier].delayTimer = 0
		timer.namedTimers[identifier].repetitionsDone = 0
		return true
	else
		return false
	end
end
function timer.Stop(identifier)
	if timer.namedTimers[identifier] and timer.namedTimers[identifier].active then
		timer.namedTimers[identifier].active = false
		timer.namedTimers[identifier].delayTimer = 0
		timer.namedTimers[identifier].repetitionsDone = 0
		return true
	else
		return false
	end
end
function timer.TimeLeft(identifier)
	if timer.namedTimers[identifier] then
		return timer.namedTimers[identifier].delay-timer.namedTimers[identifier].delayTimer
	else
		return 0
	end
end
function timer.Toggle(identifier)
	if timer.namedTimers[identifier] then
		if timer.namedTimers[identifier].active then
			timer.Pause(identifier)
		else
			timer.UnPause(identifier)
		end
		return timer.namedTimers[identifier].active
	end
end
function timer.UnPause(identifier)
	if timer.namedTimers[identifier] and not timer.namedTimers[identifier].active then
		timer.namedTimers[identifier].active = true
		return true
	else
		return false
	end
end