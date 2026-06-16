local _ent = require("ents.ent")
local anim8 = require("anim8")

local _wolf = {}
_wolf.__index = _wolf
setmetatable(_wolf, _ent)

local img = love.graphics.newImage("assets/sprites/lobo.png")
img:setFilter("nearest", "nearest")
local grid = anim8.newGrid(64,64,512,512,0,0,0)

function _wolf.new()
	local new_wolf = _ent.new()

	new_wolf.name = "wolf"
	new_wolf.class = "wolf"

	new_wolf.maxhp=100
	new_wolf.hp=new_wolf.maxhp

	new_wolf.maxpp=100
	new_wolf.pp=new_wolf.maxpp

	new_wolf.mx = 1
	new_wolf.my = 0

	new_wolf.omx = 1
	new_wolf.omy = 0
	new_wolf.oomx =1

	new_wolf.amx = 1
	new_wolf.amy = 0

	new_wolf.width = 30
	new_wolf.height = 30

	--idle, atk1, atk2, atk3, stun
	new_wolf.state = "idle"
	new_wolf.atk1_p = 0
	new_wolf.atk1_pp= 3
	new_wolf.atk1_t = 0
	new_wolf.atk1_tt = 0.3
	new_wolf.atk1_c = 0
	new_wolf.atk1_cc = 0.4

	new_wolf.stun_t = 0
	new_wolf.stun_p = 0
	new_wolf.stun_pp= 3

	new_wolf.anim = {
		idle=anim8.newAnimation(grid("1-8",1),0.1),
		walk=anim8.newAnimation(grid("1-8",2),0.1),
		atk10=anim8.newAnimation(grid("1-3",3),0.1),
		atk11=anim8.newAnimation(grid("1-3",4),0.1),
		atk12=anim8.newAnimation(grid("1-3",5),0.1),
		stun0=anim8.newAnimation(grid("1-2",6),0.1),
		stun1=anim8.newAnimation(grid("1-2",7),0.1),
		stun2=anim8.newAnimation(grid("1-2",8),0.1),
	}

	return setmetatable(new_wolf, _wolf)
end

function _wolf:setMove(mx, my)
	if self.state == "stun" then return end

	if mx ~= 0 or my ~= 0 then
		self.omx = mx
		self.omy = my
	end

	if mx ~= 0 then
		self.oomx = mx
	end

	self.mx = mx
	self.my = my
end

function _wolf:damage(v)
	self.hp = math.max(self.hp - v, 0)
end

function _wolf:stun(t, dir, spd)
	self.state = "stun"

	local anim = self.anim["stun"..tostring(self.stun_p)]
	anim:gotoFrame(1)
	anim:resume()

	self.stun_t = t
	self.dx = dir[1]*spd
	self.dy = dir[2]*spd
end

function _wolf:attack()
	--love.event.push("plrAttacked", self)
	if self.state == "idle" and self.atk1_c <= 0 then
		self.state = "atk1"

		local anim = self.anim["atk1"..tostring(self.atk1_p)]
		anim:gotoFrame(1)
		anim:resume()

		self.amx = self.omx
		self.amy = self.omy
		self.atk1_t = self.atk1_tt
		self.atk1_c = self.atk1_cc
	end
end

function _wolf:updateBehavior(dt, world)
	if self.hp <= 0 then
		self:destroy()
		return
	end

	self.anim.idle:update(dt)
	self.anim.walk:update(dt)
	self.anim.atk10:update(dt)
	self.anim.atk11:update(dt)
	self.anim.atk12:update(dt)
	self.anim.stun0:update(dt)
	self.anim.stun1:update(dt)
	self.anim.stun2:update(dt)

	self.atk1_c = math.max(self.atk1_c-dt,0)
	self.atk1_t = math.max(self.atk1_t-dt,0)
	self.stun_t = math.max(self.stun_t-dt,0)

	if self.state == "idle" then
		self.dx = self.mx*250
		self.dy = self.my*250
	elseif self.state == "atk1" then
		if self.atk1_t <= 0 then
			self.state = "idle"
			self.atk1_p = (self.atk1_p + 1) % self.atk1_pp
		end

		--Cast hitbox
		do
			u = (self.omx^2+self.omy^2)^(1/2)
			ox = (self.omx/u)
			oy = (self.omy/u)
			x = self.x + ox*30
			y = self.y + oy*30
			w = 30
			h = 30
			casterid = self.id
			usr_data = {ox,oy}
			love.event.push("queryHitbox",x,y,w,h,casterid,usr_data)
		end

		self.dx = self.amx*50
		self.dy = self.amy*50
	elseif self.state == "stun" then
		if self.stun_t <= 0 then
			self.state = "idle"
			self.stun_p = (self.stun_p + 1) % self.stun_pp
		end
	end
end

function _wolf:draw(camera)
	if not camera then return end

	--Hitbox
	local offx, offy = camera:getDrawOffset()
	love.graphics.setColor(1,0,1)
	love.graphics.rectangle("line", 
		self.x + offx, 
		self.y + offy, 
		self.width,
		self.height
		)

	--Sprite
	love.graphics.setColor(1,1,1)
	if self.state == "atk1" then
		local anim = self.anim["atk1"..tostring(self.atk1_p)]
		anim:draw(
			img, 
			self.x + offx - 64/4 + math.abs(math.min(self.oomx, 0)) * 64*1, 
			self.y + offy - 64/4,
			0,
			1 * self.oomx,
			1
		)
	elseif self.state == "stun" then
		local anim = self.anim["stun"..tostring(self.stun_p)]
		anim:draw(
			img, 
			self.x + offx - 64/4 + math.abs(math.min(self.oomx, 0)) * 64*1, 
			self.y + offy - 64/4,
			0,
			1 * self.oomx,
			1
		)

	elseif self.mx ~= 0 or self.my ~= 0 then
		self.anim.walk:draw(
			img, 
			self.x + offx - 64/4 + math.abs(math.min(self.oomx, 0)) * 64*1, 
			self.y + offy - 64/4,
			0,
			1 * self.oomx,
			1
		)
	else
		self.anim.idle:draw(
			img, 
			self.x + offx - 64/4 + math.abs(math.min(self.oomx, 0)) * 64*1, 
			self.y + offy - 64/4,
			0,
			1 * self.oomx,
			1
		)
	end

	--Healthbar TODO replace with UI element
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill",
		self.x + offx,
		self.y + self.height + 5 + offy,
		self.width * self.hp/self.maxhp,
		5
		)
end

return _wolf