-- @TODO: #11
debug_bar = {}
debug_bar.toggle = true
debug_bar.scrollback = {}
debug_bar.scrollback_index = 1

function debug_bar.func()  
	local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
	local version = loveframes.version
	local stage = loveframes.stage
  
  debug_bar.debug_panel = loveframes.Create("panel")
  debug_bar.debug_panel:SetSize(width, 410)
  debug_bar.debug_panel:SetPos(0, -410) -- -392 to show the junk, else, not
	
  debug_bar.console_panel = loveframes.Create("panel", debug_bar.debug_panel)
  debug_bar.console_panel:SetSize(width, 365)
  debug_bar.console_panel:SetPos(0, 0)
  
  debug_bar.console_log = loveframes.Create("textinput", debug_bar.console_panel)
  debug_bar.console_log:SetPos(1, 1)
  debug_bar.console_log:SetSize(width-2, 363)
  debug_bar.console_log:SetMultiline(true)
  --debug_bar.console_log:ShowLineNumbers(false)
  debug_bar.console_log:SetEditable(false)
  debug_bar.console_log:SetPlaceholderText("I'm a freakin' console.")
  print("console loaded")
  
  --[[debug_bar.console_list = loveframes.Create("list", debug_bar.console_panel)
  debug_bar.console_list:SetPos(1, 1)
  debug_bar.console_list:SetSize(width-2, 363)
  debug_bar.console_list:SetPadding(5)
  debug_bar.console_list:SetSpacing(5)
  debug_bar.console_list:SetAutoScroll(true)
  
  debug_bar.console_log = loveframes.Create("text")
	debug_bar.console_log:SetPos(1, 1)
	debug_bar.console_log:SetSize(width-2, 363)
	debug_bar.console_log:SetFont(love.graphics.newFont(12))
  debug_bar.console_log:SetLinksEnabled(false)
  debug_bar.console_log:SetDetectLinks(false)
	--console_log:SetMultiline(true)
	debug_bar.console_log:SetText("console loaded")
  debug_bar.console_log:SetIgnoreNewlines(false)
  debug_bar.console_list:AddItem(debug_bar.console_log)
  dprint("whoaaaa shit, everything is fucked", "error")]]
  --
  
  
  
  debug_bar.input_panel = loveframes.Create("panel", debug_bar.debug_panel)
  debug_bar.input_panel:SetSize(width, 27)
  debug_bar.input_panel:SetPos(0, 365)
  
  debug_bar.console_input = loveframes.Create("textinput", debug_bar.input_panel)
  debug_bar.console_input:SetMultiline(false)
  debug_bar.console_input:SetSize(width-2, 25)
  debug_bar.console_input:SetPos(1, 1)
  debug_bar.console_input:SetText("")
  debug_bar.console_input.OnEnter = function(object, text)
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
      
      console_parse(text)
      object:Clear()
    end
  end
  
	debug_bar.toolbar = loveframes.Create("panel", debug_bar.debug_panel)
	debug_bar.toolbar:SetSize(width, 18)
  debug_bar.toolbar:SetPos(0, 392)
	
  debug_bar.lfbutton = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.lfbutton:SetImage("ui/silk/bug.png")
	debug_bar.lfbutton:SetPos(1, 1)
  debug_bar.lfbutton:SetText("")
	debug_bar.lfbutton:SizeToImage()
  debug_bar.lfbutton.OnClick = function(object, x, y)
		local debug = loveframes.config["DEBUG"]
		loveframes.config["DEBUG"] = not debug
	end
  
  debug_bar.console_button = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.console_button:SetImage("ui/silk/application_xp_terminal.png")
	debug_bar.console_button:SetPos(18, 1)
  debug_bar.console_button:SetText("")
	debug_bar.console_button:SizeToImage()
  debug_bar.console_button.OnClick = function(object, x, y)
		debug_bar.ToggleConsole()
	end
  
  debug_bar.clear_button = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.clear_button:SetImage("ui/silk/page_white.png")
	debug_bar.clear_button:SetPos(36, 1)
  debug_bar.clear_button:SetText("")
	debug_bar.clear_button:SizeToImage()
  debug_bar.clear_button.OnClick = function(object, x, y)
		debug_bar.console_log:SetText("console cleared")
	end
  
  --[[debug_bar.connect_button = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.connect_button:SetImage("ui/silk/connect.png")
	debug_bar.connect_button:SetPos(54, 1)
  debug_bar.connect_button:SetText("")
	debug_bar.connect_button:SizeToImage()
  debug_bar.connect_button.OnClick = function(object, x, y)
		connect_panel.ToggleVisible()
	end
  
  debug_bar.globals_button = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.globals_button:SetImage("ui/silk/controller.png")
	debug_bar.globals_button:SetPos(72, 1)
  debug_bar.globals_button:SetText("")
	debug_bar.globals_button:SizeToImage()
  debug_bar.globals_button.OnClick = function(object, x, y)
		globals_viewer.ToggleVisible()
	end]]
  
  --[[debug_bar.video_settings = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.video_settings:SetImage("ui/silk/computer_edit.png")
	debug_bar.video_settings:SetPos(72, 1)
  debug_bar.video_settings:SetText("")
	debug_bar.video_settings:SizeToImage()
  debug_bar.video_settings.OnClick = function(object, x, y)
		video_settings.ToggleVisible()
	end]]
  
  debug_bar.exit = loveframes.Create("imagebutton", debug_bar.toolbar)
	debug_bar.exit:SetImage("ui/silk/cross.png")
	debug_bar.exit:SetPos(love.window.getWidth()-17, 1)
  debug_bar.exit:SetText("")
	debug_bar.exit:SizeToImage()
  debug_bar.exit.OnClick = function(object, x, y)
		love.event.quit()
	end
end

function debug_bar.ToggleConsole()
  local height = love.graphics.getHeight()
  local panelheight = debug_bar.debug_panel:GetHeight() -- -18 else not
  if debug_bar.toggle then
	any_frames_visible = true  
    tween(0.10, debug_bar.debug_panel, {y = (0)})
    debug_bar.console_input:SetFocus(true)
  else
	any_frames_visible = false  
    tween(0.10, debug_bar.debug_panel, {y = (0 - panelheight)})
  end
  local textos = debug_bar.console_input:GetText()
  if textos:sub(-1) == "`" then
    debug_bar.console_input:SetText(textos:sub(1, -2))
  end
  debug_bar.toggle = not debug_bar.toggle
end