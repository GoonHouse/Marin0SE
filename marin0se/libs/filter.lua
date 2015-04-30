--[[
	EntranceJew made this.
	
	It's a generic filtering system because iteration is old fashioned.
	
	We sacrifice performance for redundancy removal.
]]

filter = {}

-- if everything is valid, return true
function filter.runAll(iterable, filterFunc, ...)
	for k,v in pairs(iterable) do
		if not filterFunc(v, ...) then 
			return false
		end
	end
	return true
end

-- if anything is valid, return true
function filter.runAny(iterable, filterFunc, ...)
	for k,v in pairs(iterable) do
		if filterFunc(v, ...) then 
			return true
		end
	end
	return false
end

-- multis expect multiple tabularized calls for filter.run*

-- if all the filters return true, so do we
function filter.multiAll(ftype, ...)
	for k,v in pairs({...}) do
		if filter["run"..ftype](unpack(v)) then
			return true
		end
	end
	return false
end

-- if any of the filters return true, so do we
function filter.multiAny(ftype, ...)
	for k,v in pairs({...}) do
		if filter["run"..ftype](unpack(v)) then
			return true
		end
	end
	return false
end