local player = require("player")
local mq = require("semaq")
local game = require("games.ddz")

local _M = {}

local mt = { __index = _M }

function _M.new(tid)
    local obj = { 
        tid = tid,
        token = "",
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

function _M:join(uid, tid)
    -- 重连加入
    if type(tid) == "number" and tid > 0 then
        if status == 0 then
            return false
        end

        for seatno, player in ipairs(self.players) do
            if player.uid == uid then
                return true, self.q, self.players[seatno].q
            end
        end

        return false
    end

    -- 新加入
    -- TODO: 用户余额判断，是否符合游戏最低准入
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
                local res = self.game:play(hand)
                for i, output in ipairs(res.output) do
                    local token = nil
                    for _, next in ipairs(res.nexts) do
                        if next == i then
                            -- 
                            token = ""
                    end
                    self.players[i].q:push(output)
                end
            end
        end
    end
end

