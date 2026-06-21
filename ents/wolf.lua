local _ent = require("ents.ent")
local anim8 = require("anim8")

local _wolf = {}
_wolf.__index = _wolf
setmetatable(_wolf, _ent)

local img = love.graphics.newImage("assets/sprites/lobo.png")
img:setFilter("nearest", "nearest")
local grid = anim8.newGrid(64,64,512,576,0,0,0)

local swing_sfx = love.audio.newSource("assets/music/swing.mp3", "static")

local function lerp_quad(a,b,t,e)
	f = -e*t^2 + (1+e)*t
	--f = (f + 1)/2
	--print(t, f)
	return a + (b-a)*f
end

function _wolf.new()
	local new_wolf = _ent.new()

	new_wolf.name = "wolf"
	new_wolf.class = "wolf"

	new_wolf.maxhp=5
	new_wolf.hp=new_wolf.maxhp

	new_wolf.maxpp=100
	new_wolf.pp=100--new_wolf.maxpp

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
	new_wolf.atk1_cc = 0.5

	new_wolf.atk2_t = 0
	new_wolf.atk2_tt = 2
	new_wolf.atk2_d = 0
	new_wolf.atk2_dd= 0.5
	new_wolf.atk2_c = 0
	new_wolf.atk2_cc = 3

	new_wolf.atk3_t = 0
	new_wolf.atk3_tt = 0.4
	new_wolf.atk3_c = 0
	new_wolf.atk3_cc = 5

	new_wolf.stun_t = 0

	new_wolf.inv_t = 0
	new_wolf.inv_tt = 1

	new_wolf.anim = {
		idle=anim8.newAnimation(grid("1-8",1),0.1),
		walk=anim8.newAnimation(grid("1-8",2),0.1),
		atk10=anim8.newAnimation(grid("1-3",3),0.1),
		atk11=anim8.newAnimation(grid("1-3",4),0.1),
		atk12=anim8.newAnimation(grid("1-3",5),0.1),
		atk20=anim8.newAnimation(grid("1-5",6),0.1),
		atk21=anim8.newAnimation(grid("1-2",7),0.1),
		atk30=anim8.newAnimation(grid("1-1",8),0.1),
		stun=anim8.newAnimation(grid("1-2",9),0.1)
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

	--invicibility
	self.inv_t = self.inv_tt
end

function _wolf:stun(t, dir, spd)
	self.state = "stun"

	local anim = self.anim["stun"]
	anim:gotoFrame(1)
	anim:resume()

	self.stun_t = t
	self.dx = dir[1]*spd
	self.dy = dir[2]*spd
end

function _wolf:attack()
	--Soca/chuta parado.

	if self.state == "idle" and self.atk1_c <= 0 then
		swing_sfx:play()
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

function _wolf:sopra()
	--Sopra inimigos para longe, usa energia gradualmente.

	if self.pp < self.maxpp/2 then return end
	if self.state == "idle" and self.atk1_c <= 0 and self.atk2_c <= 0 and self.atk3_c <= 0 then
		self.state = "atk2"
		self.pp = self.pp - self.maxpp/2

		local anim = self.anim["atk20"]
		anim:gotoFrame(1)
		anim:resume()

		self.atk2_d = self.atk2_dd
		self.atk2_t = self.atk2_tt
		self.atk2_c = self.atk2_cc
	end
end

function _wolf:devour()
	--Avança e devora um inimigo, curando dois pontos de vida.
	--Consome toda a energia!

	if self.pp < self.maxpp then return end
	if self.state == "idle" and self.atk1_c <= 0 and self.atk2_c <= 0 and self.atk3_c <= 0 then
		self.state = "atk3"
		self.pp = 0

		local anim = self.anim["atk30"]
		anim:gotoFrame(1)
		anim:resume()

		self.amx = self.omx
		self.amy = self.omy
		self.atk3_t = self.atk3_tt
		self.atk3_c = self.atk3_cc
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
	self.anim.atk20:update(dt)
	self.anim.atk21:update(dt)
	self.anim.atk30:update(dt)
	--self.anim.atk31:update(dt)
	self.anim.stun:update(dt)

	self.atk1_c = math.max(self.atk1_c-dt,0)
	self.atk1_t = math.max(self.atk1_t-dt,0)

	self.atk2_d = math.max(self.atk2_d-dt,0)
	self.atk2_c = math.max(self.atk2_c-dt,0)
	self.atk2_t = math.max(self.atk2_t-dt,0)

	self.atk3_c = math.max(self.atk3_c-dt,0)
	self.atk3_t = math.max(self.atk3_t-dt,0)

	self.stun_t = math.max(self.stun_t-dt,0)
	self.inv_t  = math.max(self.inv_t -dt,0)

	if self.state == "idle" then
		self.pp = math.min(self.pp + dt*10, self.maxpp)

		spd = lerp_quad(25,250,self.pp/self.maxpp,1)
		self.dx = self.mx*spd--(50+200*self.pp/self.maxpp)
		self.dy = self.my*spd--(50+200*self.pp/self.maxpp)
		--print(spd)
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
			usr_data = {ox,oy,"atk1"}
			love.event.push("queryHitbox",x,y,w,h,casterid,usr_data)
		end

		self.dx = 0--self.amx*100
		self.dy = 0--self.amy*100
	elseif self.state == "atk2" then
		if self.atk2_t <= 0 then
			self.state = "idle"
		end

		--Cast hitbox
		if self.atk2_d <=0 then
			u = (self.omx^2+self.omy^2)^(1/2)
			ox = (self.omx/u)
			oy = (self.omy/u)
			x = self.x + ox*80 - 80 + 15
			y = self.y + oy*80 - 80 + 15
			w = 160
			h = 160
			casterid = self.id
			usr_data = {ox,oy,"atk2"}
			love.event.push("queryHitbox",x,y,w,h,casterid,usr_data)

			self.dx = -self.omx*25
			self.dy = -self.omy*25
		else
			self.dx = self.omx*25
			self.dy = self.omy*25
		end
		
	elseif self.state == "atk3" then
		if self.atk3_t <= 0 then
			self.state = "idle"
		end

		--Cast hitbox
		do
			u = (self.amx^2+self.amy^2)^(1/2)
			ox = (self.amx/u)
			oy = (self.amy/u)
			x = self.x + ox*30
			y = self.y + oy*30
			w = 30
			h = 30
			casterid = self.id
			usr_data = {ox,oy,"atk3"}
			love.event.push("queryHitbox",x,y,w,h,casterid,usr_data)
		end

		self.dx = self.amx*500
		self.dy = self.amy*500
	elseif self.state == "stun" then
		if self.stun_t <= 0 then
			self.state = "idle"
		end
	end
end

function _wolf:draw(camera)
	if not camera then return end

	--Hitbox
	local offx, offy = camera:getDrawOffset()
	--love.graphics.setColor(1,0,1)
	--love.graphics.rectangle("line", 
	--	self.x + offx, 
	--	self.y + offy, 
	--	self.width,
	--	self.height
	--)

	--Sprite
	if self.inv_t <= 0 or self.inv_t%0.2 < 0.1 then
		if (self.atk2_c > 0 and self.state ~= "atk2") or (self.atk3_c > 0 and self.state ~= "atk3") then
			love.graphics.setColor(0.50,0.50,0.50)
		else
			love.graphics.setColor(1.00,1.00,1.00)
		end
		
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
		elseif self.state == "atk2" then
			local anim
			if self.atk2_d > 0 then
				anim = self.anim["atk20"]
			else
				anim = self.anim["atk21"]
			end

			anim:draw(
				img, 
				self.x + offx - 64/4 + math.abs(math.min(self.oomx, 0)) * 64*1, 
				self.y + offy - 64/4,
				0,
				1 * self.oomx,
				1
			)
		elseif self.state == "atk3" then
			local anim = self.anim["atk30"]

			--akuma styled ghost
			local r,g,b = love.graphics.getColor()
			love.graphics.setColor(1.00,0.00,0.00)
			amx = self.amx
			if amx == 0 then amx = 1 end
			for i = self.atk3_tt - self.atk3_t, 0, -0.1 do
				anim:draw(
				img, 
				self.x + offx - 64/4 + math.abs(math.min(self.amx, 0)) * 64*1 - (self.amx*500*i), 
				self.y + offy - 64/4 - (self.amy*500*i),
				0,
				1 * amx,
				1
			)
			end

			love.graphics.setColor(r,g,b)
			anim:draw(
				img, 
				self.x + offx - 64/4 + math.abs(math.min(self.amx, 0)) * 64*1, 
				self.y + offy - 64/4,
				0,
				1 * amx,
				1
			)

		elseif self.state == "stun" then
			local anim = self.anim["stun"]
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
	end
end

return _wolf