local player = require("player")
local mq = require("semaq")
local game = require("games.ddz")

local _M = {}

local mt = { __index = _M }

function _M.new()
    local obj = { q = mq.new, game = game.new(), players = {} }
    for i = i, game.PLAYER_NUM do
        table.insert(players, {uid = 0})
    end

    return setmetatable(obj, mt)
end

function _M:join(uid)
    -- TODO: 用户余额判断，是否符合游戏最低准入

    for seatno, player in ipairs(self.players) do
        if player.uid == uid then
            return true, self.q, self.players[seatno].q
        end
    end
    
    for seatno, player in ipairs(self.players) do
        if player.uid == 0 then
            self.players[seatno].uid = uid
            self.players[seatno].q = mq.new()
            game.join(seatno)
            return true, self.q, self.players[seatno].q
        end
    end

    return false
end

function _M:play(uid, hand)
    for seatno, player in ipairs(self.players) do
        if player.uid == uid then
            self.q:push({seatno = seatno, hand = hand})
        end
    end
end

function _M:main()
    local timeout = 3

    while true do
        local ok, _ = self.q:wait(timeout)
        if ok then
            local hands = self.q:flush()
            for _, hand in ipairs(hands) do
                local outputs

                outputs, timeout = self.game:play(hand)
                for i, output in ipairs(outputs) do
                    self.players[i].q:push(output)
                end
            end
        end
    end
end

