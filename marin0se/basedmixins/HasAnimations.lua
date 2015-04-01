HasAnimations = {
	grid = nil, --anim8 grid reference
	animation = nil, --anim8 animation reference
	animation_name = '',
	
	grids = {}, --anim8 grid
	animations = {}, --anim8 animation
	graphics = {},
	
	pattern = "graphics/%(graphicspack)s/basedents/%(entname)s/%(file)s",
	file_pattern = "%(character)s/%(powerupstate)s/%(holdtype)s/%(aimangle)s/%(animname)s.png",
}

function HasAnimations.inithook(self, t)
	local k = t.class.static
	self:setAnimation("jumpman_super_2hgun_0_walk")
end

function HasAnimations:setAnimation(anim)
	if self.animation then
		self.animation:pause()
	end
	self.grid = self.grids[anim]
	self.animation_name = anim
	self.animation = self.animations[anim]
	self.animation:resume()
end

function HasAnimations:gridImage(anim, path, x, y)
	local image = love.graphics.newImage(path)
	local sig = self.ANIM_SIGS[anim]
	local g = anim8.newGrid(sig.size[1], sig.size[2], image:getWidth(), image:getHeight())
	self.grids[anim] = g
	self.animations[anim] = anim8.newAnimation(g(sig.grids), sig.frames)
end

function HasAnimations:gridSig(anim, sig, path)
	print("gridding: ", anim, path)
	local image = love.graphics.newImage(path)
	local gat = anim8.newGrid(sig.size[1], sig.size[2], image:getWidth(), image:getHeight())
	self.grids[anim] = gat
	self.graphics[anim] = image
	local go = gat:getFrames(unpack(sig.grids))
	self.animations[anim] = anim8.newAnimation(go, sig.frames)
end

function HasAnimations:included(klass)
	for k,v in pairs(klass.ANIM_SIGS) do
		local parts = string.split(k, "_")
		local file = self.file_pattern%{
			character = parts[1],
			powerupstate = parts[2],
			holdtype = parts[3],
			aimangle = parts[4],
			animname = parts[5]
		}
		local path = self.pattern%{
			graphicspack = graphicspack,
			entname = klass.name,
			file = file,
		}
		print("DEBOOGING")
		print_r(parts)
		print(file)
		print(path)
		print(k)
		print_r(v)
		self:gridSig(k, v, path)
		AdvancedGraphics:cacheImage(path, v.size[1], v.size[2])
	end
	
	registerInitHook(klass, HasAnimations.inithook)
end