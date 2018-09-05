-- simple chat with redis
local server = require("resty.websocket.server")
local cjson = require("cjson.safe")
local game = require("game.ddz")

-- --获取聊天室id
-- local len = string.len('/s/')
-- local channel_id = string.sub(uri,len+1,-1)

-- local channel_name = "chat_" .. tostring(channel_id)

ngx.log(ngx.DEBUG, "in ws now")
--ngx.print("hello")
--create connection
local wb, err = server:new{
  timeout = 100000,
  max_payload_len = 65535
}

--create success
if not wb then
  ngx.log(ngx.ERR, "failed to new websocket: ", err)
  return ngx.exit(444)
end

local mq = game.join()

local function push()
    local seq = 1
    -- loop : read from redis
    while true do
        local res = mq:get(seq)
	ngx.log(ngx.DEBUG, "client mq get ", cjson.encode(res))
        if type(res) == "table" then
            for _, msg in ipairs(res) do
                local text = msg
                if type(text) == "table" then
                    text = cjson.encode(text)
                end

		ngx.log(ngx.DEBUG, "get text", text)
                local bytes, err = wb:send_text(tostring(text))
                if not bytes then
                    ngx.log(ngx.ERR, "failed to send text: ", err)
                    return ngx.exit(444)
                end

		seq = seq + 1
            end
        end
    end
end


local co = ngx.thread.spawn(push)

--main loop
while true do
    ngx.log(ngx.DEBUG, "in client main loop")
    local data, typ, err = wb:recv_frame()

    -- 如果连接损坏 退出
    if wb.fatal then
        ngx.log(ngx.ERR, "failed to receive frame: ", err)
        return ngx.exit(444)
    end

    if not data then
        local bytes, err = wb:send_ping()
        if not bytes then
          ngx.log(ngx.ERR, "failed to send ping: ", err)
          return ngx.exit(444)
        end
        --ngx.log(ngx.ERR, "send ping: ", data)
    elseif typ == "close" then
        break
    elseif typ == "ping" then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, "failed to send pong: ", err)
            return ngx.exit(444)
        end
    elseif typ == "pong" then
        --ngx.log(ngx.ERR, "client ponged")
    elseif typ == "text" then
        game.play(data)
    end
end

wb:send_close()
ngx.thread.wait(co)
