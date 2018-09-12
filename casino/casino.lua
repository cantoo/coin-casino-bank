local game = require("game")

local _M = {}

local games = {}

function _M.join(uid)
    for _, g in ipairs(games) do
        for _, player in ipairs(g.players) do
            if player.uid == uid then
                return g.join(uid)
            end
        end
    end

    
    for _, g in ipairs(games) do
        ok, gameq, playerq = g.join(uid)
        if ok then
            return ok, gameq, playerq
        end
    end

    return false
end

function _M.main()
    for i = 1, 1000 do
        table.insert(games, game.new())
        ngx.timer.at(0, game.main)
    end
end

return _M

