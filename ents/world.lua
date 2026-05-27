_world = {}
_world.__index = _world

function _world.new()
	new_world = {}
	new_world._ents = {}
	new_world._ncs = {}
	plrid = nil
	camid = nil

	return setmetatable(new_world, _world)
end

function _world:addEntity(ent)
	self._ents[#self._ents+1] = ent
	entid = #self._ents
	ent:setid(entid)
	return entid
end

function _world:getEntity(id)
	ent = self._ents[id]
	if not ent then error() end
	return ent
end

function _world:getEntities()
	return self._ents
end

function _world:setPlayer(plr)
	--TODO give it a special spot
	return self:addEntity(plr)
end

function _world:getPlayer()
	return plrid and self._ents[plrid]
end

function _world:setCamera(cam)
	--TODO give it a special spot
	return self:addEntity(cam)
end

function _world:getCamera()
	return camid and self._ents[camid]
end

function _world:setNoCollide(ent1,ent2)
	self._ncs[#self._ncs+1] = {ent1, ent2}
end

function _world:getNoCollides()
	return self._ncs
end

function _world:isNoCollide(ent1, ent2)
	if ent1==ent2 then return false end
	local r = false
	for _, nc in pairs(self:getNoCollides()) do
		if (nc[1]==ent1 and nc[2]==ent2) or (nc[2]==ent1 and nc[1]==ent2) then
			r = true
			break
		end
	end
	return r, k
end

function _world:destroyNoCollidesWith(ent)
	--Delete all no-collide constraints.
	for k, nc in pairs(self:getNoCollides()) do
		if nc[0] == ent or nc[1] == ent then
			self._ncs[k] = nil
		end
	end
end

function _world:printAllEntities()
	print("ENTITIES IN WORLD",self,":")
	for k,ent in pairs(self:getEntities()) do
		print(">",k,"::",ent,ent.class,ent.name)
	end
end

function _world:updateAll(dt)
	for k,ent in pairs(self:getEntities()) do
		--Garbage-collect entities.
		if ent.destroyed then
			self:destroyNoCollidesWith(ent)
			self._ents[k] = nil
		else
			ent:updateBehavior(dt, self)
			ent:updatePhysics(dt, world)
		end
	end

	cam:updatePhysics(dt, self) --Atualiza de novo para que não fique travando
end

return _world