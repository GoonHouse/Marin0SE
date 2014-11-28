mouse = {}

function mouse.getPosition()
	if fullscreen then
		if fullscreenmode == "full" then
			return love.mouse.getX()/(desktopsize.width/(width*16*scale)), love.mouse.getY()/(desktopsize.height/(height*16*scale))
		else
			return love.mouse.getX()/(touchfrominsidescaling/scale), love.mouse.getY()/(touchfrominsidescaling/scale)-touchfrominsidemissing/2
		end
	else
		return love.mouse.getPosition()
	end
end

function mouse.getX()
	if fullscreen then
		if fullscreenmode == "full" then
			return love.mouse.getX()/(desktopsize.width/(width*16*scale))
		else
			return love.mouse.getX()/(touchfrominsidescaling/scale)
		end
	else
		return love.mouse.getX()
	end
end

function mouse.getY()
	if fullscreen then
		if fullscreenmode == "full" then
			return love.mouse.getY()/(desktopsize.height/(height*16*scale))
		else
			return love.mouse.getY()/(touchfrominsidescaling/scale)-touchfrominsidemissing/2
		end
	else
		return love.mouse.getY()
	end
end

function getMousePos()
	--[[local x, y = love.mouse.getX(), love.mouse.getY()
	if fullscreen then
		if fullscreenmode == "full" then
			x, y = x/(desktopsize.width/(width*16*scale)), y/(desktopsize.height/(height*16*scale))
		else
			x, y = x/(touchfrominsidescaling/scale), y/(touchfrominsidescaling/scale)-touchfrominsidemissing/2
		end
	end]]
	return mouse.getX(), mouse.getY()
end