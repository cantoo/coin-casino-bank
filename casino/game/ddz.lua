local mq = require("mq.memory")

local _M = {}

local hands = mq:new()
local players = {}

function _M.join()
	local player = {mq = mq:new()}
	table.insert(players, player)
	return player
end

function _M.play(hand)
	hands:push(hand)
	--table.insert(hands, hand)
end

function _M.main()
	while true
	do
		--for _, hand in ipairs(hands:get(0) or {}) do
		--	for _, player in ipairs(players) do 
		--		player.mq:push(hand)
		--	end
		--end

		--hands:clear()
		ngx.sleep(1)
	end
end


return _M
