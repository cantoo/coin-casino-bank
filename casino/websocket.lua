-- simple chat with redis
local server = require("resty.websocket.server")
local cjson = require("cjson.safe")
local room = require("room")

--获取聊天室id
local len = string.len('/wb/')
local uid = tonumber(string.sub(ngx.var.uri,len+1,-1))
ngx.log(ngx.DEBUG, "uri=", ngx.var.uri, ",uid=", uid)

local wb, err = server:new{
  timeout = 45000,
  max_payload_len = 4096
}

if not wb then
  ngx.log(ngx.ERR, "failed to new websocket: ", err)
  return ngx.exit(444)
end

-- TODO: 客户端必须先表明身份，并且登录态验证通过
-- TODO: 如果uri中有tid，则先考虑comeback

local desk = room.sit(uid)
if not desk then
    return ngx.exit(444)
end

local function push()
    local seq = 0

    while true do
        local res
	res, seq = desk:wait(uid, seq)
	if not res then
		ngx.log(ngx.DEBUG, "desk wait fail,tid=", desk.tid, ",uid=", uid)
		return ngx.exit(444)
	end

        for _, output in ipairs(res) do
            local bytes, err = wb:send_text(tostring(output))
            if not bytes then
                ngx.log(ngx.ERR, "failed to send text: ", err)
                return ngx.exit(444)
            end
        end
    end
end


local co = ngx.thread.spawn(push)

--main loop
while true do   
    -- 获取数据
    local data, typ, err = wb:recv_frame()
    
    while err == "again" do
        local fragment, _, err = wb:recv_frame()
        data = data .. fragment
    end

    if not data then
        if not string.find(err, "timeout", 1, true) then
            ngx.log(ngx.ERR, "recv_frame error", err)
            return ngx.exit(444)
        end
    end

    if typ == "close" then
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "send_pong error", err)
            return
        end
    elseif typ == "pong" then
        --ngx.log(ngx.DEBUG, "client ponged")
    elseif typ == "text" then
        desk:play(uid, data)
    end
end

wb:send_close()
ngx.thread.wait(co)
