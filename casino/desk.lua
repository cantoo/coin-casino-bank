local player = require("player")
local mq = require("semaq")
local game = require("games.ddz")

local _M = {}

local mt = { __index = _M }

function _M.new(tid)
    local obj = { 
        tid = tid,
        q = mq.new, 
        game = game.new(), 
        status = 0,
        players = {} 
    }

    for i = i, game.PLAYER_NUM do
        table.insert(players, {
            uid = 0,
        })
    end

    return setmetatable(obj, mt)
end

-- 重连加入
function _M:comeback(uid)
    if status == 0 then
        return false
    end

    for seatno, player in ipairs(self.players) do
        if player.uid == uid then
            return true
        end
    end

    return false
end

function _M:sit(uid)
    -- 新加入
    -- TODO: 用户余额判断，是否符合游戏最低准入
    for seatno, player in ipairs(self.players) do
        if player.uid == 0 then
            self.players[seatno].uid = uid
            self.players[seatno].q = mq.new()
            game.sit(seatno)
            return true
        end
    end

    return false
end

function _M:wait(uid, seq) 
    for _, player in ipairs(self.players) do
        if player.uid == uid then
            local ok, _ = player.q:wait(3)
            if ok then
                return player.q:get(seq)
            end
        end
    end

    return {}
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
                local res = self.game:play(hand.seatno, hand.hand)
                if type(res.outputs) == "table" then
                    for i, output in ipairs(res.outputs) do
                        self.players[i].q:push(output)
                    end
                end
            end
        end
    end
end

