function add(desc)
	print((desc or "") .. "\n" .. round((love.timer.getTime()-lasttime)*1000) .. "ms\tlines " .. lastline+1 .. " - " .. debug.getinfo(2).currentline-1 .. "\n")
	lastline = debug.getinfo(2).currentline
	lasttime = love.timer.getTime()
end

function screenshotUploadWrap(iname, idata)
	local t=upload_imagedata(iname, idata)
	if t.success then
		print("Your image was uploaded to: "..t.data.link)
		love.system.setClipboardText(t.data.link)
		notice.new("screenshot uploaded")
		--love.filesystem.write("screenshot_url.txt", t.data.link)
		--openImage(t.data.link)
	else
		print("Your image upload failed, please upload '"..outname.."' manually.")
		notice.new("upload failed, try manually")
		openSaveFolder()
	end
end

function logoPresent()
	love.graphics.clear()
	love.graphics.setColor(100, 100, 100)
	loadingtext = loadingtexts[math.random(1,#loadingtexts)]
	
	local logoscale = scale
	if logoscale <= 1 then
		logoscale = 0.5
	else
		logoscale = 1
	end
	
	love.graphics.setColor(255, 255, 255)
	
	love.graphics.draw(logo, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, logoscale, logoscale, 142, 150)
	love.graphics.setColor(150, 150, 150)
	properprint(loading_header, love.graphics.getWidth()/2-string.len(loading_header)*4*scale, love.graphics.getHeight()/2-170*logoscale-7*scale)
	love.graphics.setColor(50, 50, 50)
	properprint(loadingtext, love.graphics.getWidth()/2-string.len(loadingtext)*4*scale, love.graphics.getHeight()/2+165*logoscale)
	love.graphics.present()
end

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function changescale(s, init)
	scale = s
	
	if not init then
		if width*16*scale > desktopsize.width then
			if fullscreen and fullscreenmode == "full" then
				scale = scale - 1
				return
			end
			
			if fullscreen and fullscreenmode == "touchfrominside" then
				fullscreenmode = "full"
				scale = scale - 1
				return
			end
			
			if love.graphics.isSupported("canvas") then
				fullscreen = true
			end
			
			scale = scale - 1
			fullscreenmode = "touchfrominside"
			
		elseif fullscreen then
			if fullscreenmode == "full" then
				fullscreenmode = "touchfrominside"
				scale = scale + 1
				return
			else
				fullscreen = false
			end
			scale = scale + 1
			fullscreenmode = "full"
			
		end
	end
	
	if fullscreen then
		love.window.setMode(desktopsize.width, desktopsize.height, {fullscreen=fullscreen, vsync=vsync, fsaa=fsaa})
	else
		uispace = math.floor(width*16*scale/4)
		love.window.setMode(width*16*scale, height*16*scale, {fullscreen=fullscreen, vsync=vsync, fsaa=fsaa}) --25x14 blocks (15 blocks actual height)
	end
	
	if love.graphics.isSupported("canvas") then
		completecanvas = love.graphics.newCanvas()
		completecanvas:setFilter("linear", "linear")
	end
	
	gamewidth = love.window.getWidth()
	gameheight = love.window.getHeight()
	
	if shaders then
		shaders:refresh()
	end
	
	if generatespritebatch then
		generatespritebatch()
	end
end

function properprintbackground(s, ox, oy, include, dcolor, sc)
	--[[if type(s)~="string" then
		print("WARNING: Tried to properprint a non-string.")
		return
	end]]
	local scale = sc or scale
	local x = ox
	local y = oy
	local startx = x
	local dcolor = dcolor or {255,255,255}
	local skip = 0
	local precolor = {love.graphics.getColor()}
	love.graphics.setColor(unpack(dcolor))
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if char == "|" then
				x = startx-((i)*8)*scale
				y = y + 10*scale
			elseif fontquadsback[char] then
				love.graphics.draw(fontimageback, fontquadsback[char], x+((i-1)*8)*scale, y-1*scale, 0, scale, scale)
			end
		end
	end
	love.graphics.setColor(unpack(precolor))
	if include ~= false then
		properprint(s, ox, oy, scale)
	end
end
function properprint(s, x, y, sc)
	local scale = sc or scale
	local startx = x
	local skip = 0
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if string.sub(s, i, i+3) == "_dir" and tonumber(string.sub(s, i+4, i+4)) then
				love.graphics.draw(directionsimg, directionsquad[tonumber(string.sub(s, i+4, i+4))], x+((i-1)*8+1)*scale, y, 0, scale, scale)
				skip = 4
			elseif char == "|" then
				x = startx-((i)*8)*scale
				y = y + 10*scale
			elseif fontquads[char] then
				love.graphics.draw(fontimage, fontquads[char], x+((i-1)*8)*scale, y, 0, scale, scale)
			end
		end
	end
end
function getaveragecolor(imgdata, cox, coy)	
	local xstart = (cox-1)*17
	local ystart = (coy-1)*17
	
	local r, g, b = 0, 0, 0
	
	local count = 0
	
	for x = xstart, xstart+15 do
		for y = ystart, ystart+15 do
			local pr, pg, pb, a = imgdata:getPixel(x, y)
			if a > 127 then
				r, g, b = r+pr, g+pg, b+pb
				count = count + 1
			end
		end
	end
	
	r, g, b = r/count, g/count, b/count
	
	return r, g, b
end

function openSaveFolder(subfolder) --By Slime
	local path = love.filesystem.getSaveDirectory()
	path = subfolder and path.."/"..subfolder or path
	
	local cmdstr
	local successval = 0
	
	if os.getenv("WINDIR") then -- lolwindows
		--cmdstr = "Explorer /root,%s"
		if path:match("LOVE") then --hardcoded to fix ISO characters in usernames and made sure release mode doesn't mess anything up -saso
			cmdstr = "Explorer %%appdata%%\\LOVE\\Marin0SE"
		else
			cmdstr = "Explorer %%appdata%%\\Marin0SE"
		end
		path = path:gsub("/", "\\")
		successval = 1
	elseif os.getenv("HOME") then
		if path:match("/Library/Application Support") then -- OSX
			cmdstr = "open \"%s\""
		else -- linux?
			cmdstr = "xdg-open \"%s\""
		end
	end
	
	-- returns true if successfully opened folder
	return cmdstr and os.execute(cmdstr:format(path)) == successval
end

function openImage(img)
	local path = love.filesystem.getSaveDirectory()
	
	local cmdstr
	local successval = 0
	
	if os.getenv("WINDIR") then -- windows
		cmdstr = "Explorer \"%s\""
	elseif os.getenv("HOME") then
		if path:match("/Library/Application Support") then -- OSX
			cmdstr = "open \"%s\""
		else -- linux?
			cmdstr = "xdg-open \"%s\""
		end
	end
	
	os.execute(cmdstr:format(img))
	return cmdstr~=nil
end

function getrainbowcolor(i)
	local whiteness = 255
	local r, g, b
	if i < 1/6 then
		r = 1
		g = i*6
		b = 0
	elseif i >= 1/6 and i < 2/6 then
		r = (1/6-(i-1/6))*6
		g = 1
		b = 0
	elseif i >= 2/6 and i < 3/6 then
		r = 0
		g = 1
		b = (i-2/6)*6
	elseif i >= 3/6 and i < 4/6 then
		r = 0
		g = (1/6-(i-3/6))*6
		b = 1
	elseif i >= 4/6 and i < 5/6 then
		r = (i-4/6)*6
		g = 0
		b = 1
	else
		r = 1
		g = 0
		b = (1/6-(i-5/6))*6
	end
	
	return {round(r*whiteness), round(g*whiteness), round(b*whiteness), 255}
end