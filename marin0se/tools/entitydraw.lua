local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	
end

function thisclass:update(dt)
	-- we can always show our status, probably
	local x, y = getMousePos()
	local tilex,tiley = getMouseTile(x, y-8*scale)
	self.status="("..tilex..","..tiley..")"
	
	if editortool.update(self,dt) then
		-- begin of tap
		lightdrawX, lightdrawY = getMouseTile(x, y+8*scale)
		lightdrawtable = {{x=lightdrawX, y=lightdrawY}}
		-- paint
		paintLight()
	end
end

function thisclass:draw()
	editortool.draw(self)
end