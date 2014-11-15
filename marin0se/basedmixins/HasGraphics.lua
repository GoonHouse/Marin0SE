--[[
	this doesn't supply a prefab draw method because we use it's presence 
	
]]

--[[
	USED STATICS:
	image_sigs
]]

HasGraphics = {
	-- offsets for drawing
	cox = 0, offsetX = 0, quadcenterX = 0,
	coy = 0, offsetY = 0, quadcenterY = 0,
	coz = 0, offsetZ = 0, quadcenterZ = 0,
	
	--this is technically a physical property but it's also a visual one, I'm sorry
	rotation = 0,
	
	drawable = true, --by turning this off, you can disable drawing by the global handler
	visible = true, --this is for e
	
	graphicid = nil, --should be classname by default
	graphic = nil, --globalimages[self.graphicid].img or missinggraphicimg
	
	quad = nil, --this is a reference to the global quad list
	quadi = 1, --index in the quadlist
}

function HasGraphics:setGraphic(id, quadwrap)
	-- if quadwrap is true, we'll modulo the current quadi to the new graphic, else, reset to 1
	self.graphicid = id
	self.graphic = globalimages[self.graphicid].img or missinggraphicimg
	if not quadwrap then
		self.quadi = 1
	end
	self:setQuad(self.quadi)
	-- worst case scenario, this call is redundant; best: we wrap number that's too big/small
end

function HasGraphics:setQuad(ind)
	ind = ind or self.quadi
	-- set the quad based on the current graphics set
	self.quadi = ind%(globalimages[self.graphicid].frames+1)
	if self.quadi == 0 then
		--the only thing modulo and 1-indexed languages weren't prepared for
		self.quadi = 1
	end
	self.quad = globalimages[self.graphicid].quads[self.quadi]
end
--hoo boy
function HasGraphics:setOffset(nx, ny, nz)
	if type(nx) == "table" then
		nz = nx[3]
		ny = nx[2]
		nx = nx[1]
	end
	if not ny then ny = nx end
	if not nz then nz = ny end
	
	self.offsetX = nx or 0
	self.offsetY = ny or 0
	self.offsetZ = nz or 0
end

function HasGraphics:setQuadCenter(nx, ny, nz)
	if type(nx) == "table" then
		nz = nx[3]
		ny = nx[2]
		nx = nx[1]
	end
	if not ny then ny = nx end
	if not nz then nz = ny end
	
	self.quadcenterX = nx or 0
	self.quadcenterY = ny or 0
	self.quadcenterZ = nz or 0
end

function HasGraphics:setCo(nx, ny, nz)
	if type(nx) == "table" then
		nz = nx[3]
		ny = nx[2]
		nx = nx[1]
	end
	if not ny then ny = nx end
	if not nz then nz = ny end
	
	self.cox = nx or 0
	self.coy = ny or 0
	self.coz = nz or 0
end

--@TODO: Needs a static method to pre-queue assets.
function HasGraphics:cacheImage(imgname, dimx, dimy)
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

function HasGraphics:nextFrame()
	-- I don't know why I let this quirk exist but I haven't enough sample data to factor it out yet.
	self:setQuad(self.quadi)
	self.quadi = self.quadi + 1
end

-- doing it upon load is dubious but we don't have a way to get all resources used in a level yet
function HasGraphics:included(klass)
	-- Go through the input map
	for k,v in pairs(klass.GRAPHIC_SIGS) do
		self:cacheImage(k, v[1],v[2])
	end
end