local ipt = require("ipt")
local _wolf = require("ents.wolf")
local _pig = require("ents.pig")
local _wall = require("ents.wall")
local _camera = require("ents.camera")
local _hitbox = require("ents.hitbox")
local _world = require("ents.world")

local _healthbar = require("ui.healthbar")
local _score = require("ui.score")
local score = 0

local anim8 = require("anim8")
local img = love.graphics.newImage("assets/sprites/bg.png")
img:setFilter("nearest", "nearest")
local grid = anim8.newGrid(16,16,128,128,0,0,0)
local fencegrid = anim8.newGrid(16,32,128,128,0,0,0)

local ost = love.audio.newSource("assets/music/ost.mp3", "stream")
local hitwolf_sfx = love.audio.newSource("assets/music/hit_wolf.mp3", "static")
local hitpig_sfx = love.audio.newSource("assets/music/hit_pig.mp3", "static")

local maptilesize = 16
local maptiles = 64
local maptruesize = maptilesize*maptiles
local randograss={}
for i=1,64 do
	randograss[i] = {
		math.random(1, maptiles), 
		math.random(1, maptiles), 
		anim8.newAnimation(grid(math.random(1,8),math.random(1,2)),100)
	}
end
local fencesprite={
	tl=anim8.newAnimation(fencegrid(1,2),100),
	ml=anim8.newAnimation(fencegrid(1,3),100),
	bl=anim8.newAnimation(fencegrid(1,4),100),
	bm=anim8.newAnimation(fencegrid(2,4),100),
	br=anim8.newAnimation(fencegrid(3,4),100),
	mr=anim8.newAnimation(fencegrid(3,3),100),
	tr=anim8.newAnimation(fencegrid(3,2),100),
	tm=anim8.newAnimation(fencegrid(2,2),100)
}

function newPlayer()
	local plr = _wolf.new()
	plr.x = 0
	plr.y = 0
	world:setPlayer(plr)

	local cam = world:getCamera()
	cam:setFocus(plr)

	return plr
end

function newEnemy()
	local pig = _pig.new()
	local spwang = math.random(0,628)/100 --todo
	pig.x=math.random(-maptilesize*maptiles/3,maptilesize*maptiles/3)
	pig.y=math.random(-maptilesize*maptiles/3,maptilesize*maptiles/3)
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
	m = maptiles*maptilesize/2
	local wall_left=_wall.new(-m,-m,maptilesize,m*2)
	local wall_right=_wall.new(m,-m,maptilesize,m*2+maptilesize)
	local wall_top=_wall.new(-m, -m, m*2, maptilesize)
	local wall_bottom=_wall.new(-m, m, m*2+maptilesize, maptilesize)
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
	love.window.setTitle("Lobo VS Porcos")

	world = _world.new()

	newWalls()
	cam = newCamera()

	ost:setLooping(true)
	ost:play()
end

function love.handlers.entHit(hitted_id, hitbox_id)
	hitted = world:getEntity(hitted_id)
	hitbox = world:getEntity(hitbox_id)
	caster = world:getEntity(hitbox.casterid)

	if not hitted then print("entHit cancelled: no 'hitted'.") return end
	if not hitbox then print("entHit cancelled: no 'hitbox'.") return end
	if not caster then print("entHit cancelled: no 'caster'.") return end

	--print(caster.class, "hitted", hitted.class, "with", hitbox.class)

	--TODO make hitbox userdata hitbox type (wind, atk1, devour)

	if hitted.class == "pig" and hitted.state ~= "stun" then
		--print("wolf hitted pig.")
		if hitbox.usr_data[3] == "atk1" then
			hitpig_sfx:play()
			hitted:damage(25)
			hitted:stun(0.2, {hitbox.usr_data[1], hitbox.usr_data[2]}, 300)
		elseif hitbox.usr_data[3] == "atk2" then
			hitted:damage(4)
			hitted:stun(0.3, {hitbox.usr_data[1], hitbox.usr_data[2]}, 100)
		elseif hitbox.usr_data[3] == "atk3" and caster.atk3_t > 0 then
			hitpig_sfx:play() --TODO substitui por NHAC
			hitted:damage(999999) --mortinho da silva
			caster.atk3_t = 0 --termina o ataque 3 do lobo
			caster.hp = math.min(caster.hp+2, caster.maxhp) --cura o lobo
		end
		
	elseif hitted.class == "wolf" and hitted.state ~= "stun" and hitted.inv_t <= 0 then
		--print(hitted.inv_t)
		--print("pig hitted wolf.")
		hitwolf_sfx:play()

		hitted:damage(1)
		hitted:stun(0.3, {hitbox.usr_data[1], hitbox.usr_data[2]}, 300)
	end
