
local _M = {
	hands = {}
}

local players = {}

local function play(hand)
	for _, player in ipairs(players) do 
		table.insert(player, hand)
	end
end

function _M:join()
	local player = {}
	table.insert(players, player)
	return player
end

function _M:main()
	while true
	do
		for _, hand in ipairs(hands) do
			play(hand)
		end

		_M.hands = {}
		ngx.sleep(0)
	end
end


return _M
