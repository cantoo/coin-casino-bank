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
	ngx.log(ngx.DEBUG, "push qqq=", cjson.encode(self.qqq))
	self.sema:post(1)
end

function _M:get(seq)
	local ok, _ = self.sema:wait(30)
	if not ok then
		return nil
	end

	local out = {}
	for i = seq, #self.qqq do
		ngx.log(ngx.DEBUG, "get qqq", self.qqq[i])
		table.insert(out, self.qqq[i])
	end 

	return out
end

function _M:clear()
	self.qqq = {}
end

return _M
