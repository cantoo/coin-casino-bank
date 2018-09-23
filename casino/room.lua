local desk = require("desk")
local cjson = require("cjson.safe")

local _M = {}

local desks = {}

function _M.sit(tid, player)
    for _, d in ipairs(desks) do
	ngx.log(ngx.DEBUG, "d.tid=", d.tid, ",tid", tid)
        if d.tid == tid and d:sit(player) then
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

