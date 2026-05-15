local _ent = require("ents.ent")

local _pig = {}
_pig.__index = _pig
setmetatable(_pig, _ent)

function _pig.new()
	local new_pig = _ent.new()

	new_pig.maxhp=100
	new_pig.hp=new_pig.maxhp

	return setmetatable(new_pig, _pig)
end

function _pig:draw()
	local offx, offy = camera:getDrawOffset()
	love.graphics.circle("line", self.x + offx, self.y + offy, 15)
end

return _pig