local cjson = require("cjson.safe")
local semaphore = require("ngx.semaphore")
local mq = require("mq.memory")

local _M = {}

local hands = mq:new()
local players = {}

function _M.join()
	local player = mq:new()
	table.insert(players, player)
	return player
end

function _M.play(hand)
	ngx.log(ngx.DEBUG, "play hand=", hand)
	ngx.log(ngx.DEBUG, "qqq=", cjson.encode(hands.qqq))
	hands:push(hand)
	--table.insert(hands, hand)
end

function _M.main()
	while true
	do
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
