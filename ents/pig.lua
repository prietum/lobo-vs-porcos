local _ent = require("ents.ent")

local _pig = {}
_pig.__index = _pig
setmetatable(_pig, _ent)

function _pig.new()
	local new_pig = _ent.new()

	new_pig.maxhp=100
	new_pig.hp=new_pig.maxhp
	new_pig.width = 30
	new_pig.height = 30

	return setmetatable(new_pig, _pig)
end

function _pig:updateBehavior(dt)
	self.dx = self.dx + math.random(-50,50) * dt
	self.dy = self.dy + math.random(-50,50) * dt
end

function _pig:draw(camera)
	if not camera then return end
	local offx, offy = camera:getDrawOffset()
	love.graphics.rectangle("line",
		self.x + offx, 
		self.y + offy, 
		self.width,
		self.height
	)
end

return _pig