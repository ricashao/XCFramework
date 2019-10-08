----- 异步加载器
require "Load.PoolResLoader"

local EventDispatcher = require "Framework.Basic.EventDispatcher"
AsynPrefabLoader = Class("AsynPrefabLoader", EventDispatcher)

local LoadingList = {} 			--- pfb 加载
local IconLoadingList = {} 		--- 图片加载
local PoolResLoadingList = {}	--- 使用PoolManager加载管理的pfb资源

function AsynPrefabLoader.Clear()

	LoadingList = {}
	IconLoadingList = {}
	PoolResLoadingList = {}

end

function AsynPrefabLoader:Ctor()

	EventDispatcher.Ctor(self)
	self.loadPath = nil
	self.loadedCallback = nil
	self.loadErrCallback = nil
	self.listener = nil

	LoadingList[tostring(self)] = self

end

function AsynPrefabLoader:Destroy()

	LoadingList[tostring(self)] = nil
end

function AsynPrefabLoader:Load(path, loadCallback, errCallback, listener, postion, rotation)
	self.loadPath = path
	self.loadedAssetCallback = loadCallback
	self.loadErrCallback = errCallback
	self.listener = listener

	----postion, rotation 必须同时不为空
	if postion and rotation then
		AssetManager.LoadAsset(path, Util.GetPathName(path), tostring(self), postion, rotation)
	else
		AssetManager.LoadAsset(path, Util.GetPathName(path), tostring(self))
	end
end

function AsynPrefabLoader:OnLoadEnd(path, obj)
	if self.loadedCallback then
		-- local pool = CheapUtil.PrefabPool.GetPool(path)
  --   	local pfb = pool:Spawn(true)
  --   	self.loadedCallback(self.listener, path, pfb)
    elseif self.loadedAssetCallback then
    	self.loadedAssetCallback(self.listener, path, obj)
	end
end


--------------------------------------------------------------
--====================公共模块================================
--------------------------------------------------------------
----加载完成后，回调
function AsynPrefabLoader.CallFromCS(key, path, obj)
	
	local self = LoadingList[key] 
	if self then
	  self:OnLoadEnd(path, obj)
	elseif IconLoadingList[key] then   ----图片加载

	  IconLoadCtrl.OnLoadedIcon(key, obj)
	  IconLoadingList[key] = IconLoadingList[key] - 1

	  if IconLoadingList[key] < 1 then
	  	IconLoadingList[key] = nil
	  end
	elseif PoolResLoadingList[key] then  
		PoolResLoader.OnPoolResLoaded(key, path, obj)
	else
		if error then error("加载的资源 " .. path .. " 没有被利用") end
		GameObject.Destroy(obj)
	end
end

----静态加载图片
function AsynPrefabLoader.LoadIcon(path, assetname, key, usepool)

	--缓存
	if IconLoadingList[key] then
		IconLoadingList[key] = IconLoadingList[key] + 1
	else
		IconLoadingList[key] = 1
	end

	--加载
	if usepool then
		PoolManager.GetResourceObject(path, assetname, 1, 1, key)
	else
		AssetManager.LoadAsset(path, assetname, key)
	end
end

function AsynPrefabLoader.AddPoolResLoadKey(key)
	
	PoolResLoadingList[key] = 1
end

function AsynPrefabLoader.RemovePoolResLoadKey(key)
	
	PoolResLoadingList[key] = nil
end

return AsynPrefabLoader