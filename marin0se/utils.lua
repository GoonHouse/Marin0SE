--[[ strange language sorcery takes place here ]]
function table.pack(...)
	return { n = select("#", ...), ... }
end

function table.contains(t, entry)
	for i, v in pairs(t) do
		if v == entry then
			return true
		end
	end
	return false
end

function table.print(t)
	--print(Tserial.pack(t, true, true))
	-- the above causes a stack overflow, so we are doing this the dumb way
	if t~=nil then
		for k,v in pairs(t) do print(k, "=", v) end
	else
		print("nothing, got a nil")
	end
end

function string:split(delimiter) --Not by me
	local result = {}
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( self, from , delim_from-1 ) )
		from = delim_to + 1
		delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

local function interp(s, tab)
	return (s:gsub('%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
			function(k, fmt) return tab[k] and ("%"..fmt):format(tab[k]) or
				'%('..k..')'..fmt end))
end
getmetatable("").__mod = interp
-- refer to: https://docs.python.org/2/library/stdtypes.html#string-formatting if confused

function nop()
	
end