local _ent = require("ents.ent")

local _wolf = {}
_wolf.__index = _wolf
setmetatable(_wolf, _ent)

function _wolf.new()
	local new_wolf = _ent.new()

	new_wolf.maxhp=100
	new_wolf.hp=new_wolf.maxhp

	new_wolf.maxpp=100
	new_wolf.pp=new_wolf.maxpp

	--todo conserta
	new_wolf.width = 30
	new_wolf.height = 30

	return setmetatable(new_wolf, _wolf)
end

function _wolf:draw(camera)
	if not camera then return end
	local offx, offy = camera:getDrawOffset()
	love.graphics.rectangle("fill", 
		self.x + offx, 
		self.y + offy, 
		self.width,
		self.height
		)
end

return _wolf