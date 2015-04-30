-- credits to [Robin](http://love2d.org/forums/viewtopic.php?p=69006&sid=d263c1c1d69a5ffe6fd6259bb7d4ae9c#p69006)
function love.graphics.roundrect(mode, x, y, width, height, xround, yround)
	local points = {}
	local precision = (xround + yround) * .1
	local tI, hP = table.insert, .5*math.pi
	if xround > width*.5 then xround = width*.5 end
	if yround > height*.5 then yround = height*.5 end
	local X1, Y1, X2, Y2 = x + xround, y + yround, x + width - xround, y + height - yround
	local sin, cos = math.sin, math.cos
	for i = 0, precision do
		local a = (i/precision-1)*hP
		tI(points, X2 + xround*cos(a))
		tI(points, Y1 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision)*hP
		tI(points, X2 + xround*cos(a))
		tI(points, Y2 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision+1)*hP
		tI(points, X1 + xround*cos(a))
		tI(points, Y2 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision+2)*hP
		tI(points, X1 + xround*cos(a))
		tI(points, Y1 + yround*sin(a))
	end
	love.graphics.polygon(mode, unpack(points))
end

-- overloads for safe fallbacks with resources
love.audio.oldSource = love.audio.newSource
love.audio.newSource = function(snd, stype)
	local finalpath = snd
	stype = stype or "static"
	if type(snd)=="string" and not love.filesystem.exists(snd) then
		local depth = 0
		for k,v in pairs(soundsearchdirs) do
			local p = v % {mappack=mappack,file=snd,soundpack=soundpack}
			if love.filesystem.exists(p) then
				depth = k
				finalpath = p
				break
			end
		end
		if depth == #soundsearchdirs then
			print("ALERT: Engine couldn't find sound '"..snd.."' anywhere!")
		elseif depth == #soundsearchdirs-1 then
			print("WARNING: Engine couldn't find sound '"..snd.."', used fallback.")
		elseif depth == 0 then
			assert(false, "CALL THE COPS: The fallback missingsound file is GONE.")
		end
		snd = finalpath
	end
	return love.audio.oldSource(snd, stype)
end

love.sound.oldSoundData = love.sound.newSoundData
love.sound.newSoundData = function(snd, x, y, z)
	local finalpath = snd
	if type(snd)=="string" and not love.filesystem.exists(snd) then
		local depth = 0
		for k,v in pairs(soundsearchdirs) do
			local p = v % {mappack=mappack,file=snd,soundpack=soundpack}
			if love.filesystem.exists(p) then
				depth = k
				finalpath = p
				break
			end
		end
		if depth == #soundsearchdirs then
			print("ALERT: Engine couldn't find sounddata '"..snd.."' anywhere!")
		elseif depth == #soundsearchdirs-1 then
			print("WARNING: Engine couldn't find sounddata '"..snd.."', used fallback.")
		elseif depth == 0 then
			assert(false, "CALL THE COPS: The fallback missingsound(data) file is GONE.")
		end
		snd = finalpath
	end
	return love.sound.oldSoundData(snd, x, y, z)
end

love.graphics.oldImage = love.graphics.newImage
love.graphics.newImage = function(img, ex)
	local finalpath = img
	if type(img)=="string" and not love.filesystem.exists(img) then
		local depth = 0
		for k,v in pairs(graphicssearchdirs) do
			local p = v % {mappack=mappack,file=img,graphicspack=graphicspack}
			if love.filesystem.exists(p) then
				depth = k
				finalpath = p
				break
			end
		end
		if depth == #graphicssearchdirs then
			print("ALERT: Engine couldn't find graphic '"..img.."' anywhere!")
		elseif depth == #graphicssearchdirs-1 then
			print("WARNING: Engine couldn't find graphic '"..img.."', used fallback.")
		elseif depth == 0 then
			assert(false, "CALL THE COPS: The fallback missinggraphic image is GONE.")
		end
		img = finalpath
	end
	return love.graphics.oldImage(img, ex)
end

love.image.oldImageData = love.image.newImageData
love.image.newImageData = function(img, ex)
	local finalpath = img
	if type(img)=="string" and not love.filesystem.exists(img) then
		local depth = 0
		for k,v in pairs(graphicssearchdirs) do
			local p = v % {mappack=mappack,file=img,graphicspack=graphicspack}
			if love.filesystem.exists(p) then
				depth = k
				finalpath = p
				break
			end
		end
		if depth == #graphicssearchdirs then
			print("ALERT: Engine couldn't find graphic '"..img.."' anywhere!")
		elseif depth == #graphicssearchdirs-1 then
			print("WARNING: Engine couldn't find graphic '"..img.."', used fallback.")
		elseif depth == 0 then
			assert(false, "CALL THE COPS: The fallback missinggraphic image is GONE.")
		end
		img = finalpath
	end
	return love.image.oldImageData(img, ex)
end