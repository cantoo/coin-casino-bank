local cjson = require("cjson.safe")
local semaphore = require("ngx.semaphore")

local _M = {}

local mt = { __index = _M }

function _M:new() 
	return setmetatable({
		qqq = {},
		sema = semaphore.new()}, mt)
end

function _M:push(elem)
	table.insert(self.qqq, elem)
	self.sema:post(1)
end

function _M:get(seq)
	local ok, err = self.sema:wait(3)
	if not ok then
		return nil
	end

	local out = {}
	for i = seq, #self.qqq do
		table.insert(out, self.qqq[i])
	end 

	return out
end

function _M:clear()
	self.qqq = {}
end

return _M
