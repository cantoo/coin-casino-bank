local _M = {}

local games = {}

function _M.join(uid, playerq)
    for _, game in ipairs(games) do
        if game:join(uid, playerq) then
            return game
        end
    end

    return nil
end

function _M.main(game)
end

