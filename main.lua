local ipt = require("ipt")
local _wolf = require("ents.wolf")
local _pig = require("ents.pig")
local _wall = require("ents.wall")
local _camera = require("ents.camera")

function love.load()
	entities = {}

	plr = _wolf.new()
	plr.x = 100
	plr.y = 100
	plr:setWorld(entities)
	entities[1] = plr

	camera = _camera.new()
	camera:setFocus(plr)
	entities[8] = camera

	pig1 = _pig.new()
	pig1.x=200
	pig1.y=200
	pig1:setWorld(entities)
	entities[2] = pig1
	pig2 = _pig.new()
	pig2.x=-200
	pig2.y=-100
	pig2:setWorld(entities)
	entities[3] = pig2

	wall_left=_wall.new(-500,-500,30,1000)
	wall_right=_wall.new(500,-500,30,1030)
	wall_top=_wall.new(-500, -500, 1000, 30)
	wall_bottom=_wall.new(-500, 500, 1030, 30)
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
	entities[4] = wall_left
	entities[5] = wall_right
	entities[6] = wall_top 
	entities[7] = wall_bottom
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

function love.update(dt)
	--movement
	plr.mx = ((ipt["left"] and -1) or 0) + ((ipt["right"] and 1) or 0)
	plr.my = ((ipt["up"] and -1) or 0) + ((ipt["down"] and 1) or 0)

	--velocity
	plr.dx = plr.mx*500
	plr.dy = plr.my*500

	for k,ent in ipairs(entities) do
		ent:update(dt)
	end
end

function love.draw()
	love.graphics.clear(0,0,0,0)
	for k,ent in ipairs(entities) do
		ent:draw(camera)
	end
end