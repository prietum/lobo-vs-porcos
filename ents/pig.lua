local _ent = require("ents.ent")

local _pig = {}
_pig.__index = _pig
setmetatable(_pig, _ent)

function _pig.new()
	local new_pig = _ent.new()

	new_pig.name = "pig"
	new_pig.class = "pig"

	new_pig.maxhp=100
	new_pig.hp=new_pig.maxhp
	new_pig.width = 30
	new_pig.height = 30

	new_pig.state = "idle"
	new_pig.stun_t = 0

	return setmetatable(new_pig, _pig)
end

function _pig:updateBehavior(dt, world)
	if self.hp <= 0 then
		self:destroy()
		return
	end

	self.stun_t = math.max(self.stun_t-dt,0)

	if self.state == "idle" then
		plr = world:getPlayer()
		if plr then
			diffx = plr.x - self.x
			diffy = plr.y - self.y
			diffm = (diffx^2+diffy^2)^0.5

			dirx = diffx/diffm
			diry = diffy/diffm

			self.dx = dirx * 100
			self.dy = diry * 100
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

	--Healthbar.
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle("fill",
		self.x + offx,
		self.y + self.height + 5 + offy,
		self.width * self.hp/self.maxhp,
		5
		)
end

return _pig