end

function love.handlers.queryHitbox(x,y,w,h,casterid,usr_data)
	hitbox = _hitbox.new()
	hitbox.x = x
	hitbox.y = y
	hitbox.width = w
	hitbox.height = h
	hitbox.casterid = casterid
	hitbox.usr_data = usr_data

	world:addEntity(hitbox)
	hitbox:queryOnce()
end

function love.handlers.spawnEnemy()
	newEnemy()
end

function love.handlers.respawnPlayer()
	newPlayer()
end

function love.handlers.playerDied()
	score = 0
end

function love.handlers.pigDied()
	score = score+1
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
	--world:printAllEntities()
	local plr = world:getPlayer()

	if plr then
		--print(plr, plr.class)
		--movement
		nmx = ((ipt["left"] and -1) or 0) + ((ipt["right"] and 1) or 0)
		nmy = ((ipt["up"] and -1) or 0) + ((ipt["down"] and 1) or 0)
		plr:setMove(nmx, nmy)

		if ipt["atk1"] then
			plr:attack()
		elseif ipt["atk2"] then
			--world:printAllEntities()
			plr:sopra()
		elseif ipt["atk3"] then
			plr:devour()
		end
	else
		love.event.push("respawnPlayer")
	end

	pigslen = 0
	for _, ent in pairs(world:getEntities()) do
		if ent.class == "pig" then
			pigslen = pigslen + 1
		end
	end

	b = b - dt
	if b<=0 and pigslen <= 6 then
		b = b + 2
		local tab = {math.random(1,100)}
		love.event.push("spawnEnemy")
	end

	world:updateAll(dt)
end

function love.draw()
	local offx, offy = cam:getDrawOffset()

	love.graphics.clear(1,1,1,0)
	--draw top walls
	love.graphics.setColor(1,1,1)
	for i=1, maptiles-1 do
		fencesprite.tm:draw(img,offx+i*maptilesize-maptilesize*maptiles/2,offy-maptilesize*maptiles/2)
	end

	--draw grass
	love.graphics.setColor(1,1,1)
	for _,grass in ipairs(randograss) do
		grass[3]:draw(
			img, 
			grass[1]*maptilesize+offx-maptilesize*maptiles/2,
			grass[2]*maptilesize+offy-maptilesize*maptiles/2
		)
	end

	for k,ent in pairs(world:getEntities()) do
		--print("drawing ent ",k, ent)
		ent:draw(cam)
	end

	--draw other walls
	love.graphics.setColor(1,1,1)
	fencesprite.tl:draw(img,offx-maptilesize*maptiles/2,offy-maptilesize*maptiles/2)
	fencesprite.tr:draw(img,offx+maptilesize*maptiles/2,offy-maptilesize*maptiles/2)
	fencesprite.bl:draw(img,offx-maptilesize*maptiles/2,offy+maptilesize*maptiles/2)
	fencesprite.br:draw(img,offx+maptilesize*maptiles/2,offy+maptilesize*maptiles/2)
	for i=1, maptiles/2 - 1 do
		fencesprite.ml:draw(img,offx-maptilesize*maptiles/2,offy+i*maptilesize*2-maptilesize*maptiles/2)
		fencesprite.mr:draw(img,offx+maptilesize*maptiles/2,offy+i*maptilesize*2-maptilesize*maptiles/2)
	end
	for i=1, maptiles-1 do
		fencesprite.bm:draw(img,offx+i*maptilesize-maptilesize*maptiles/2,offy+maptilesize*maptiles/2)
	end

	--draw UI
	if world:getPlayer() then
		_healthbar:draw(world:getPlayer())
		_score:draw(score)
	end
end