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

function _M:wait(timeout)
	return self.sema:wait(timeout)
end

function _M:get(seq)
	local out = {}
	if seq > #self.q then
		seq = 1
	end

	for i = seq, #self.q do
		table.insert(out, self.q[i])
		seq = seq + 1
	end 

	return out, seq
end

function _M:flush()
	local q = self.q
	self.q = {}
	return q
end

return _M
