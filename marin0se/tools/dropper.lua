local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, editortool)
local thisclass = _G[classname]

function thisclass:init()
	editortool.init(self, classname)
	
end

function thisclass:canFire()
	local value = controls.tap.editorDropper and self.active and not editormenuopen and not testlevel
	print("dropper canfire", value)
	return value
end

function thisclass:update(dt)
	-- we can always show our status, probably
	local x, y = getMousePos()
	local tilex,tiley = getMouseTile(x, y+(8*scale))
	self.status="("..tilex..","..tiley..")"
	
	if self:canFire() then
		if inmap(tilex, tiley) then
			editentities = false
			editenemies = false
			switch_tileset("all")
			currenttile = map[tilex][tiley][1]
			changeTool("paintdraw", currenttile)
		end
	end
end

function thisclass:draw()
	editortool.draw(self)
end