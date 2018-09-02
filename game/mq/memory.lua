local semaphore = require("ngx.semaphore")

local _M = {}

local mt = { __index = _M }

function _M:new() 
	return setmetatable({
		queue = {}
		sema = semaphore:new()}, mt)
end

function _M:push(elem)
	table.insert(self.queue, elem)
	self.sema.post(1)
end

function _M:get(seq)
	self.sema.wait()

	local out = {}
	for i = seq, #self.queue do
		table.insert(out, self.queue[i])
	end 

	return out
end

function _M:clear()
	self.queue = {}
end
