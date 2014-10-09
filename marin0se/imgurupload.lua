-- WHOO BOY THANK THE LORDY FOR SSL FROM http://love2d.org/forums/viewtopic.php?f=5&t=76728
require("libs.ssl")
require("libs.https")
local JSON = require("JSON")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local CLIENT_ID = "4ce94df6f78813c" --dedicated to uploading images of crashes/misbehaviors in this game

function upload_imagedata(oname, imagedata)
	local outname = oname or "temp.png"
	imagedata:encode(outname)
	local idata, isize = love.filesystem.read(outname)
	local t = {}
	local reqbody = idata
	https.request({
		url = "https://api.imgur.com/3/image",
		sink = ltn12.sink.table(t),
		source = ltn12.source.string(reqbody),
		method = "POST",
		headers = {
			["Authorization"] = "Client-ID "..CLIENT_ID,
			["content-length"] = string.len(reqbody),
			["content-type"] = "multipart/form-data",
		},
	})
	return JSON:decode(table.concat(t))
end
