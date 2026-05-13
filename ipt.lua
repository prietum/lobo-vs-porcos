local _ipt_map = {
	["left"]={false, "a"},
	["right"]={false, "d"},
	["up"]={false,"w"},
	["down"]={false,"s"},
	["atk1"]={false,"i"},--combo
	["atk2"]={false,"o"},--devora
	["atk3"]={false,"p"},--sopra
	["menu"]={false,"escape"},
	["abi1"]={false,"k"},--desvia
	["abi2"]={false,"l"},--bloqueia
}

local _ipt = {}

function _ipt.update(key, pressed)
	if pressed then
		for i,v in pairs(_ipt_map) do
			v[1]=(key==v[2] and true) or v[1]
		end
	else
		for i,v in pairs(_ipt_map) do
			v[1]=(key~=v[2] and v[1]) or false
		end
	end
end

function _ipt.__index(self, key)
	assert(_ipt_map[key])
	return _ipt_map[key][1]
end

return setmetatable(_ipt, _ipt)