-- --local game = require("game.ddz")

-- --ngx.timer.at(0, game.main)

-- ngx.timer.at(30, function ()
-- 	local game = require("game.ddz")
-- 	game.main()
-- end)


-- -- 游戏主逻辑
-- local mq = require("semaq")
-- local game = require("game")

-- local games = {}

-- local function start(game)
-- end

-- for i = 1, 1 do
-- 	table.insert(games, game)
-- 	ngx.timer.at(0, start, game)
-- end

local casino = require("casino")
casino.main()

