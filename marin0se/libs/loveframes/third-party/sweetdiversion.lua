--[[--------------------------------
-- "Sweet Diversion"
-- Copyright (c) 2014 Mark "Klowner" Riedesel
--]]--------------------------------

local _version_conditions = {}

local sweetdiversion = function (expr)
	local cache = _version_conditions
	local match = cache[expr]

	if match ~= nil then
		return match
	end

	local curr_version_t = {love._version_major, love._version_minor, love._version_revision}
	local op = string.sub(expr, 0, 1)
	local comparator

	if op == '>' or op == '<' then
		if op == '>' then
			comparator = function (a,b) return a == b and 0 or a > b and 1 or -1 end
		else
			comparator = function (a,b) return a == b and 0 or a < b and 1 or -1 end
		end
	else
		comparator = function (a,b) return ('*' == b or a == b) and 1 or -16 end
	end

	-- split version from expression into numeric parts
	local expr_version_t = {}
	for v, _ in string.gmatch(expr, "([%d*x]+)") do
		table.insert(expr_version_t, tonumber(v) or '*')
	end

	local result = 0
	for i = 1, #expr_version_t do
		result = result + comparator(curr_version_t[i], expr_version_t[i]) * (2^(#expr_version_t-i))
	end

	result = result > 0
	cache[expr] = result
	return result
end

return sweetdiversion
