local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.frametime = 0.8
thisclass.static.scrollheight = 2.5

--[[
thisclass.static.GRAPHIC_QUADCENTER = {8,4,0}
thisclass.static.GRAPHIC_OFFSET = {8,4,0}
thisclass.static.GRAPHIC_SIGS = {
	popupfont = {16,8}
}
]]

thisclass:include(Base)
--thisclass:include(HasGraphics)

function thisclass:init(x, y, text, stype)
	baseentity.init(self, thisclass, classname, x, y+.5, 0, nil)
	--baseentity.init(self, thisclass, classname, x-.5, y-.5, 0, nil, parent)
	self.text = text
	self.stype = stype or "score" --score, life, time, coin
	
	--[[ reference this if things go weird
		self.width, self.height = 16, 8
		self.offsetX, self.offsetY = self.width/2, self.height/2
		self.quadcenterX, self.quadcenterY = self.width/2, self.height/2
		self.width, self.height = 16/16, 8/16
	]]
	--[[ not used because HasGraphics currently disabled
		self.graphicid = "popupfont"
		self.graphic = globalimages[self.graphicid].img or missinggraphicimg
		-- the comment below about self.quad also applies here
		self.quadi = 1
		self.quad = globalimages[self.graphicid].quads[self.quadi]
	]]
	--self.timermax = thisclass.frametime
	--self.timer = 0
	
	--self.maxy = self.y-thisclass.scrollheight
	
	self.drawable = false
	
	timer.Simple(thisclass.frametime, 
		function()
			self:remove()
		end
	)
	
	--table.insert(objects[classname], self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	self.y = self.y - (thisclass.scrollheight/thisclass.frametime)*dt
	--math.floor((self.y-1.5-2.8*(dt/0.8))*16*scale)
	--math.floor((self.y-1.5-thisclass.scrollheight*(self.timer/thisclass.frametime))*16*scale)
	
	--[[if self.y < self.maxy or self.destroy then
		return true
	end]]
	
	return self.destroy
end

function thisclass:draw()
	--properprintbackground(self.s, self.x*16*scale, (self.y-.5-self.timer)*16*scale, true, nil, scale)
	properprint2(self.text, math.floor((self.x-0.4-xscroll)*16*scale), math.floor((self.y-1.5-yscroll)*16*scale))
	if self.stype == "life" then
		--love.graphics.draw(popupfontimage, popupfontquads[1], math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
	elseif self.stype == "time" then
		--love.graphics.draw(popupfontimage, popupfontquads[6], math.floor((scrollingscores[i].x)*16*scale)-32, math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
		--properprint2(self.text, math.floor((self.x-0.4)*16*scale)+8, math.floor((self.y-1.5-thisclass.scrollheight*(self.timer/thisclass.frametime))*16*scale))
	elseif self.stype == "coin" then
		--I dunno, man
	end
end