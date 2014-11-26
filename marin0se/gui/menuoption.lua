menuoption = class("menuoption")

function menuoption:init(otype, label, func)
	self.active = false
	self.selected = false
	
	self.otype = otype
	self.label = label or "???"
	self.func = func or nop
	self.x = 0
	self.y = 0
	
	if self.otype == "text" then
		self.label = 
	elseif self.otype == "slider" then
		
	end
end

menuprompt = class("menuprompt")

function examplebuild()
	pausemenu = menuprompt:new()
	local tempopt = menuoption:new(
	pausemenu:append("text", "resume", 
	pausemenuoptions = {"resume", "suspend", "volume", "quit to", "quit to"}
	pausemenuoptions2 = {"", "", "", "menu", "desktop"}
end

function menuprompt:init()
	self.active = false
	self.options = {} --sub-elements, indexed by number
	self.index = 0 --the current position the cursor is at
	self.startindex = 0 --the position the cursor starts at
	self.layout = "ver" --"ver" or "hor"
	self.blur = false
	
	-- positioning
	self.width = 100
	self.height = 150
	-- position it in the center, offset it by its size
	self.x = (width*scale*8)-self.width*.5*scale
	self.y = (height*scale*8)-self.height*.5*scale
	
	--drawrectangle(width*8-49, 112-74, 98, 148)
end

function menuprompt:append(theoption) --you should only feed me menuoptions
	if otype == "text" then
		table.insert(self.options, 
			
	elseif otype == "slider" then
		table.insert(self.options, 
end

function menuprompt:()
	
end

function menuprompt:update(dt)
	
end

function menuprompt:draw()
	if self.blur then
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
	end
	
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255)
	drawrectangle(width*8-49, 112-74, 98, 148)
	
	for i = 1, #pausemenuoptions do
		love.graphics.setColor(100, 100, 100, 255)
		if pausemenuselected == i and not menuprompt and not desktopprompt then
			love.graphics.setColor(255, 255, 255, 255)
			properprint(">", (width*8*scale)-45*scale, (112*scale)-60*scale+(i-1)*25*scale)
		end
		properprint(pausemenuoptions[i], (width*8*scale)-35*scale, (112*scale)-60*scale+(i-1)*25*scale)
		properprint(pausemenuoptions2[i], (width*8*scale)-35*scale, (112*scale)-50*scale+(i-1)*25*scale)
		
		if pausemenuoptions[i] == "volume" then
			drawrectangle((width*8)-34, 68+(i-1)*25, 74, 1)
			drawrectangle((width*8)-34, 65+(i-1)*25, 1, 7)
			drawrectangle((width*8)+40, 65+(i-1)*25, 1, 7)
			love.graphics.draw(volumesliderimg, math.floor(((width*8)-35+74*volume)*scale), (112*scale)-47*scale+(i-1)*25*scale, 0, scale, scale)
		end
	end
	
	
	if menuprompt then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
		love.graphics.setColor(255, 255, 255, 255)
		drawrectangle((width*8)-99, 112-24, 198, 48)
		properprint("quit to menu?", (width*8*scale)-string.len("quit to menu?")*4*scale, (112*scale)-10*scale)
		if pausemenuselected2 == 1 then
			properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale) 
		else
			properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		end
	end
	
	if desktopprompt then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
		love.graphics.setColor(255, 255, 255, 255)
		drawrectangle((width*8)-99, 112-24, 198, 48)
		properprint("quit to desktop?", (width*8*scale)-string.len("quit to desktop?")*4*scale, (112*scale)-10*scale)
		if pausemenuselected2 == 1 then
			properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		else
			properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		end
	end
	
	if suspendprompt then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
		love.graphics.setColor(255, 255, 255, 255)
		drawrectangle((width*8)-99, 112-24, 198, 48)
		properprint("suspend game? this can", (width*8*scale)-string.len("suspend game? this can")*4*scale, (112*scale)-20*scale)
		properprint("only be loaded once!", (width*8*scale)-string.len("only be loaded once!")*4*scale, (112*scale)-10*scale)
		if pausemenuselected2 == 1 then
			properprint(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		else
			properprint(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
			love.graphics.setColor(100, 100, 100, 255)
			properprint("yes", (width*8*scale)-44*scale, (112*scale)+4*scale)
			love.graphics.setColor(255, 255, 255, 255)
			properprint("no", (width*8*scale)+28*scale, (112*scale)+4*scale)
		end
	end
end

function menuprompt:mousepressed(x, y, button)
	
end

function menuprompt:mousereleased(x, y, button)
	
end