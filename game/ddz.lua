local mq = require("mq.memory")

local _M = {
	hands = {}
}

local players = {}

function _M:join()
	local player = {mq = mq:new()}
	table.insert(players, player)
	return player
end

function _M:play(hand)
	table.insert(_M.hands, hand)
end

function _M:main()
	while true
	do
		for _, hand in ipairs(hands) do
			for _, player in ipairs(players) do 
				player.mq:push(hand)
			end
		end

		_M.hands = {}
		ngx.sleep(0)
	end
end


return _M
