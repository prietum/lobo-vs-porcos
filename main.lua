local ent = require("ent")
local ipt = require("ipt")

function love.load()
	plr = ent.new()
	plr.x = 100
	plr.y = 100
end

function love.keyreleased(key)
	ipt.update(key,false)
end

function love.keypressed(key)
	ipt.update(key,true)

	if key == "escape" then
		love.event.quit()
	end
end

function love.update()
	--movement
	plr.mx = ((ipt["left"] and -1) or 0) + ((ipt["right"] and 1) or 0)
	plr.my = ((ipt["up"] and -1) or 0) + ((ipt["down"] and 1) or 0)

	--velocity
	plr.dx = plr.mx
	plr.dy = plr.my

	--position
	plr.x = plr.x + plr.dx
	plr.y = plr.y + plr.dy
end

function love.draw()
	love.graphics.clear(0,0,0,0)
	love.graphics.circle("fill", plr.x, plr.y, 30)
end