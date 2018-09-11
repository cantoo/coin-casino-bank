local player = require("player")
local mq = require("semaq")

local _M = {}

local mt = { __index = _M }

function _M.new()
    return setmetatable({
        q = mq.new(),
        players = {
            {
                uid = 0,
                status = 0,
            },{
                uid = 0,
                status = 0,
            },{
                uid = 0,
                status = 0,
            }
        }
    })
end

function _M:join(uid, playerq)
    for _, player in ipairs(self.players) do
        if player.uid == 0 then
            player.uid = uid
            player.playerq = playerq
            return self.q
        end
    end

    return nil
end

function _M:play(hand)
    self.q:push(hand)
end