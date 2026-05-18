_world = {}
_world.__index = _world

function _world.new()
	new_world = {}
	new_world.ents = {}
	new_world.ncs = {}
	plrid = nil
	camid = nil

	return setmetatable(new_world, _world)
end

function _world:addEntity(ent)
	self.ents[#self.ents+1] = ent
end

function _world:getEntities()
	return self.ents
end

function _world:setPlayer(plr)
	self:addEntity(plr)
	plrid = #self.ents
end

function _world:getPlayer()
	return plrid and self.ents[plrid]
end

function _world:setCamera(cam)
	for k,v in pairs(self) do print(k,v) end
	self:addEntity(cam)
	camid = #self.ents
end

function _world:getCamera()
	return camid and self.ents[camid]
end

function _world:setNoCollide(ent1,ent2)
	self.ncs[#self.ncs+1] = {ent1, ent2}
end

function _world:isNoCollide(ent1, ent2)
	if ent1==ent2 then return false end
	local r = false
	for _, nc in pairs(self.ncs) do
		if nc[1]==ent1 and nc[2]==ent2 then
			r = true
			break
		end
	end
	return r
end

function _world:updateAll(dt)
	--Update entity behavior.
	for k,ent in pairs(self:getEntities()) do
		ent:updateBehavior(dt, self)
	end

	--Update entity physics.
	for k,ent in pairs(self:getEntities()) do
		ent:updatePhysics(dt, self)
	end

	cam:updatePhysics(dt, self) --Atualiza de novo para que não fique travando
end

return _world