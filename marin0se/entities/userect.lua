userect = class('userect')

function userect:init(x, y, width, height, parent)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.parent = parent
	self.destroy = false
	
	table.insert(objects["userect"], self)
end

function userect:update(dt)
	return self.destroy
end

function userect:draw()
	
end

function userect:setPos(x, y)
	self.x = x
	self.y = y
end

function userect:use(x, y, width, height, user)
	--x, y, width, height are presumably different from where ?
	if aabb(x, y, width, height, self.x, self.y, self.width, self.height) then
		self.parent:used(user)
	end
end


-- these are here so that I can keep track of how their original implementation worked
function legacy_userect(x, y, width, height)
	local outtable = {}
	
	local j
	
	for i, v in pairs(userects) do
		if aabb(x, y, width, height, v.x, v.y, v.width, v.height) then
			table.insert(outtable, v.callback)
			if not j then
				j = i
			end
		end
	end
	
	return outtable, j
end

function legacy_adduserect(x, y, width, height, callback)
	local t = {}
	t.x = x
	t.y = y
	t.width = width
	t.height = height
	t.callback = callback
	t.delete = false
	
	table.insert(userects, t)
	return t
end