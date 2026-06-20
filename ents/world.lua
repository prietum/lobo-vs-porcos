_world = {}
_world.__index = _world

function _world.new()
	new_world = {}
	new_world._ents = {}
	new_world._ncs = {}
	new_world.plrid = nil
	new_world.camid = nil

	return setmetatable(new_world, _world)
end

function _world:addEntity(ent)
	entid = #self._ents+1
	self._ents[entid] = ent
	ent:setid(entid)
	return entid
end

function _world:getEntity(id)
	assert(type(id)=="number", "_world:getEntity(id): id passed is not a number.")
	ent = self._ents[id]
	if ent.destroyed then print(string.format("Entity id:%d class:%s is destroyed.", id, ent.class)) end
	assert(ent, string.format("Entity id:%d not found.", id))
	if not ent then error(string.format("Entity %d not found!", id)) end
	return ent
end

function _world:getEntities()
	return self._ents
end

function _world:setPlayer(plr)
	self.plrid = self:addEntity(plr)
	--print("setPlayer:",self.plrid,plr,plr.class)
	--print("setPlayer result:",self.plrid, self._ents[self.plrid], self._ents[self.plrid].class)
	return self.plrid
end

function _world:getPlayer()
	--if self.plrid then
		--print("getPlayer",self.plrid, self._ents[self.plrid], self._ents[self.plrid].class)
	--else
		--print("getPlayer",self.plrid, self._ents[self.plrid])
	--end
	
	return self._ents[self.plrid]
end

function _world:setCamera(cam)
	self.camid = self:addEntity(cam)
	return self.camid
end

function _world:getCamera()
	return self._ents[self.camid]
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

			-- clear up special id vars
			if self.plrid == k then print("Player destroyed.") self.plrid = nil love.event.push("playerDied")
			elseif self.camid == k then print("Camera destroyed.") self.camid = nil
			end

			if ent.class=="pig" then print("Pig destroyed.") love.event.push("pigDied") end
		else
			ent:updateBehavior(dt, self)
			ent:updatePhysics(dt, world)
		end
	end

	cam:updatePhysics(dt, self) --Atualiza de novo para que não fique travando
end

return _world