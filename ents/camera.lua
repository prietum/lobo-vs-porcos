local _ent = require("ents.ent")

local _camera = {}
_camera.__index = _camera
setmetatable(_camera, _ent)

function _camera.new()
	local new_camera = _ent.new()

	return setmetatable(new_camera, _camera)
end

function _camera:setFocus(ent)
	self.focus = ent
end

function _camera:update()
	if self.focus then
		self.x = self.focus.x
		self.y = self.focus.y
	end
end

function _camera:getDrawOffset()
	local winx, winy = love.window.getMode()
	return -self.x + winx/2, -self.y + winy/2
end

return _camera