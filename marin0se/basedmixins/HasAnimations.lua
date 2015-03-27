HasAnimations = {
	grids = {}, --anim8 grid
	animations = {},
}

function HasAnimations:gridImage(image, x, y)
	//self.grids[image] = 
end

function HasAnimations:included(klass)
	for k,v in pairs(klass.GRAPHIC_SIGS) do
		self:gridImage(k, v[1],v[2])
	end
	
	registerInitHook(klass, AdvancedGraphics.inithook)
end