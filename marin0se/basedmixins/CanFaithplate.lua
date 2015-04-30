CanFaithplate = {
	can_faithplate = true,
	falling = true,
}

function CanFaithplate:faithPlate(dir)
	self.falling = true
end

function CanFaithplate:startFall() -- this is presumably used by a faithplate as a callback, I can't be sure
	self.falling = true
end