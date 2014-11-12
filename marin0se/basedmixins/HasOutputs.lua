HasOutputs = {
	outputTable = {},
	hasOutput = true,
}

function HasOutputs:addoutput(a, t)
	table.insert(self.outputTable, {a, t})
end

function HasOutputs:out(t)
	for i = 1, #self.outputTable do
		-- if it has an input method, feed it the data
		if self.outputTable[i][1].input then
			self.outputTable[i][1]:input(t, self.outputTable[i][2])
		end
		-- if it doesn't, how did it get here to begin with?
	end
end

function HasOutputs:toggle_all_outputs()
	for i = 1, #self.outputTable do
		if self.outputTable[i][1].input then
			self.outputTable[i][1]:input("toggle", self.outputTable[i][2])
		end
	end
end