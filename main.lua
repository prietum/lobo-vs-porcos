local ipt = require("ipt")
local _wolf = require("ents.wolf")
local _pig = require("ents.pig")
local _wall = require("ents.wall")
local _camera = require("ents.camera")

function newPlayer()
	local plr = _wolf.new()
	plr.x = 0
	plr.y = 0
	plr:setWorld(entities)
	entities[#entities+1] = plr
	return plr
end

function newEnemy()
	local pig = _pig.new()
	local spwang = math.random(0,628)/100 --todo
	pig.x=-100
	pig.y= 100
	pig:setWorld(entities)
	entities[#entities+1] = pig
end

function newCamera()
	local cam = _camera.new()
	entities[#entities+1] = cam
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
	wall_left:setWorld(entities)
	wall_right:setWorld(entities)
	wall_top:setWorld(entities)
	wall_bottom:setWorld(entities)
	wall_left:setNonCollide({wall_top, wall_right, wall_bottom})
	wall_right:setNonCollide({wall_top, wall_left, wall_bottom})
	wall_top:setNonCollide({wall_left, wall_right, wall_bottom})
	wall_bottom:setNonCollide({wall_top, wall_right, wall_left})
	entities[#entities+1] = wall_left
	entities[#entities+1] = wall_right
	entities[#entities+1] = wall_top 
	entities[#entities+1] = wall_bottom
end

function love.load()
	entities = {}

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

	--Update entity behavior.
	for k,ent in pairs(entities) do
		ent:updateBehavior(dt)
	end

	--Update entity physics.
	for k,ent in pairs(entities) do
		ent:updatePhysics(dt)
	end

	cam:updatePhysics(dt) --Atualiza de novo para que não fique travando
end

function love.draw()
	love.graphics.clear(0,0,0,0)
	for k,ent in pairs(entities) do
		ent:draw(cam)
	end
end