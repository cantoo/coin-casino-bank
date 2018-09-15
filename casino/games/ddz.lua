local cjson = require("cjson.safe")

local _M = {
	PLAYER_NUM = 3
}

local mt = { __index = _M }

function _M.new()
	return setmetatable({}, mt)
end

function _M:sit()
end

function _M:play(seatno, hand)
	return {
		outputs = {hand, hand, hand}
	}
end

return _M
