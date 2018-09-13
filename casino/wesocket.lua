-- simple chat with redis
local server = require("resty.websocket.server")
local cjson = require("cjson.safe")
local game = require("game.ddz")

-- --获取聊天室id
-- local len = string.len('/s/')
-- local channel_id = string.sub(uri,len+1,-1)

-- local channel_name = "chat_" .. tostring(channel_id)

local wb, err = server:new{
  timeout = 10000,
  max_payload_len = 65535
}

if not wb then
  ngx.log(ngx.ERR, "failed to new websocket: ", err)
  return ngx.exit(444)
end

local mq = game:join()

local function push()
    while true do
        local res = mq:wait()
        if type(res) == "table" then
            for _, msg in ipairs(res) do
                local text = msg
                if type(text) == "table" then
                    text = cjson.encode(text)
                end

                local bytes, err = wb:send_text(tostring(text))
                if not bytes then
                    ngx.log(ngx.ERR, "failed to send text: ", err)
                    return ngx.exit(444)
                end
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
        game:play(data)
    end
end

wb:send_close()
ngx.thread.wait(co)