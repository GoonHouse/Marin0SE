local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	
end

function thisclass:update(dt)
	editortool.update(self,dt)
	local x,y = getMouseTile(mouse.getX(), mouse.getY()-8*scale)
	self.status="("..x..","..y..")"
end

function thisclass:draw()
	editortool.draw(self)
end