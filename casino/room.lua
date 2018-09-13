local desk = require("desk")

local _M = {}

local desks = {}

function _M.join(uid)
    for _, d in ipairs(desks) do
        if d:available(uid) then
            return d:join(uid)
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

