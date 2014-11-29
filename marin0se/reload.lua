function reloadFonts()
	fontquads = {}
	for i = 1, string.len(fontglyphs) do
		fontquads[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*8, 0, 8, 8, fontimage:getWidth(), fontimage:getHeight())
	end
	fontquadsback = {}
	for i = 1, string.len(fontglyphs) do
		fontquadsback[string.sub(fontglyphs, i, i)] = love.graphics.newQuad((i-1)*10, 0, 10, 10, fontimageback:getWidth(), fontimageback:getHeight())
	end
end

function reloadQuads()
	font2quads = {}
	for i = 1, 10 do
		font2quads[string.sub(numberglyphs, i, i)] = love.graphics.newQuad((i-1)*4, 0, 4, 8, 40, 8)
	end

	font3quads = {}
	for i = 1, 4 do
		font3quads[string.sub(symbolglyphs, i, i)] = love.graphics.newQuad((i-1)*4, 0, 4, 8, 40, 8)
	end
	
	cursorareaquads = {}
	for i = 1, 4 do
		cursorareaquads[i] = love.graphics.newQuad((i-1)*18, 0, 18, 18, 72, 18)
	end
	
	popupfontquads = {}
	for i = 1, 6 do
		popupfontquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 8, 96, 8)
	end

	fireworkquads = {}
	for i = 1, 4 do
		fireworkquads[i] = love.graphics.newQuad((i-1)*32, 0, 32, 32, 128, 32)
	end
	
	oddjobhudquads = {}
	for i = 1, 5 do
		oddjobhudquads[i] = love.graphics.newQuad((i-1)*8, 0, 8, 8, 40, 8)
	end
	
	coinblockanimationquads = {}
	for i = 1, 30 do
		coinblockanimationquads[i] = love.graphics.newQuad((i-1)*8, 0, 8, 52, 256, 64)
	end
	
	coinanimationquads = {}
	for j = 1, 4 do
		coinanimationquads[j] = {}
		for i = 1, 5 do
			coinanimationquads[j][i] = love.graphics.newQuad((i-1)*5, (j-1)*8, 5, 8, 25, 32)
		end
	end
	
	--coinblock
	coinblockquads = {}
	for j = 1, 4 do
		coinblockquads[j] = {}
		for i = 1, 5 do
			coinblockquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 80, 64)
		end
	end
	
	--coin
	coinquads = {}
	for j = 1, 4 do
		coinquads[j] = {}
		for i = 1, 5 do
			coinquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 80, 64)
		end
	end

	--redcoin
	redcoinquads = {}
	for i = 1, 4 do
		redcoinquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end	
	
	redcointallquads = {}
	for i = 1, 4 do
		redcointallquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 32, 64, 32)
	end	
	
	redcoinbigquads = {}
	for i = 1, 4 do
		redcoinbigquads[i] = love.graphics.newQuad((i-1)*32, 0, 32, 32, 128, 32)
	end	
	
	--smoke puff
	smokepuffquads = {}
	for i = 1, 4 do
		smokepuffquads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end	
	
	--leaf
	leafquad = {}
	for y = 1, 4 do
		leafquad[y] = {}
		for x = 1, 2 do
			leafquad[y][x] = love.graphics.newQuad((x-1)*8, (y-1)*8, 8, 8, 16, 32)
		end
	end
	
	--axe
	axequads = {}
	for i = 1, 5 do
		axequads[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 80, 16)
	end
	
	--spring
	springquads = {}
	for i = 1, 4 do
		springquads[i] = {}
		for j = 1, 3 do
			springquads[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*32, 16, 32, 48, 128)
		end
	end
	
	-- pswitch
	pswitchquads = {}
	for i = 1, 2 do
		pswitchquads[i] = {}
		for j = 1, 4 do
			pswitchquads[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*16, 16, 16, 64, 32)
		end	
	end
	
	seesawquad = {}
	for i = 1, 4 do
		seesawquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	starquad = {}
	for i = 1, 4 do
		starquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	flowerquad = {}
	for i = 1, 4 do
		flowerquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
	
	vinequad = {}
	for i = 1, 4 do
		vinequad[i] = {}
		for j = 1, 2 do
			vinequad[i][j] = love.graphics.newQuad((j-1)*16, (i-1)*16, 16, 16, 32, 64) 
		end
	end
	
	--enemies
	goombaquad = {}
	
	for y = 1, 4 do
		goombaquad[y] = {}
		for x = 1, 2 do
			goombaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 32, 64)
		end
	end
		
	spikeyquad = {}
	for y = 1, 4 do
		spikeyquad[y] = {}
		for x = 1, 4 do
			spikeyquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 64, 64)
		end
	end
	
	lakitoquad = {}
	for y = 1, 4 do
		lakitoquad[y] = {}
		for x = 1, 2 do
			lakitoquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 32, 96)
		end
	end
	
	koopaquad = {}
	
	for y = 1, 4 do
		koopaquad[y] = {}
		for x = 1, 5 do
			koopaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*24, 16, 24, 80, 96)
		end
	end
	
	singlequad = love.graphics.newQuad(0, 0, 16, 16, 16, 16)
	
	cheepcheepquad = {}
	
	cheepcheepquad[1] = {}
	cheepcheepquad[1][1] = love.graphics.newQuad(0, 0, 16, 16, 32, 32)
	cheepcheepquad[1][2] = love.graphics.newQuad(16, 0, 16, 16, 32, 32)
	
	cheepcheepquad[2] = {}
	cheepcheepquad[2][1] = love.graphics.newQuad(0, 16, 16, 16, 32, 32)
	cheepcheepquad[2][2] = love.graphics.newQuad(16, 16, 16, 16, 32, 32)
	
	squidquad = {}
	for x = 1, 2 do
		squidquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 24, 32, 24)
	end
	
	bulletbillquad = {}
	
	for y = 1, 4 do
		bulletbillquad[y] = love.graphics.newQuad(0, (y-1)*16, 16, 16, 16, 64)
	end
	
	hammerbrosquad = {}
	for y = 1, 4 do
		hammerbrosquad[y] = {}
		for x = 1, 4 do
			hammerbrosquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*34, 16, 34, 64, 136)
		end
	end	
	
	hammerquad = {}
	for j = 1, 4 do
		hammerquad[j] = {}
		for i = 1, 4 do
			hammerquad[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*16, 16, 16, 64, 64)
		end
	end
	
	plantquads = {}
	for j = 1, 4 do
		plantquads[j] = {}
		for i = 1, 2 do
			plantquads[j][i] = love.graphics.newQuad((i-1)*16, (j-1)*23, 16, 23, 32, 92)
		end
	end
	
	firequad = {love.graphics.newQuad(0, 0, 24, 8, 48, 8), love.graphics.newQuad(24, 0, 24, 8, 48, 8)}
	
	
	bowserquad = {}
	bowserquad[1] = {love.graphics.newQuad(0, 0, 32, 32, 64, 64), love.graphics.newQuad(32, 0, 32, 32, 64, 64)}
	bowserquad[2] = {love.graphics.newQuad(0, 32, 32, 32, 64, 64), love.graphics.newQuad(32, 32, 32, 32, 64, 64)}
	
	decoysquad = {}
	for y = 1, 7 do
		decoysquad[y] = love.graphics.newQuad(0, (y-1)*32, 32, 32, 64, 256)
	end
	
	--magic!
	magicquad = {}
	for x = 1, 6 do
		magicquad[x] = love.graphics.newQuad((x-1)*9, 0, 9, 9, 54, 9)
	end
	
	--GUI
	checkboxquad = {{love.graphics.newQuad(0, 0, 9, 9, 18, 18), love.graphics.newQuad(9, 0, 9, 9, 18, 18)}, {love.graphics.newQuad(0, 9, 9, 9, 18, 18), love.graphics.newQuad(9, 9, 9, 9, 18, 18)}}
	
	--portals
	portalquad = {}
	for i = 0, 7 do
		portalquad[i] = love.graphics.newQuad(0, i*4, 32, 4, 32, 28)
	end
	
	--Portal props	
	buttonquad = {love.graphics.newQuad(0, 0, 32, 5, 64, 5), love.graphics.newQuad(32, 0, 32, 5, 64, 5)}
	
	pushbuttonquad = {love.graphics.newQuad(0, 0, 16, 16, 32, 16), love.graphics.newQuad(16, 0, 16, 16, 32, 16)}
	
	wallindicatorquad = {love.graphics.newQuad(0, 0, 16, 16, 32, 16), love.graphics.newQuad(16, 0, 16, 16, 32, 16)}
	
	walltimerquad = {}
	for i = 1, 10 do
		walltimerquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 160, 16)
	end
	
	groundlightquad = {}
	for i = 1, 6 do
		groundlightquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 96, 16)
	end
	
	directionsquad = {}
	for x = 1, 6 do
		directionsquad[x] = love.graphics.newQuad((x-1)*7, 0, 7, 7, 42, 7)
	end
	
	excursionquad = {}
	for x = 1, 8 do
		excursionquad[x] = love.graphics.newQuad((x-1)*8, 0, 8, 32, 64, 32)
	end
	
	faithplatequad = {love.graphics.newQuad(0, 0, 32, 16, 32, 32), love.graphics.newQuad(0, 16, 32, 16, 32, 32)}
	
	gelquad = {love.graphics.newQuad(0, 0, 12, 12, 36, 12), love.graphics.newQuad(12, 0, 12, 12, 36, 12), love.graphics.newQuad(24, 0, 12, 12, 36, 12)}
	
	panelquad = {}
	for x = 1, 2 do
		panelquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 32, 16)
	end
