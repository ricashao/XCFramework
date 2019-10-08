--[[
	异步加载的Prefab, 并异步加载所有挂载点上的prefab
]]

local PrefabObject = require "UI.PrefabObject"
local AsynPrefabObject = Class("AsynPrefabObject", PrefabObject)

function AsynPrefabObject:Ctor(...)

	PrefabObject.Ctor(self, ...)

	self.loadPath = nil
	self.loaded = false
	self.inLoading = false
	self.onLoadedCallBack = nil
	self.loader = AsynPrefabLoader.New()
end

function AsynPrefabObject:Destroy()
	self.loader:Destroy()
	PrefabObject.Destroy(self)
end

--[[
	@pfbname    prefab的名字
	@path 	    prefab的路径
	@onloaded   加载完成的回调
	@bReuse     是否放到PrefabPool中 重复利用(废弃)

]]
function AsynPrefabObject:LoadObject(pfbname, path, onloaded, bReuse)

	if self.inLoading then
		return
	end
	-- self.reuse = bReuse
	self.onLoadedCallBack = onloaded
	path = string.lower(path .. "/"..pfbname..".ga")
	self.loadPath = path
	self.loader:Load(path, self.OnLoadEnd, self.OnLoadErr, self)
end
--
function AsynPrefabObject:OnLoadEnd(key, pfb)
	
	AssetManager.MountResource(pfb)
	self.loaded = true
	self.prefab = pfb
	self.onLoadedCallBack(self, pfb)
end

-- 加载失败
function AsynPrefabObject:OnLoadErr(path, self)

end


return AsynPrefabObject