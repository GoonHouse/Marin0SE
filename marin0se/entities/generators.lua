generators = class("generators")

function generators:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.visible = false
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		self.contents = self.r[1]
		table.remove(self.r, 1)
		else
	table.remove(self.r, 1)
	end
end

function generators:link()
	while #self.r > 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[3]) == v.cox and tonumber(self.r[4]) == v.coy then
					v:addoutput(self, self.r[2])
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function generators:input(t, input)
	if t ~= "off" then
		if self.contents == "bulletbill" then
			gensrunning[1] = true
			return true
		elseif self.contents == "flyingcheeps" then
			gensrunning[2] = true
			return true
		elseif self.contents == "bowserflames" then
			gensrunning[3] = true
			return true
		elseif self.contents == "highwindright" then
			gensrunning[4] = true
			return true
		end
	else
	gensrunning[1] = false
	gensrunning[2] = false
	gensrunning[3] = false
	gensrunning[4] = false
	return false
	end
end