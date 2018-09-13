-- simple chat with redis
local server = require("resty.websocket.server")
local cjson = require("cjson.safe")
local room = require("room")

--获取聊天室id
local len = string.len('/wb/')
local uid = tonumber(string.sub(uri,len+1,-1))

local wb, err = server:new{
  timeout = 20000,
  max_payload_len = 4096
}

if not wb then
  ngx.log(ngx.ERR, "failed to new websocket: ", err)
  return ngx.exit(444)
end

-- TODO: 客户端必须先表明身份，并且登录态验证通过
-- TODO: 如果uri中有tid，则先考虑comeback

local desk = room:sit()
if desk then
    return ngx.exit(444)
end

local function push()
    local seq = 0

    while true do
        local res = desk:wait(uid)
        for _, output in ipairs(res) do
            local bytes, err = wb:send_text(tostring(output))
            if not bytes then
                ngx.log(ngx.ERR, "failed to send text: ", err)
                return ngx.exit(444)
            end

            seq = seq + 1
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
        desk:play(data)
    end
end

wb:send_close()
ngx.thread.wait(co)