require "Utils.TableUtil"
local Object = require "Framework.Object"
local UIPrefabCtrl = Class("UIPrefabCtrl", Object)

UIPrefabCtrl.ObjectPool = {}
----///////////======调用的接口(创建预制体池)======/////////////////
--by Yss --2015.7.30

function UIPrefabCtrl:Destroy()

	if self.prefabObj then
		self:ReturnObj(self.prefabObj)
		self.prefabObj = nil
	end
end

--创建一个池，放入预制体
function UIPrefabCtrl:CreatePrefab(modelname, path)
	local prefab = UIPrefabCtrl:GetModelFromPool(modelname,path)
	self.prefabObj = prefab.obj
	self.isAddedEpt = prefab.isAddedEpt
	return self.prefabObj, self.isAddedEpt--(挂载点是否加载过)
end

--///////////////========以下下方法不需要关注======////////////////////////////////

function UIPrefabCtrl:Ctor( ... )

end

----查找池中有无预制体，没有创建，有则取出
function UIPrefabCtrl:GetModelFromPool(modelname, path)
	local prefab = {}
	for k, v in pairs(UIPrefabCtrl.ObjectPool) do
		if v.name == modelname then
			prefab.obj = v
			prefab.isAddedEpt = true
			prefab.obj:SetActive(true)
			UIPrefabCtrl.ObjectPool[k] = nil
			break
		end
	end
	if prefab.obj == nil then
	 	prefab.obj = self:LoadPrefab(modelname,path)
	 	prefab.isAddedEpt = false
	end
	return prefab
end

----加载预制体对象
function UIPrefabCtrl:LoadPrefab(modelname, path)

	local path = string.lower(path.."/"..modelname..".ga")
    local pfb = PoolManager.GetResourceObject(path, 1)
    return pfb
end

----放入池
function UIPrefabCtrl:ReturnObj( obj )
	if obj then
		obj:SetActive(false)
		table.insert(UIPrefabCtrl.ObjectPool,obj)
	end
end

----销毁池
function UIPrefabCtrl.DestroyPool()
	for _, v in pairs(UIPrefabCtrl.ObjectPool) do
		if v then
			GameObject.Destroy(v)
		end
	end
	UIPrefabCtrl.ObjectPool = {}
	isloaded = false
end

return UIPrefabCtrl