local _ent = require("ents.ent")
local anim8 = require("anim8")

local _pig = {}
_pig.__index = _pig
setmetatable(_pig, _ent)

local img = love.graphics.newImage("assets/sprites/spear_pig.png")
img:setFilter("nearest", "nearest")
local grid = anim8.newGrid(64,64,512,256,0,0,0)

function _pig.new()
	local new_pig = _ent.new()

	new_pig.name = "pig"
	new_pig.class = "pig"

	new_pig.maxhp=100
	new_pig.hp=new_pig.maxhp
	new_pig.width = 30
	new_pig.height = 30

	new_pig.state = "idle"
	new_pig.atk_d = 0
	new_pig.atk_dd= 0.4
	new_pig.atk_t = 0
	new_pig.atk_tt = 0.5
	new_pig.atk_c = 0
	new_pig.atk_cc = 2
	new_pig.stun_t = 0
	new_pig.stop_t = 0
	new_pig.stop_tt= 1

	new_pig.oomx = 1

	new_pig.anim = {
		idle=anim8.newAnimation(grid("1-6",1),0.1),
		walk=anim8.newAnimation(grid("1-6",2),0.1),
		atk=anim8.newAnimation(grid("1-6",3),0.1),
		stun=anim8.newAnimation(grid("1-2",4),0.1),
	}

	return setmetatable(new_pig, _pig)
end

function _pig:damage(v)
	self.hp = math.max(self.hp - v, 0)
end

function _pig:stun(t, dir, spd)
	self.state = "stun"

	--local anim = self.anim["stun"..tostring(self.stun_p)]
	--anim:gotoFrame(1)
	--anim:resume()

	self.stun_t = t
	self.dx = dir[1]*spd
	self.dy = dir[2]*spd
end

function _pig:attack()
	if self.state == "idle" and self.atk_c <= 0 then
		self.state = "atk"

		self.anim.atk:gotoFrame(1)
		self.anim.atk:resume()

		self.atk_t = self.atk_tt
		self.atk_c = self.atk_cc
		self.atk_d = self.atk_dd
	end
end

function _pig:updateBehavior(dt, world)
	if self.hp <= 0 then
		self:destroy()
		return
	end

	self.anim.idle:update(dt)
	self.anim.walk:update(dt)
	self.anim.atk:update(dt)

	plr = world:getPlayer()
	if plr then
		diffx = plr.x - self.x
		diffy = plr.y - self.y
		diffm = (diffx^2+diffy^2)^0.5

		dirx = diffx/diffm
		diry = diffy/diffm
	else
		dirx = 0
		diry = 0
		diffm = 1
	end

	for _, other_pig in pairs(world:getEntities()) do
		if other_pig.class == "pig" and other_pig ~= self then
			pdiffx = self.x - other_pig.x
			pdiffy = self.y - other_pig.y
			pdiffm = (pdiffx^2+pdiffy^2)^0.5
			dirx = dirx + 0.1*pdiffx/pdiffm
			diry = diry + 0.1*pdiffy/pdiffm
		end
	end

	self.atk_c = math.max(self.atk_c-dt,0)
	self.atk_t = math.max(self.atk_t-dt,0)
	self.atk_d = math.max(self.atk_d-dt,0)
	self.stun_t = math.max(self.stun_t-dt,0)
	self.stop_t = math.max(self.stop_t-dt,0)

	if self.state == "idle" then
		if plr then
			if self.stop_t <= 0 and math.random(1,500) == 1 then
				self.stop_t = self.stop_tt
			end

			if self.stop_t<=0 then
				self.dx = (dirx) * 50 * diffm/100
				self.dy = (diry) * 50 * diffm/100
			else
				self.dx = 0
				self.dy = 0
			end

			if diffm < 100 then
				self:attack()
			end
		else
			self.dx = 0
			self.dy = 0
		end
	elseif self.state == "atk" then
		if self.atk_t <= 0 then
			self.state = "idle"
		end
		
		if self.atk_d <= 0 then
			self.dx = dirx*200
			self.dy = diry*200

			--Cast hitbox
			do
				x = self.x + dirx*25 + 7.5
				y = self.y + diry*25 + 7.5
				w = 15
				h = 15
				casterid = self.id
				usr_data = {dirx, diry}
				love.event.push("queryHitbox",x,y,w,h,casterid,usr_data)
			end
		else
			self.dx = 0
			self.dy = 0
		end
	elseif self.state == "stun" then
		if self.stun_t <= 0 then
			self.state = "idle"
			self.dx = 0
			self.dy = 0
		end
	end

	if self.dx > 0 then
		self.oomx = 1
	elseif self.dx < 0 then
		self.oomx = -1
	end
end

function _pig:draw(camera)
	if not camera then return end
	local offx, offy = camera:getDrawOffset()

	--Hitbox
	love.graphics.setColor(1,1,0)
	love.graphics.rectangle("line",
		self.x + offx, 
		self.y + offy, 
		self.width,
		self.height
	)

	--Sprite
	love.graphics.setColor(1,1,1)
	if self.state == "atk" then
		self.anim.atk:draw(
			img, 
			self.x + offx - 64/4 + math.abs(math.min(self.oomx, 0)) * 64*1, 
			self.y + offy - 64/4,
			0,
			1 * self.oomx,
			1
		)
	elseif self.state == "stun" then
		local anim = self.anim["stun"]
		anim:draw(
			img, 
			self.x + offx - 64/4 + math.abs(math.min(-self.oomx, 0)) * 64*1, 
			self.y + offy - 64/4,
			0,
			1 * -self.oomx,
			1
		)

	elseif self.dx ~= 0 or self.dy ~= 0 then
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

	--Healthbar
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill",
		self.x + offx,
		self.y + self.height + 5 + offy,
		self.width,
		5
		)

	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("fill",
		self.x + offx + 1,
		self.y + self.height + 6 + offy,
		(self.width - 2) * self.hp/self.maxhp,
		3
		)
end

return _pig