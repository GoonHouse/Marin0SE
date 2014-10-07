net={}
net.listenTable={}
function net.queue(chan, data)
	table.insert(networksendqueue, von.serialize({chan=chan, data=data, client=networkclientnumber}))
end

function net.send(chan, data)
	udp:send(von.serialize({chan=chan,data=data,client=networkclientnumber}))
end

function net.pump()
	for k,v in ipairs(networksendqueue) do
		udp:send(v)
		networksendqueue[k]=nil
	end
end

function net.receive()
	local data, msg = udp:receive()
	--@TODO: Find what msg could be and extra bits of info.
	if data==nil then return nil, nil end
	data = von.deserialize(data)
	return data.chan, data.data
end