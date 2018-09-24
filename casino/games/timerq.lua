local _M = {}

local mt = { __index = _M }

function _M.new()
    return setmetatable({
        min = 0,
        q = {},
    }, mt)
end

function _M:add(timeout, data)
    table.insert(self.q, {
        timeout = timeout,
        data = data,
    })

    if self.min == 0 or self.q[min].timeout > timeout then
        self.min = #self.q
    end

    return self.q[self.min].timeout
end

function _M:expires()
    local m = self.q[self.min]
    local q = {}
    local min = 0

    local ret = {}
    for _, timer in ipaires(self.q) do
        if timer.timeout <= m.timeout then
            table.insert(ret, timer.data)
        else
            table.insert(q, timer)
            if min == 0 or q[min].timeout > timer.timeout then
                min = #q
            end
        end
    end

    self.min = min
    self.q = q
    return self.q[self.min].timeout, ret
end

return _M



