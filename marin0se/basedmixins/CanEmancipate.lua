CanEmancipate = {
	emancipatecheck = true,
	-- this will be used to prevent further updates once emancipated
	was_emancipated = false
}

function CanEmancipate:emancipate()
	print("baseentity told to emancipate")
	if not self.was_emancipated then
		local speedx, speedy = self.speedx, self.speedy
		if self.carrier then
			speedx = speedx + self.carrier.speedx
			speedy = speedy + self.carrier.speedy
			self.carrier:drop_held()
			self.carrier = nil --in the event that our carrier doesn't call our dropped method
		end
		table.insert(objects["emancipateanimation"], emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, speedx, speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self:remove()
		self.was_emancipated = true
		self.drawable = false
	end
end