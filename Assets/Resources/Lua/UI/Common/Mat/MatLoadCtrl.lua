MatLoadCtrl = {}

function MatLoadCtrl.GetMat(name, path)
	local mat = Resources.Load(path .. "/" .. name, Material.GetClassType())
	return mat
end