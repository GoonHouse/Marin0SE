net={}
net.listenTable={}
net.udpSocket=nil

function net.assign(mode)
	if mode=="client" then
		net.udpSocket = udp
	elseif mode=="server" then
		net.udpSocket = server_udp
	end
end

function net.queue(chan, data)
	table.insert(networksendqueue, von.serialize({chan=chan, data=data, client=networkclientnumber}))
end

function net.send(chan, data)
	net.udpSocket:send(von.serialize({chan=chan,data=data,client=networkclientnumber}))
end

function net.sendto(chan, data, ip, port)
	net.udpSocket:sendto(von.serialize({chan=chan,data=data,client=networkclientnumber}), ip, port)
end

function net.pump()
	for k,v in ipairs(networksendqueue) do
		net.udpSocket:send(v)
		networksendqueue[k]=nil
	end
end

function net.receive()
	local data, msg = net.udpSocket:receive()
	if data==nil then return nil, nil end
	data = von.deserialize(data)
	--@TODO: use the ip and port to bind to a particular address
	return data.chan, data.data
end

function net.receivefrom()
	local data, ip, port = net.udpSocket:receivefrom()
	--@TODO: In the odd circumstance we are sent no data from somebody?
	if data==nil then return nil, nil, ip, port end
	data = von.deserialize(data)
	--@TODO: use the ip and port to bind to a particular address
	return data.chan, data.data, ip, port
end



---- SERVER related things
serve = {} --using serve instead of server because it probably already exists in the mess of globals
serve.peers = {}
--[[
	{
		
	}
]]
