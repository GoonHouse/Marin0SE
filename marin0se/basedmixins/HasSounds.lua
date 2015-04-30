HasSounds = {
	activesounds = {},
	filters = {},
	
}
--[[
	REQUIRES ATTRIBUTES:
	r
	
	EXPECTED STATIC PROPERTIES:
	sig_sounds = {
		soundname = {
			volume = 1.0,
			pitch = 1.0,
			relative = true,
			use_velocity = true,
			use_
		}
	}
]]
function HasSounds.filters.delete_sounds(k, v)
	return v.source:tell("samples") >= v.samplecount
end

function HasSounds:playSound(sound, is_static, use_velocity)
	if not soundlist[sound] then
		print("WARNING: Entity tried to play nonexistant sound: "..sound)
		return
	end

	if soundenabled then
		if delaylist[sound] then
			local currenttime = love.timer.getTime()
			if currenttime-soundlist[sound].lastplayed > delaylist[sound] then
				soundlist[sound].lastplayed = currenttime
			else
				return
			end
		end
		local soundclone = table.combine(soundlist[sound])
		soundclone.source = soundlist[sound].source:clone()
		soundclone.moves = true
		soundclone.use_velocity = false
		if is_static then
			soundclone.moves = false
		end
		soundclone.source:setRelative(false)
		soundclone.source:setPosition(self.x, self.y, self.z)
		if use_velocity then
			-- velocity has the potential to sound weird, so, it's optional
			soundclone.use_velocity = true
			soundclone.source:setVelocity(self.speedx, self.speedy, self.speedz)
		else
			soundclone.source:setVelocity(0, 0, 0)
		end
		soundclone.source:play()
		table.insert(self.activesounds, soundclone)
	end
end

function HasSounds:cacheSound(sound, settings)
	if soundlist[sound] then
		print("WARNING: Tried to load existing sound.")
		return false
	end
	
	local dat = love.sound.newSoundData(v..".ogg")
	soundlist[sound] = {}
	soundlist[sound].duration = dat:getDuration()
	soundlist[sound].samplecount = dat:getSampleCount()
	soundlist[sound].samplerate = dat:getSampleRate()
	soundlist[sound].source = love.audio.newSource(dat)
	soundlist[sound].lastplayed = 0
	if settings.volume then
		soundlist[sound].source:setVolume(settings.volume)
	end
	if settings.pitch then
		soundlist[sound].source:setPitch(settings.pitch)
	end
	if settings.looping then
		soundlist[sound].source:setLooping(settings.looping)
	end
end

function HasSounds:included(klass)
	-- import the noises
	for k,v in pairs(klass.SOUND_SIGS) do
		self:cacheSound(k, v)
	end
end