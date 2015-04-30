soundman = class("soundman")

--[[
	this is a class meant to manage all sound sources, mostly to allow us to manage 3d sound sources easily
]]


function soundman:init()
	self.soundlist = {} --the list of sounds that should be managed
	self.delaylist = {} --the list of sounds to be delayed
	self.soundenabled = true --whether or not sounds are enabled globally
	self.usepositionalsound = true --whether the listener is global, whether
	
	-- listener sfx properties:
	--DistanceModel: distmodel (none, inverse, inverse clamped, linear, linear clamped, exponent, exponent clamped)
	--Orientation: vector upward, vector forward
	--default: 0, 0, -1; 0, 1, 0
	--Position: x, y, z
	--default: 0, 0, 0
	--Velocity: x, y, z
	--Volume: float volume
	
	-- individual sfx properties:
	--AttenuationDistances: num ref, num max
	--Cone: rad innerAngle, rad outerAngle, float outerVolume
	--Direction: x, y, z
	--Looping: bool
	--Pitch: float
	--Position: x, y, z
	--Relative: bool
	--Rolloff: num
	--Velocity: x, y, z
	--Volume: float volume (max: 1.0)
	--VolumeLimits: min, max
	
end

function playsound2(sound)
	if not soundlist[sound] then
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
		
		soundlist[sound].source:stop()
		soundlist[sound].source:rewind()
		soundlist[sound].source:play()
	end
end