end

function reloadGraphics()
	-- this doesn't rebuild quads so if any of these change resolution we're royally hosed
	iconimg = love.image.newImageData("icon.gif")
	love.window.setIcon(iconimg)

	fontimage = love.graphics.newImage("font.png")
	fontimageback = love.graphics.newImage("fontback.png")
	
	for _, v in pairs(imagelist) do
		_G[v .. "img"] = love.graphics.newImage( v .. ".png")
	end
	
	transparencyimg:setWrap("repeat", "repeat")
	
	menuselection = love.graphics.newImage("menuselect.png")
	mappackback = love.graphics.newImage("mappackback.png")
	mappacknoicon = love.graphics.newImage("mappacknoicon.png")
	mappackoverlay = love.graphics.newImage("mappackoverlay.png")
	mappackhighlight = love.graphics.newImage("mappackhighlight.png")
	
	mappackscrollbar = love.graphics.newImage("mappackscrollbar.png")
	
	fontimage2 = love.graphics.newImage("smallfont.png")
	fontimage3 = love.graphics.newImage("smallsymbols.png")
	
	entitiesimg = love.graphics.newImage("entities.png")
	
	popupfontimage = love.graphics.newImage("popupfont.png")
	
	linktoolpointerimg = love.graphics.newImage("linktoolpointer.png")
	
	titleimage = love.graphics.newImage("title.png")
	playerselectimg = love.graphics.newImage("playerselectarrow.png")
	
	magicimg = love.graphics.newImage("magic.png")
	
	checkboximg = love.graphics.newImage("checkbox.png")
	
	dropdownarrowimg = love.graphics.newImage("dropdownarrow.png")
	
	portalparticleimg = love.graphics.newImage("portalparticle.png")
	portalcrosshairimg = love.graphics.newImage("portalcrosshair.png")
	portaldotimg = love.graphics.newImage("portaldot.png")
	portalprojectileimg = love.graphics.newImage("portalprojectile.png")
	portalprojectileparticleimg = love.graphics.newImage("portalprojectileparticle.png")
	portalbackgroundimg = love.graphics.newImage("portalbackground.png")
	
	--Menu shit
	huebarimg = love.graphics.newImage("huebar.png")
	huebarmarkerimg = love.graphics.newImage("huebarmarker.png")
	volumesliderimg = love.graphics.newImage("volumeslider.png")
	directionsimg = love.graphics.newImage("directions.png")
	
	gradientimg = love.graphics.newImage("gradient.png")
	gradientimg:setFilter("linear", "linear")
	
	--@WARNING: This code is a bad influence because icons that don't already exist can't be introduced by a modpack. I'll fix it later.
	killfeed.icons = {}
	killfeed.exicons = {}
	local gdir = "graphics/DEFAULT/"
	local idir = "ui/icons/kill"
	for h,s in ipairs(love.filesystem.getDirectoryItems(gdir..idir)) do
		if love.filesystem.isFile(gdir..idir.."/"..s) then
			killfeed.icons[s:sub(0,-5)] = love.graphics.newImage(gdir..idir.."/"..s)
		end
	end
	idir = "ui/icons"
	for h,s in ipairs(love.filesystem.getDirectoryItems(gdir..idir)) do
		if love.filesystem.isFile(gdir..idir.."/"..s) then
			killfeed.exicons[s:sub(0,-5)] = love.graphics.newImage(gdir..idir.."/"..s)
		end
	end
	
