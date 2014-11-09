local classname=debug.getinfo(1,'S').source:split("/")[2]:sub(0,-5)
_G[classname] = class(classname, baseentity)
local thisclass = _G[classname]

-- custom stuff
thisclass.static.frametime = 0.8
thisclass.static.scrollheight = 2.5
thisclass.static.possible = {
	["1up"] = {16, 8, 0, 0},
	["2up"] = {16, 8, 16, 0},
	["3up"] = {16, 8, 32, 0},
	["5up"] = {16, 8, 48, 0},
	["coin"] = {7, 8, 65, 0}, 
	["plus"] = {4, 8, 74, 0},
	["clock"] = {8, 8, 80, 0},
}

-- engine stuff
thisclass.static.image_sigs = {
	popupfont = {16,8}
}

function thisclass:init(x, y, text, stype)
	--baseentity.init(self, thisclass, classname, x-.5, y-.5, 0, nil, parent)
	self.x = x-xscroll
	self.y = y-yscroll
	self.text = text
	self.stype = stype or "score" --score, life, time, coin
	
	self.static = true
	self.mask = {true, false}
	self.category = 1
	self.width, self.height = 16, 8
	self.offsetX, self.offsetY = self.width/2, self.height/2
	self.quadcenterX, self.quadcenterY = self.width/2, self.height/2
	self.width, self.height = 16/16, 8/16
	self.graphicid = "popupfont"
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	-- the comment below about self.quad also applies here
	self.quadi = 1
	self.quad = globalimages[self.graphicid].quads[self.quadi]
	self.drawable = false
	self.active = true
	self.timermax = thisclass.frametime
	self.timer = 0
	
	table.insert(objects[classname], self)
end

function thisclass:update(dt)
	baseentity.update(self, dt)
	
	self.y = self.y - (thisclass.scrollheight/thisclass.frametime)*dt
	--math.floor((self.y-1.5-2.8*(dt/0.8))*16*scale)
	--math.floor((self.y-1.5-thisclass.scrollheight*(self.timer/thisclass.frametime))*16*scale)
	
	return self.destroy
end

function thisclass:timercallback()
	self.destroy = true
end

function thisclass:draw()
	--properprintbackground(self.s, self.x*16*scale, (self.y-.5-self.timer)*16*scale, true, nil, scale)
	properprint2(self.text, math.floor((self.x-0.4)*16*scale), math.floor((self.y-1.5)*16*scale))
	if self.stype == "life" then
		--love.graphics.draw(popupfontimage, popupfontquads[1], math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
	elseif self.stype == "time" then
		--love.graphics.draw(popupfontimage, popupfontquads[6], math.floor((scrollingscores[i].x)*16*scale)-32, math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
		--properprint2(self.text, math.floor((self.x-0.4)*16*scale)+8, math.floor((self.y-1.5-thisclass.scrollheight*(self.timer/thisclass.frametime))*16*scale))
	elseif self.stype == "coin" then
		--I dunno, man
	end
end