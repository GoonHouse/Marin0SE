local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	
end

local info = debug.getinfo(1,'S')
print(info.source)