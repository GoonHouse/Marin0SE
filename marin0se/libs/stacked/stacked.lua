--[[
	MIT LICENSE

    Copyright (c) 2014 Phoenix C. Enero

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]--

stacked = {
	font = love.graphics.newFont(8),
	graphsToManage = {},
	graphsUnmanaged = {},
	simpleGraphs = {},
	stackedGraphs = {},
	graphSortFunc = function(a, b)
		return a.vmin > b.vmin
	end,
	graphSort = function()
		stacked.graphsUnmanaged = {}
		for k,v in pairs(stacked.graphsToManage) do
			table.insert(stacked.graphsUnmanaged, v)
		end
		table.sort(stacked.graphsUnmanaged, stacked.graphSortFunc)
	end,
}
stacked.protoType = {
	x = 0, -- | position of the graph
	y = 0, -- |
	width = 50, --  | dimensions of the graph
	height = 30, --|
	delay = 0.5, -- delay until the next update
	name = "graph",
	points = 25, --width/2 was the default
	
	--pollmode = "stretch", --stretch, single
	drawmode = "relative", --"relative", "scale"
	lwidth = 2,
	font = stacked.font,
	fcolor = {255, 255, 255},
	lcolor = {128, 0, 0},
	draggable = false, -- whether it is draggable or not
	vmax = -math.huge, -- the maximum value of the graph
	pmax = -math.huge,
	vmin = math.huge, -- the minimum value of the graph
	cur_time = 0, -- the current time of the graph
	func = function(g, dt, ...)
		return dt 
	end,
	lblformat = "%(name)s: %(val)s (%(vmax)s / %(vmin)s)",
	dlabel = true,
	cscalemin = 0,
	cscalemax = 1,
	--[[
		name --the name of the graph
		val --the value of the individual update function
		vmax --the max visible value of the graph
	]]
	vals = {}, -- the values of the graph
	
	val = 0, --temp value for use against sprintf, changed in update
	label = "graph", --what is drawn, will get printed, changed in update
}

-- creates a graph table (too lazy to make objects and stuff)
function stacked.Simple(t)
	local g = table.combine(stacked.protoType, t)
	for i=1, g.points do
		table.insert(g.vals, 0)
	end
	
	-- return the table
	table.insert(stacked.simpleGraphs, g)
	return g
end

function stacked.Create(name, t)
	local g = table.combine(stacked.protoType, t)
	for i=1, g.points do
		table.insert(g.vals, 0)
	end
	g.name = name
	
	-- return the table
	stacked.graphsToManage[name] = g
	table.insert(stacked.graphsUnmanaged, g)
	return g 
end

--fpsGraph.updateGraph(graph, fps, "FPS: " .. fps, dt)
function stacked.update(dt)
	for k,v in pairs(stacked.graphsToManage) do
		stacked.updateGraph(v, dt)
	end
end

function stacked.pointUpdate(graph, dt)
	-- for when dt isn't actually dt or we simply don't have one
	local val = graph.func(graph, dt)
	table.remove(graph.vals, 1)
	table.insert(graph.vals, val)
	
	local min, max = math.huge, -math.huge
	for i=1, #graph.vals do
		local v = graph.vals[i]
		if v > max then max = v end
		if v < min then min = v end
	end
	graph.vmax = max
	graph.vmin = min
	-- update the max and label variables
	graph.val = val
	graph.pmax = max --math.ceil(graph.vmax/10)*10+20 --why is this? I don't know.
	graph.label = graph.lblformat % graph
end

function stacked.updateGraph(graph, dt, ...)
	-- update the current time of the graph
	graph.cur_time = graph.cur_time + dt
	local reps = math.floor(graph.cur_time/graph.delay)
	graph.cur_time = graph.cur_time - graph.delay*reps
	
	local val = graph.func(graph, dt, ...)
	for i=1,reps do
		-- add new values to the graph while removing the first
		table.remove(graph.vals, 1)
		table.insert(graph.vals, val)
	end
	
	local min, max = math.huge, -math.huge
	for i=1, #graph.vals do
		local v = graph.vals[i]
		if v > max then max = v end
		if v < min then min = v end
	end
	graph.vmax = max
	graph.vmin = min
	-- update the max and label variables
	graph.val = val
	graph.pmax = max --math.ceil(graph.vmax/10)*10+20 --why is this? I don't know.
	graph.label = graph.lblformat % graph
end

function stacked.xdraw(graph)
	
end

-- draws all the graphs in your list
function stacked.draw(graphs)
	-- set default font
	local snap = love.graphics.takeSnapShot()

	-- loop through all of the graphs
	for k,v in pairs(stacked.graphsToManage) do
		local step = v.width/v.points
		-- draw graph
		love.graphics.setLineWidth(v.lwidth)
		love.graphics.setColor(v.lcolor)
		for i=2, v.points do
			local a = v.vals[i-1]
			local b = v.vals[i]
			if v.drawmode == "scale" then
				love.graphics.line(
					step*(i-2)+v.x, v.height*(-a/v.pmax+1)+v.y,
					step*(i-1)+v.x, v.height*(-b/v.pmax+1)+v.y
				)
			elseif v.drawmode == "relative" then
			-- max: 466, min: 345, i: 401
				love.graphics.line(
					step*(i-2)+v.x,
					v.y - (v.height * math.scale(a, v.vmin, v.vmax, v.cscalemin, v.cscalemax)) + v.height,
					step*(i-1)+v.x,
					v.y - (v.height * math.scale(b, v.vmin, v.vmax, v.cscalemin, v.cscalemax)) + v.height
				)
			end
		end

		-- print the label of the graph
		if v.dlabel then
			local width, nolines = v.font:getWrap(v.label, v.width)
			love.graphics.setFont(v.font)
			love.graphics.setColor(v.fcolor)
			printfwithfont(v.font, v.label, v.x, v.height+v.y-v.font:getHeight()*nolines, v.width)
			--love.graphics.printf(v.label, v.x, v.height+v.y-v.font:getHeight()*nolines, v.width)
		end
	end
	
	love.graphics.applySnapShot(snap)
end

--[[
	this is here to sort the labels based on the minimums and then draw them up and down
]]
function stacked.exdraw()
	stacked.draw() --draw the lines
	stacked.graphSort()
	for k,v in pairs(stacked.graphsUnmanaged) do
		local txt = v.lblformat % v
		love.graphics.setColor(v.lcolor)
		printfwithfont(v.font, txt, v.x, v.height+v.y-v.font:getHeight()*k, v.width)
	end
end

--[[
	this function is here to demonstrate snippets of logic necessary to have a stack-graph
	the idea is that they need to sync min-max values
]]
function stamp(bucket)
	if bucket ~= "init" then
		local seg
		if bucketmode == "individual" then
			seg = os.clock()-bucketsegment
		elseif bucketmode == "total" then
			seg = os.clock()-bucketstart
		end
		grapher.updateGraph(grapher.graphsToManage[bucket], globaldt, seg*1000)
		if bucketmode == "total" then
			-- sync the min/max values to prevent scaling forming inaccurate draws
			local min, max = 0, 0
			for k,v in pairs(enum_draw_types) do
				local g = grapher.graphsToManage[v]
				if g.vmax > max then max = g.vmax end
				if g.vmin < min then min = g.vmin end
			end
			
			--if I were a smarter man, I'd know how to use a sort function to avoid a second pass
			for k,v in pairs(enum_draw_types) do
				local g = grapher.graphsToManage[v]
				g.vmin = min
				g.vmax = max
				g.pmax = max
			end
		end
		bucketsegment = os.clock()
	else
		bucketstart = os.clock()
		bucketsegment = bucketstart
	end
end

--[[
bucketgraph = {
	func = function(g, dt, ...)
		local gob = {...}
		return gob[1] --dt is not really dt but don't tell nobody
	end,
	width = 400,
	height = 100,
	points = 100,
	cscalemin = 0,
	cscalemax = 1,
	--pollmode = "single",
	drawmode = "relative", --relative
	lblformat = "%(name)s: %(val)1f",
	dlabel = false,
}
]]