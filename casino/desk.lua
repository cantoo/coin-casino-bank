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
        for seatno, output in ipairs(res.outputs) do
            if self.players[seatno].q then
                if type(output) == "string" and output ~= "" then
                    self.players[seatno].q:push(tostring(output))
                end

                if type(output) == "table" then
                    self.players[seatno].q:push(cjson.encode(output))
                end
            end
        end
    end 
end

-- TODO: 新加入，入场金合法性判断
-- TODO: 防作弊，相邻IP，玩家间互相屏蔽等

function _M:join(p)
    -- local seatno = self.game:comeback(p)
    -- if seatno then
    --     -- 重放
    --     local player = self.players[seatno]
    --     player.seq = 1
    --     return seatno
    -- end
    
    -- for seatno, player in ipairs(self.players) do
    --     if self.game.players[seatno].uid == p.uid then
	-- 	ngx.log(ngx.DEBUG, "come back,uid=", p.uid)
    --     end
    -- end

    local seatno, res = self.game:join(p.uid)
    if seatno then
        local player = self.players[seatno]
        player.seq = 1
        player.q = mq.new()
        self:update(res)
        return seatno
    end

    return nil
end

function _M:wait(uid) 
    local seatno = self.game:get_seatno(uid)
    if seatno then
        local player = self.players[seatno]
        local ok, _ = player.q:wait(10)
        if ok then
            local res = player.q:get(player.seq)
            player.seq = player.seq + #res
            return res
        end

        return {}
    end

    return nil
end

function _M:action(uid, hand)
    local seatno = self.game:get_seatno(uid)
    if seatno then
        self.q:push({seatno = seatno, hand = hand})
    end
end

function _M:main()
    while true do
        local ok, err = self.q:wait(self.game:timeout() + 4)
        if err == "timeout" then
            self:update(self.game:expire())
        end

        if ok then
            local hands = self.q:flush()
            for _, hand in ipairs(hands) do
                self:update(self.game:action(hand.seatno, hand.hand))
            end
        end
    end
end

return _M
