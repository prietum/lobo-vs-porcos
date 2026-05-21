local _ent = require("ents.ent")

local _wolf = {}
_wolf.__index = _wolf
setmetatable(_wolf, _ent)

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

	new_wolf.width = 30
	new_wolf.height = 30

	return setmetatable(new_wolf, _wolf)
end

function _wolf:setMove(mx, my)
	if mx ~= 0 or my ~= 0 then
		self.omx = mx
		self.omy = my
	end
	self.mx = mx
	self.my = my
end

function _wolf:attack()
	love.event.push("plrAttack")
end

function _wolf:updateBehavior(dt, world)
	--print("wolf behavior")
	--print(self.mx, self.my)
	self.dx = self.mx*500
	self.dy = self.my*500
	--print(self.dx, self.dy)
end

function _wolf:draw(camera)
	if not camera then return end
	local offx, offy = camera:getDrawOffset()
	love.graphics.setColor(1,0,1)
	love.graphics.rectangle("fill", 
		self.x + offx, 
		self.y + offy, 
		self.width,
		self.height
		)
end

return _wolf