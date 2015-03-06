local function interp(s, tab)
	return (s:gsub('%%%((%a%w*)%)([-0-9%.]*[cdeEfgGiouxXsq])',
			function(k, fmt) return tab[k] and ("%"..fmt):format(tab[k]) or
				'%('..k..')'..fmt end))
end
getmetatable("").__mod = interp
-- refer to: https://docs.python.org/2/library/stdtypes.html#string-formatting if confused