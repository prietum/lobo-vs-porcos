local _ent = {}
_ent.__index = _ent

function _ent.new()
	local new_ent = {}
	new_ent.name = "Unnamed Entity"

	new_ent.x=0
	new_ent.y=0
	new_ent.dx=0
	new_ent.dy=0

	new_ent.width = 0
	new_ent.height = 0

	new_ent.mx=0
	new_ent.my=0

	new_ent.world = {}
	new_ent.noncollide = {}

	setmetatable(new_ent, _ent)
	return new_ent
end

function _ent:setWorld(world)
	self.world = world
end

function _ent:setNonCollide(noncollide)
	self.noncollide = noncollide
end

function _ent:update(dt)
	--anti noclip: checks only when i'm in movement!
	if self.dx ~= 0 or self.dy ~= 0 then
		local collx = false
		local colly = false
		for k, ent in ipairs(self.world) do
			local ego = false
			local nc = false
			local atom = false

			ego = self==ent
			atom = ent.width==0 and ent.height==0
			if not ego and not atom then
				for k2, nc_ent in ipairs(self.noncollide) do
					if nc_ent==ent then nc = true break end
				end
			end

			if not ego and not atom and not nc then
				local AA = self.x+self.width+self.dx*dt>ent.x and self.x+self.dx*dt<ent.x+ent.width
				local BB = self.y+self.height+self.dy*dt>ent.y and self.y+self.dy*dt<ent.y+ent.height
				
				if AA and BB then
					print(self.name, "collided with", ent.name)

					local dffx = math.min(math.abs((self.x+self.width)-(ent.x)),math.abs((self.x)-(ent.x+ent.width)))
					local dffy = math.min(math.abs((self.y+self.height)-(ent.y)),math.abs((self.y)-(ent.y+ent.height)))

					if dffx<dffy then
						collx = true
						if self.dx > 0 then
							self.x = ent.x - self.width
						else
							self.x = ent.x + ent.width
						end
					else
						colly = true
						if self.dy > 0 then
							self.y = ent.y - self.height
						else
							self.y = ent.y + ent.height
						end
					end
				end
			end
		end

		if not collx then
			self.x = self.x + (self.dx)* dt
		end
		if not colly then
			self.y = self.y + (self.dy)* dt
		end
	end
end

function _ent:draw(camera) end

return _ent