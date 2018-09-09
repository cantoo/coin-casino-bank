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
	hands:push(hand)
end

function _M.main()
	while true
	do
		local newhands = hands:get(1) or {}
		for _, hand in ipairs(newhands) do
			for _, player in ipairs(players) do 
				player:push(hand)
			end
		end

		hands:clear()
	end
end


return _M
