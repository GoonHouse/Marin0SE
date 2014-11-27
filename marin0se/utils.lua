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

function table.find(t, k)
	for _,v in pairs(t) do
		if v == k then
			return _
		end
	end
	return nil
end

function table.print(t)
	print("~=table.print(", t, ")")
	--print(Tserial.pack(t, true, true))
	-- the above causes a stack overflow, so we are doing this the dumb way
	if t~=nil then
		for k,v in pairs(t) do print(k, "=", v) end
	else
		print("nothing, got a nil")
	end
	print("=~table.print(", t, ")")
end

-- this code was originally from TLbind, also works to clone
function table.combine(a, b)
	local t = {}
	for k, v in pairs(a) do if type(v)=="table" then t[k]=table.combine(v) else t[k]=v end end
	if b then for k, v in pairs(b) do if type(v)=="table" then t[k]=table.combine(v) else t[k]=v end end end
	return t
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

function table.fdelete(tbl, filterfunc, ex)
	--[[
		delete elements in a table where the filterfunc returns true
		
		filterfunc is supplied the index and the object, plus whatever is in ex
	]]
	local delete = {}
	
	for i, v in pairs(tbl) do
		if filterfunc(i, v, ex) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end) -- why are we doing this
	
	for i, v in pairs(delete) do
		table.remove(tbl, v) --remove
	end
end