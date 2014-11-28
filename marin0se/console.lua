function console_parse(text)
  text = text or ""
  print("> "..text)
  _, ret0 = loadstring(text)
  if type(_) == 'nil' then
    _, ret1 = loadstring("return "..text)
  end
  if type(_) == 'function' then
    print(_())
  end
  print(ret1)
end

cprint = print
print = function(...)
  local text = ""
  for k,v in pairs({...}) do
    text = text .. tostring(v) .. "\t"
  end
  if text ~= "" then
    cprint(text)
    local console = debug_bar.console_log:GetLines()
    --local log_lines = debug_bar.console_log:GetLines()
    --console = console:gsub(" \n ", "\n")
    
    -- @TODO: #7
    -- table.insert(console, {color = debug_bar.console_log:GetDefaultColor()})
    -- table.insert(console, message)
    if type(text) == 'table' or type(text) == 'function' then
      text = inspect(text)
    end
    if type(text) ~= 'string' then
      text = tostring(text)
    end
    -- Enforce console history limit.
    if game.console.history_limit ~= -1 then
      local diff = (text:countlines() + #console) - game.console.history_limit 
      if diff > 0 then
        for i=1,diff do
          table.remove(console, 1)
        end
      end
    end
    
    debug_bar.console_log:SetText(table.concat(console, "\n").."\n"..text)
    --debug_bar.console_log:SetText(console.."\n"..text)
  end
end

--[[function dprint(text, context)
  local ftext = debug_bar.console_log:GetFormattedText()
  local default = debug_bar.console_log:GetDefaultColor()
  local con_text = {} -- haha
  if context == 'warning' then
    con_text = {color = {255, 220, 0, 255}}
  elseif context == 'error' then
    con_text = {color = {255, 65, 54, 255}}
  else
    con_text = {color = default}
  end
  -- We're going to do something massively counter-intuitive.
  -- Flash the text to get it parsed by loveframes then get it back.
  local ttext = {}
  table.insert(ttext, con_text)
  table.insert(ttext, text)
  table.insert(ttext, default)
  debug_bar.console_log:SetText(ttext)
  local gtext = debug_bar.console_log:GetFormattedText()
  for k, v in ipairs(gtext) do
    table.insert(ftext, v)
  end
  debug_bar.console_log:SetText(ftext)
end]]