end

function reloadSounds() -- mastersfx, master list of sounds current being looked at.
	soundstoload = {"none", "jump", "jumpbig", "stomp", "shot", "blockhit", "blockbreak", "coin", "pipe", "boom", "mushroomappear", "mushroomeat", "shrink", "death", "gameover", "fireball", "redcoin1", "redcoin2", "redcoin3", "redcoin4", "redcoin5", "boss_spit", "enemy_hit", "rainboom",
					"oneup", "levelend", "castleend", "scorering", "intermission", "fire", "bridgebreak", "bowserfall", "vine", "swim", "konami", "pause", "bulletbill", "addtime", "throw", "trophy", "switch",
					"lowtime", "tailwag", "planemode", "stab", "spring", "portal1open", "portal2open", "portalenter", "portalfizzle"}
				
	soundlist = {}
	
	for i, v in pairs(soundstoload) do
		local dat = love.sound.newSoundData(v..".ogg")
		soundlist[v] = {}
		soundlist[v].duration = dat:getDuration()
		soundlist[v].samplecount = dat:getSampleCount()
		soundlist[v].samplerate = dat:getSampleRate()
		soundlist[v].source = love.audio.newSource(dat)
		soundlist[v].lastplayed = 0
	end
	
	soundlist["scorering"].source:setLooping(true)
	soundlist["planemode"].source:setLooping(true)
	soundlist["portal1open"].source:setVolume(0.3)
	soundlist["portal2open"].source:setVolume(0.3)
	soundlist["portalenter"].source:setVolume(0.3)
	soundlist["portalfizzle"].source:setVolume(0.3)
end