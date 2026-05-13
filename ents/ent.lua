local _ent = {}
_ent.__index = _ent

_ent_list = {}

function _ent.new()
	local new_ent = {}
	new_ent.x=0
	new_ent.y=0
	new_ent.dx=0
	new_ent.dy=0

	new_ent.mx=0
	new_ent.my=0

	setmetatable(new_ent, _ent)
	return new_ent
end

return _ent