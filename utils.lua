--[[ strange language sorcery takes place here ]]
function table.pack(...)
	return { n = select("#", ...), ... }
end