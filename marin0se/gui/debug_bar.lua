-- @TODO: #11
debug_bar = {
	toggle = true,
	scrollback = {},
	scrollback_index = 1,
}

-- overload print to pipe it to the textbox in addition to here
local _print = print
function print(...)
	local strings = {}
	for k,v in pairs({...}) do
		strings[k] = tostring(v)
	end
	local text = table.concat(strings, "\t")
	
	_print(...)
	debug_bar:append(text)
end

function debug_bar:parse(cmd)
	local xcmd = cmd
	if not (
		xcmd:match("end") or xcmd:match("do") or 
		xcmd:match("do") or xcmd:match("function") 
		or xcmd:match("return") or xcmd:match("=") 
	) then
		xcmd = "return " .. xcmd
	end
	local func, why = loadstring(xcmd,"*")
	if not func then
		return false, why
	end
	local xselect = function(x, ...) return x, {...} end
	local ok, result = xselect(pcall(func))
	if not ok then
		return false, result[1]
	end

	if type(result[1]) == "function" and not xcmd:match("[()=]") then
		ok, result = xselect(pcall(result[1]))
		if not ok then 
			return false, result[1]
		end
	end
	
	if ( #result > 0 ) then
		local strings = {}
		for k,v in pairs(result) do strings[k] = tostring(v) end
		return true, table.concat(strings, " , ")
	end

	return true, "nil"
end

function debug_bar:append(text)
	text = text or ""
	
	if text ~= "" then
		local console = self.console_log:GetLines()

		-- Enforce console history limit.
		if game.console.history_limit ~= -1 then
			local diff = (text:countlines() + #console) - game.console.history_limit 
			if diff > 0 then
				for i=1,diff do
					table.remove(console, 1)
				end
			end
		end
		
		table.insert(console, text)
		self.console_log:SetLines(console)
		--self.console_log:GetVerticalScrollBody():Scroll(-self.parent.buttonscrollamount)
	end
end

function debug_bar.handleEnter(object, text)
	if text ~= "" then
		local scrollback_size = table.length(debug_bar.scrollback) 
		if game.console.scrollback_limit == -1 then
			debug_bar.scrollback_index = scrollback_size+2
		else
			if scrollback_size == game.console.scrollback_limit then
				table.remove(debug_bar.scrollback, 1)
				debug_bar.scrollback_index = scrollback_size+1
			else
				debug_bar.scrollback_index = scrollback_size+2
			end
		end

		table.insert(debug_bar.scrollback, text)

		debug_bar:append("> " .. text)
		local ok, result = debug_bar:parse(text)
		if not ok then
			result = "ERROR: "..result
		end
		
		debug_bar:append(result)
		
		object:Clear()
	end
end

function debug_bar:func()  
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local version = loveframes.version
	local stage = loveframes.stage

	self.debug_panel = loveframes.Create("panel")
	self.debug_panel:SetSize(width, 410)
	self.debug_panel:SetPos(0, -410) -- -392 to show the junk, else, not

	self.console_panel = loveframes.Create("panel", self.debug_panel)
	self.console_panel:SetSize(width, 365)
	self.console_panel:SetPos(0, 0)

	self.console_log = loveframes.Create("textinput", self.console_panel)
	self.console_log:SetPos(1, 1)
	self.console_log:SetSize(width-2, 363)
	self.console_log:SetMultiline(true)
	--self.console_log:ShowLineNumbers(false)
	self.console_log:SetEditable(false)
	self.console_log:SetPlaceholderText("I'm a freakin' console.")
	print("console loaded")

	--[[
	self.console_list = loveframes.Create("list", self.console_panel)
	self.console_list:SetPos(1, 1)
	self.console_list:SetSize(width-2, 363)
	self.console_list:SetPadding(5)
	self.console_list:SetSpacing(5)
	self.console_list:SetAutoScroll(true)

	self.console_log = loveframes.Create("text")
	self.console_log:SetPos(1, 1)
	self.console_log:SetSize(width-2, 363)
	self.console_log:SetFont(love.graphics.newFont(12))
	self.console_log:SetLinksEnabled(false)
	self.console_log:SetDetectLinks(false)
	--console_log:SetMultiline(true)
	self.console_log:SetText("console loaded")
	self.console_log:SetIgnoreNewlines(false)
	self.console_list:AddItem(self.console_log)
	dprint("whoaaaa shit, everything is fucked", "error")
	]]

	self.input_panel = loveframes.Create("panel", self.debug_panel)
	self.input_panel:SetSize(width, 27)
	self.input_panel:SetPos(0, 365)

	self.console_input = loveframes.Create("textinput", self.input_panel)
	self.console_input:SetMultiline(false)
	self.console_input:SetSize(width-2, 25)
	self.console_input:SetPos(1, 1)
	self.console_input:SetText("")
	self.console_input.OnEnter = self.handleEnter

	self.toolbar = loveframes.Create("panel", self.debug_panel)
	self.toolbar:SetSize(width, 18)
	self.toolbar:SetPos(0, 392)

	self.lfbutton = loveframes.Create("imagebutton", self.toolbar)
	self.lfbutton:SetImage("ui/silk/bug.png")
	self.lfbutton:SetPos(1, 1)
	self.lfbutton:SetText("")
	self.lfbutton:SizeToImage()
	self.lfbutton.OnClick = function(object, x, y)
		local debug = loveframes.config["DEBUG"]
		loveframes.config["DEBUG"] = not debug
	end

	self.console_button = loveframes.Create("imagebutton", self.toolbar)
	self.console_button:SetImage("ui/silk/application_xp_terminal.png")
	self.console_button:SetPos(18, 1)
	self.console_button:SetText("")
	self.console_button:SizeToImage()
	self.console_button.OnClick = function(object, x, y)
		self.ToggleConsole()
	end

	self.clear_button = loveframes.Create("imagebutton", self.toolbar)
	self.clear_button:SetImage("ui/silk/page_white.png")
	self.clear_button:SetPos(36, 1)
	self.clear_button:SetText("")
	self.clear_button:SizeToImage()
	self.clear_button.OnClick = function(object, x, y)
		self.console_log:SetText("console cleared")
	end

	--[[
	self.connect_button = loveframes.Create("imagebutton", self.toolbar)
	self.connect_button:SetImage("ui/silk/connect.png")
	self.connect_button:SetPos(54, 1)
	self.connect_button:SetText("")
	self.connect_button:SizeToImage()
	self.connect_button.OnClick = function(object, x, y)
		connect_panel.ToggleVisible()
	end

	self.globals_button = loveframes.Create("imagebutton", self.toolbar)
	self.globals_button:SetImage("ui/silk/controller.png")
	self.globals_button:SetPos(72, 1)
	self.globals_button:SetText("")
	self.globals_button:SizeToImage()
	self.globals_button.OnClick = function(object, x, y)
		globals_viewer.ToggleVisible()
	end

	self.video_settings = loveframes.Create("imagebutton", self.toolbar)
	self.video_settings:SetImage("ui/silk/computer_edit.png")
	self.video_settings:SetPos(72, 1)
	self.video_settings:SetText("")
	self.video_settings:SizeToImage()
	self.video_settings.OnClick = function(object, x, y)
		video_settings.ToggleVisible()
	end
	]]

	self.exit = loveframes.Create("imagebutton", self.toolbar)
	self.exit:SetImage("ui/silk/cross.png")
	self.exit:SetPos(love.window.getWidth()-17, 1)
	self.exit:SetText("")
	self.exit:SizeToImage()
	self.exit.OnClick = function(object, x, y)
		love.event.quit()
	end
end

function debug_bar:ToggleConsole()
	local height = love.graphics.getHeight()
	local panelheight = self.debug_panel:GetHeight() -- -18 else not
	if self.toggle then
		any_frames_visible = true  
		tween(0.10, self.debug_panel, {y = (0)})
		self.console_input:SetFocus(true)
	else
		any_frames_visible = false  
		tween(0.10, self.debug_panel, {y = (0 - panelheight)})
	end
	local textos = self.console_input:GetText()
	if textos:sub(-1) == "`" then
		self.console_input:SetText(textos:sub(1, -2))
	end
	self.toggle = not self.toggle
end