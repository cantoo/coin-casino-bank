--local game = require("game.ddz")

--ngx.timer.at(0, game.main)

ngx.timer.at(30, function ()
	local game = require("game.ddz")
	game.main()
end)
