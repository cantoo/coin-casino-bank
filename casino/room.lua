local desk = require("desk")

local _M = {}

local desks = {}

function _M.comeback(uid, tid)
    for _, desk in ipairs(desks) do
        if desk.tid ==  tid and desk:comeback(uid) then
            return desk
        end
    end

    return nil
end

function _M.sit(uid)
    for _, desk in ipairs(desks) do
        if desk.join(uid) then
            return desk
        end
    end

    return nil
end

function _M.main()
    for i = 1, 1 do
        table.insert(desks, desk.new())
        ngx.timer.at(0, desk.main)
    end
end

return _M

