--[[ strange language sorcery takes place here ]]
function table.pack(...)
	return { n = select("#", ...), ... }
end

-- for when # isn't good
function table.length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
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

-- alias
table.copy = table.combine

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

function string:countlines()
	return select(2, self:gsub('\n', '\n'))+1
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

-- shave the remainder and see how many times 'a' can fit 'b' inside it
function math.fits(a, b)
	return (a - (a % b))/b
end

function math.scale(value, omin, omax, nmin, nmax)
	value = value or 0
	omin = omin or 0
	omax = omax or 1
	nmin = nmin or 0
	nmax = nmax or 1
	return (
		(
			(nmax-nmin)*(value-omin)
		)/(omax-omin)
	)+nmin
end

-- this came from the evolve gmod plugin framework because I liked it.
function formatTime( t )
	if ( t < 0 ) then
		return "Forever"
	elseif ( t < 60 ) then
		if ( t == 1 ) then return "one second" else return t .. " seconds" end
	elseif ( t < 3600 ) then
		if ( math.ceil( t / 60 ) == 1 ) then return "one minute" else return math.ceil( t / 60 ) .. " minutes" end
	elseif ( t < 24 * 3600 ) then
		if ( math.ceil( t / 3600 ) == 1 ) then return "one hour" else return math.ceil( t / 3600 ) .. " hours" end
	elseif ( t < 24 * 3600 * 7 ) then
		if ( math.ceil( t / ( 24 * 3600 ) ) == 1 ) then return "one day" else return math.ceil( t / ( 24 * 3600 ) ) .. " days" end
	elseif ( t < 24 * 3600 * 30 ) then
		if ( math.ceil( t / ( 24 * 3600 * 7 ) ) == 1 ) then return "one week" else return math.ceil( t / ( 24 * 3600 * 7 ) ) .. " weeks" end
	else
		if ( math.ceil( t / ( 24 * 3600 * 30 ) ) == 1 ) then return "one month" else return math.ceil( t / ( 24 * 3600 * 30 ) )	.. " months" end
	end
end