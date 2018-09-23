local mq = require("semaq")
local game = require("games.ddz")
local cjson = require("cjson.safe")

local _M = {}

local mt = { __index = _M }

function _M.new(tid)
    local obj = { 
        tid = tid,
        q = mq.new(), 
        game = game.new(), 
        status = 0,
        players = {} 
    }

    for i = 1, game.SEAT_NUM do
        table.insert(obj.players, {
            uid = 0,
            seq = 1,
            q = nil,
        })
    end

    return setmetatable(obj, mt)
end

function _M:update(res)
    if type(res) ~= "table" then
        return 
    end

    if type(res.outputs) == "table" then
        for i, output in ipairs(res.outputs) do
            if self.players[i].uid ~= 0 then
                if type(output) == "string" and output ~= "" then
                    self.players[i].q:push(tostring(output))
                end

                if type(output) == "table" then
                    self.players[i].q:push(cjson.encode(output))
                end
            end
        end
    end 

    return res.timeout
end

-- TODO: 新加入，入场金合法性判断
-- TODO: 防作弊，相邻IP，玩家间互相屏蔽等

function _M:sit(p)
    for seatno, player in ipairs(self.players) do
        if p.uid == player.uid then
		ngx.log(ngx.DEBUG, "come back,uid=", p.uid)
            -- 重放
            player.seq = 1
            return seatno
        end
    end

    local seatno, res = self.game:join()
	ngx.log(ngx.DEBUG, "game players=", cjson.encode(self.game.players))
    if seatno then
        local player = self.players[seatno]
        player.uid = p.uid
        player.seq = 1
        player.q = mq.new()
	ngx.log(ngx.DEBUG, "new player,uid=", p.uid)
        self:update(res)
        return seatno
    end

    -- for seatno, player in ipairs(self.players) do
    --     if player.uid == 0 then
    --         player.uid = uid
    --         player.q = mq.new()
    --         return self.game:sit(seatno)
    --     end
    -- end

    return nil
end

function _M:wait(uid) 
    for _, player in ipairs(self.players) do
        if player.uid == uid then
            local ok, _ = player.q:wait(3)
            if ok then
                local res = player.q:get(player.seq)
                player.seq = player.seq + #res
                return res
            end

            return {}
        end
    end

    return nil
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
                timeout = self:update(self.game:play(hand.seatno, hand.hand))
            end
        end
    end
end

return _M
