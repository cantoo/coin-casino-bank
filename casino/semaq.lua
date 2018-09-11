local cjson = require("cjson.safe")
local semaphore = require("ngx.semaphore")

local _M = {}

local mt = { __index = _M }

function _M.new() 
	return setmetatable({
		q = {},
		sema = semaphore.new()}, mt)
end

function _M:push(elem)
	table.insert(self.q, elem)
	self.sema:post(1)
end

function _M:get(seq)
	local ok, err = self.sema:wait(3)
	if not ok then
		return nil
	end

	local out = {}
	for i = seq, #self.q do
		table.insert(out, self.q[i])
	end 

	return out
end

function _M:clear()
	self.q = {}
end

return _M
