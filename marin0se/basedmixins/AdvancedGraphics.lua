--[[
	this doesn't supply a prefab draw method because we use it's presence 
	
]]

--[[
	USED STATICS:
	image_sigs
]]

AdvancedGraphics = {
	-- offsets for drawing
	drawable = true, --by turning this off, you can disable drawing by the global handler
	
	graphicid = nil, --should be classname by default
	graphic = nil, --globalimages[self.graphicid].img or missinggraphicimg
	
	quad = nil, --this is a reference to the global quad list
	quadi = 1, --index in the quadlist
	
	grids = {}, --anim8 grid, keyed by animation name, quad dealio
	animations = {}, --anim8 animation, keyed by animation name, 
}

function AdvancedGraphics.inithook(self, t)
	local k = t.class.static
	self:setGraphic(t.class.name, true)
end

function AdvancedGraphics:setGraphic(id, quadwrap)
	-- if quadwrap is true, we'll modulo the current quadi to the new graphic, else, reset to 1
	self.graphicid = id
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	if not quadwrap then
		self.quadi = 1
	end
	self:setQuad(self.quadi)
	-- worst case scenario, this call is redundant; best: we wrap number that's too big/small
end

function AdvancedGraphics:setQuad(ind)
	ind = ind or self.quadi
	-- set the quad based on the current graphics set
	self.quadi = ind%(globalimages[self.graphicid].frames+1)
	if self.quadi == 0 then
		--the only thing modulo and 1-indexed languages weren't prepared for
		self.quadi = 1
	end
	self.quad = globalimages[self.graphicid].quads[self.quadi]
end

--@TODO: Needs a static method to pre-queue assets.
function AdvancedGraphics:cacheImage(imgname, dimx, dimy)
	globalimages[imgname] = {quads = {}, dims={dimx,dimy}}
	local gl = globalimages[imgname]
	
	gl.img = love.image.newImageData(imgname..".png")
	local timg = love.graphics.newImage(gl.img)
	local w, h = math.floor(timg:getWidth()/dimx), math.floor(timg:getHeight()/dimy)
	gl.img = timg
	gl.frames=w*h
	for y = 1, h do
		-- Yeah, I'm not entirely certain why I'm allowing the use of y>1, but here we are.
		for x = 1, w do
			table.insert(gl.quads, love.graphics.newQuad((x-1)*dimx, (y-1)*dimy, dimx, dimy, timg:getDimensions()))
		end
	end
end

function AdvancedGraphics:nextFrame()
	-- I don't know why I let this quirk exist but I haven't enough sample data to factor it out yet.
	self:setQuad(self.quadi)
	self.quadi = self.quadi + 1
end

-- doing it upon load is dubious but we don't have a way to get all resources used in a level yet
function AdvancedGraphics:included(klass)
	for k,v in pairs(klass.GRAPHIC_SIGS) do
		self:cacheImage(k, v[1],v[2])
	end
	
	registerInitHook(klass, AdvancedGraphics.inithook)
end