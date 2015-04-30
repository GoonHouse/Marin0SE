animationtarget = class("animationtarget")

function animationtarget:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	self.outtable = {}
	self.id = ""
	
	--IDENTIFIER
	if #self.r > 0 and self.r[1] ~= "link" then
		self.id = tostring(self.r[1])
		table.remove(self.r, 1)
	end
end

function animationtarget:link()
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

function animationtarget:addoutput(a, t)
	print("added output")
	table.insert(self.outtable, {a, t})
end

function animationtarget:out(t)
	for i = 1, #self.outtable do
		print("telling our dad")
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end