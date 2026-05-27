local ipt = require("ipt")
local _wolf = require("ents.wolf")
local _pig = require("ents.pig")
local _wall = require("ents.wall")
local _camera = require("ents.camera")
local _hitbox = require("ents.hitbox")
local _world = require("ents.world")

--local healthbar = require("ui.healthbar")
--local menu = require("ui.menu")
--local minimap = require("ui.minimap")
--local enemy_healthbars = require("ui.enm_healthbars")

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
	for _, other_pig in pairs(world:getEntities()) do
		if other_pig.class == "pig" and other_pig ~= pig then
			world:setNoCollide(pig, other_pig)
		end
	end
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

function love.handlers.entHit(hitted_id, hitbox_id)
	hitted = world:getEntity(hitted_id)
	hitbox = world:getEntity(hitbox_id)

	if hitted.class == "pig" and hitted.state ~= "stun" then
		hitted.state = "stun"
		hitted.stun_t = 0.2
		hitted.dx = hitbox.usr_data[1]*900
		hitted.dy = hitbox.usr_data[2]*900
		hitted.hp = math.max(hitted.hp - 34, 0)
	end
end

function love.handlers.queryHitbox(x,y,w,h,caster,usr_data)
	hitbox = _hitbox.new()
	hitbox.x = x
	hitbox.y = y
	hitbox.width = w
	hitbox.height = h
	hitbox.caster = caster
	hitbox.usr_data = usr_data

	world:addEntity(hitbox)
	hitbox:queryOnce()
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

--lembrete
--		>	passe entidades pelos eventos como ID. elas não são passadas por referência, aparentemente.
--			ent.id ao invés de ent

local b = 1
function love.update(dt)
	--movement
	nmx = ((ipt["left"] and -1) or 0) + ((ipt["right"] and 1) or 0)
	nmy = ((ipt["up"] and -1) or 0) + ((ipt["down"] and 1) or 0)
	plr:setMove(nmx, nmy)

	b = b - dt
	if b<=0 then
		b = b + 10
		local tab = {math.random(1,100)}
		love.event.push("spawnEnemy")
	end

	if ipt["atk1"] then
		plr:attack()
	end

	if ipt["atk2"] then
		world:printAllEntities()
	end

	world:updateAll(dt)
end

function love.draw()
	love.graphics.clear(0,0,0,0)
	for k,ent in pairs(world:getEntities()) do
		--print("drawing ent ",k, ent)
		ent:draw(cam)
	end
end