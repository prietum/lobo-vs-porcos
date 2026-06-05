local _ent = require("ents.ent")

_hitbox = {}
_hitbox.__index = _hitbox

setmetatable(_hitbox, _ent)

function _hitbox.new()
	new_hitbox = _ent.new()

	new_hitbox.name = "hitbox"
	new_hitbox.class = "hitbox"

	new_hitbox.querying = false
	new_hitbox.queryingonce = false
	new_hitbox.caster = caster
	new_hitbox.usr_data = {}

	return setmetatable(new_hitbox, _hitbox)
end

function _hitbox:updateBehavior()
	if not self.querying then
		--print("yoa")
		self:destroy()
	end	
end

function _hitbox:updatePhysics(dt, world) --TODO switch for radial check
	if not self.querying then return end
	for k, ent in pairs(world:getEntities()) do
		local ego = false
		local dad = false
		local atom = false
		local dead = false

		dead = ent.destroyed
		ego = self.id==ent.id
		dad = self.casterid==ent.id
		atom = ent.width==0 and ent.height==0
		hbx = ent.class == "hitbox" or ent.class == "wall"

		--print(self.caster, ent)

		if not dead and not ego and not atom and not dad and not hbx then
			local AA = self.x+self.width>ent.x and self.x<ent.x+ent.width
			local BB = self.y+self.height>ent.y and self.y<ent.y+ent.height
			
			if AA and BB then
				--Collided
				print("entHit:", self.name, "->", ent.name)
				love.event.push("entHit", ent.id, self.id)
			end
		end
	end
	if self.queryingonce then
		self.querying = false
	end
end

function _hitbox:queryStart()
	self.querying = true
	self.queryingonce = false
end

function _hitbox:queryEnd()
	self.querying = false
	self.queryingonce = false
end

function _hitbox:queryOnce()
	self.querying = true
	self.queryingonce = true
end

function _hitbox:draw(camera)
	if not camera then return end
	local offx, offy = camera:getDrawOffset()
	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("line", 
		self.x + offx, 
		self.y + offy, 
		self.width,
		self.height
		)
end

return _hitbox