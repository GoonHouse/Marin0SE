music = {
	loaded = {},
	pitch = 1,
	list = {
		"overworld.ogg",
		"underground.ogg",
		"castle.ogg",
		"underwater.ogg",
		"starmusic.ogg",
		"outofbounds.ogg",
	},
	list_fast = {
		"overworld-fast.ogg",
		"underground-fast.ogg",
		"castle-fast.ogg",
		"underwater-fast.ogg",
		"starmusic-fast.ogg",
	},
}


function getfilepath(name)
	for i=1,#soundsearchdirs-1 do
		--@NOTE: This is making the assumption that the direct file link is at the end.
		local p = soundsearchdirs[i] % {mappack=mappack,file=name,soundpack=soundpack}
		if love.filesystem.isFile(p) then
			return p
		end
	end
end

function music:load(name)
	local filepath = getfilepath(name)
	if not filepath then
		print(string.format("can't load music %q: can't find file!", name))
		return false
	end
	
	if not self.loaded[filepath] then
		local loaded, source = pcall(love.audio.newSource, filepath, "stream")
		if loaded then
			-- all music should loop
			source:setRelative(true)
			source:setPosition(0,0,0)
			source:setVelocity(0,0,0)
			source:setLooping(true)
			source:setPitch(self.pitch)
			self.loaded[name] = source
		else
			print(string.format("can't load music %q: can't create source!", filepath))
			return false
		end
	end
	
	return true
end

function music:play(name, fast)
	if fast then
		local newname = name:sub(0, -5) .. "-fast" .. name:sub(-4)
		if getfilepath(newname) then
			name = newname
		end
	end
	
	-- try to load source from disk if it hasn't been loaded already
	if not self.loaded[name] and not self:load(name) then
		return
	end
	
	if self.loaded[name] then
		if soundenabled then
			self.loaded[name]:stop()
			self.loaded[name]:rewind()
			self.loaded[name]:play()
		end
	end
end

function music:stop(name, fast)
	if fast then
		local newname = name:sub(0, -5) .. "-fast" .. name:sub(-4)
		if getfilepath(newname) then
			name = newname
		end
	end
	
	if self.loaded[name] then
		self.loaded[name]:stop()
	end
end

function music:update()
	for filepath, source in pairs(self.loaded) do
		source:setPitch(self.pitch)
	end
end
