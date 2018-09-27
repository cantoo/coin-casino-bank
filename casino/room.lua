local desk = require("desk")
local cjson = require("cjson.safe")

local _M = {}

local desks = {}

function _M.join(tid, player)
    for _, d in ipairs(desks) do
        if d.tid == tid and d:join(player) then
            return d
        end
    end

    return nil
end

function _M.main()
    for i = 1, 1 do
	    -- TODO: get tid from seq server
	    local d = desk.new(i)
        table.insert(desks, d)
        ngx.timer.at(0, function () d:main() end)
    end
end

return _M

