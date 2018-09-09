local cjson = require("cjson.safe")
local semaphore = require("ngx.semaphore")
local mq = require("mq.memory")

local _M = {}

local hands = mq:new()
local players = {}
local fck = 5

function _M.chgfck()
	fck = 6
end

function _M.getfck()
	return fck
end

function _M.join()
	local player = mq:new()
	table.insert(players, player)
	return player
end

function _M.play(hand)
	hands:push(hand)
	--table.insert(hands, hand)
	ngx.log(ngx.DEBUG, "play qqq=", cjson.encode(hands.qqq))
	ngx.log(ngx.DEBUG, "play count=", hands.sema:count())
end

function _M.main()
	while true
	do
		ngx.log(ngx.DEBUG, "fck=", fck)
		ngx.log(ngx.DEBUG, "main qqq=", cjson.encode(hands.qqq))
		ngx.log(ngx.DEBUG, "main count=", hands.sema:count())
		local newhands = hands:get(1) or {}
		ngx.log(ngx.DEBUG, "newhands=", cjson.encode(newhands))
		for _, hand in ipairs(newhands) do
			ngx.log(ngx.DEBUG, "get hand ", hand)
			for _, player in ipairs(players) do 
				player:push(hand)
			end
		end

		hands:clear()
		--ngx.sleep(1)
	end
end


return _M
