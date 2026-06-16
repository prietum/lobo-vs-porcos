local _ent = require("ents.ent")

local _wall = {}
_wall.__index = _wall
setmetatable(_wall, _ent)

function _wall.new(x,y,width,height)
	local new_wall = _ent.new()

	new_wall.name = "wall"
	new_wall.class = "wall"

	new_wall.x = x
	new_wall.y = y
	new_wall.width = width
	new_wall.height = height

	return setmetatable(new_wall, _wall)
end

local test = false
function _wall:draw(camera)
	if not test then return end
	if not camera then return end
	local offx, offy = camera:getDrawOffset()
	love.graphics.setColor(1,0,1)
	love.graphics.rectangle("fill", 
		self.x+offx, 
		self.y+offy, 
		self.width, 
		self.height
		)
end

return _wall