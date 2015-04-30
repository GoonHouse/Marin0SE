anim = class("anim")
--[[
	anim (for lack of the availability of "animation") is for player animations
	
	this is so that the code for handling an animation like mario growing doesn't
	leave the player in a particular weird state that hinges on physical properties
	
	
]]

function anim:init(actor, sequence_name)
	
	self.actor = actor
	-- a reference to the player object we are responsible for managing
	
	self.sequence_name = sequence_name
	-- the name of a sequence to invoke on a player
	
	self.timer = 0
	-- how far along in the animation we are
	self.duration = 0
	-- the total duration of the animation
end


