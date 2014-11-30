editortool = class('editortool')

function editortool:init(name)
	self.status = ""
	self.name = name
	self.active = false
	
	self.allowdrag = true
	self.dragging = false
	
	-- this draws the little dashed lines around where the current tile is
	self.showtilehighlight = true
end

-- change parameters
function editortool:change(...)
	print("editortool.change():", ...)
	--for k,v in pairs(arg) do print(k, "=", v) end
end

-- revert the states set by attempting to begin the operation
function editortool:cancel()
	
end

function editortool:operate()
	-- this function is meant to paramaterize inputs for an undo history and insert it
end

function editortool:revertOperation()
	-- this is the invert of operate, which is meant to undo what just happened in the undo stack
end

function editortool:update(dt)
	if self.active and controls.editorPaint and not testlevel and not editormenuopen then
		if controls.tap.editorSelect and editorignoretap then
			-- not entirely sure this belongs here but it'll help us sort out the paint tool for now
			return false
		elseif controls.release.editorSelect and editorignorerelease then
			return false
		else
			return true
		end
	end
end

function editortool:canFire()
	if self.allowdrag and not self.dragging then
		self.dragging = true
	end
	--print("click", tostring(controls.tap.editorSelect), "active", tostring(self.active), "noignore", tostring(not editorignoretap), "nomenuopen", tostring(not editormenuopen), "notest", tostring(not testlevel))
	return controls.tap.editorSelect and self.active and not editormenuopen and not testlevel
end

function editortool:canUnfire()
	if self.allowdrag and self.dragging then
		self.dragging = false
	end
	--print("unclick", tostring(controls.release.editorSelect), "active", tostring(self.active), "noignore", tostring(not editorignorerelease), "nomenuopen", tostring(not editormenuopen), "notest", tostring(not testlevel))
	return controls.release.editorSelect and self.active and not editormenuopen and not testlevel
end

function editortool:canPaint()
	return controls.editorPaint and not testlevel and not editormenuopen
end

function editortool:draw()
	if self.showtilehighlight then
		local x, y = getMouseTile(mouse.getX(), mouse.getY()-8*scale)
		love.graphics.draw(cursorareaimg, cursorareaquads[redcoinframe], math.floor((x-xscroll-1-(1/16))*16*scale), math.floor(((y-yscroll-1-(1/16))*16+8)*scale), 0, scale, scale)
	end
end