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
	ngx.log(ngx.DEBUG, "push count=", self.sema:count())
end

function _M:get(seq)
	local ok, err = self.sema:wait(3)
	ngx.log(ngx.DEBUG, "ok=", ok, ",err=", err, ",count=", self.sema:count())
	if not ok then
		return nil
	end

	local out = {}
	ngx.log(ngx.DEBUG, "get qqq=", cjson.encode(self.qqq))
	for i = seq, #self.qqq do
		table.insert(out, self.qqq[i])
	end 

	return out
end

function _M:clear()
	self.qqq = {}
end

return _M
