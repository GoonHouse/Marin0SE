function alert(level, message)
	if table.contains(alert_show_types, level) then
		error(message, 0)
	end
end