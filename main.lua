local ipt = require("ipt")
local _wolf = require("ents.wolf")
local _pig = require("ents.pig")
local _wall = require("ents.wall")
local _camera = require("ents.camera")
local _world = require("ents.world")

function newPlayer()
	local plr = _wolf.new()
	plr.x = 0
	plr.y = 0
	world:setPlayer(plr)
	return plr
end

function newEnemy()
	local pig = _pig.new()
	local spwang = math.random(0,628)/100 --todo
	pig.x=-100
	pig.y= 100
	world:addEntity(pig)
end

function newCamera()
	local cam = _camera.new()
	world:setCamera(cam)
	return cam
end

function newWalls()
	local wall_left=_wall.new(-500,-500,30,1000)
	local wall_right=_wall.new(500,-500,30,1030)
	local wall_top=_wall.new(-500, -500, 1000, 30)
	local wall_bottom=_wall.new(-500, 500, 1030, 30)
	wall_left.name = "Left wall"
	wall_right.name = "Right wall"
	wall_top.name = "Top wall"
	wall_bottom.name = "Bottom wall"

	world:addEntity(wall_left)
	world:addEntity(wall_right)
	world:addEntity(wall_top)
	world:addEntity(wall_bottom)

	world:setNoCollide(wall_left, wall_right)
	world:setNoCollide(wall_left, wall_top)
	world:setNoCollide(wall_left, wall_bottom)
	world:setNoCollide(wall_right, wall_top)
	world:setNoCollide(wall_right, wall_bottom)
	world:setNoCollide(wall_top, wall_bottom)
end

function love.load()
	world = _world.new()

	newWalls()
	cam = newCamera()
	plr = newPlayer()
	cam:setFocus(plr)
end

function love.handlers.spawnEnemy()
	newEnemy()
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

local b = 1
function love.update(dt)
	--movement
	plr.mx = ((ipt["left"] and -1) or 0) + ((ipt["right"] and 1) or 0)
	plr.my = ((ipt["up"] and -1) or 0) + ((ipt["down"] and 1) or 0)

	--velocity
	plr.dx = plr.mx*500
	plr.dy = plr.my*500

	b = b - dt
	if b<=0 then
		b = b + 1
		love.event.push("spawnEnemy")
	end

	world:updateAll(dt)
end

function love.draw()
	love.graphics.clear(0,0,0,0)
	for k,ent in pairs(world:getEntities()) do
		ent:draw(cam)
	end
end