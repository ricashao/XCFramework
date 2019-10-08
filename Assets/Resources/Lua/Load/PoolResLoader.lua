--[[

	使用poolmanager加载和管理资源, 使用后的资源需要手动放回池里。
]]
local Object = require "Framework.Object";
PoolResLoader = Class("PoolResLoader", Object);

local M = PoolResLoader

local poolLoaders = {}

----切换账号的时候，需要清理掉
function M.ClearLoaders()

	for k, _ in pairs(poolLoaders) do

		AsynPrefabLoader.RemovePoolResLoadKey(k)
	end
	poolLoaders = {}
end

function M:Ctor()
	
	self.loadPath = nil
	self.loadedCallback = nil
	self.loadErrCallback = nil
	self.listener = nil
	self.size = 0
	self.level = 1
end

--必须要调用到
function M:Destroy()

	local key = tostring(self)
	AsynPrefabLoader.RemovePoolResLoadKey(key)
	poolLoaders[key] = nil
end

--[[

     获取资源对象
     @param path 		资源路径
     @param assetName 	资源名称
     @param size 		池子大小，同一个资源大小先后赋值不同，则替换池子大小
     @param level 		对象池等级
     @param loadCallback 回调函数
     @param errCallback 加载失败回调函数（预留接口）
     @param passdata    回传参数
     @param position 	初始化坐标
     @param rotation 	初始化旋转
]]
function M:Load(path, size, level, loadCallback, errCallback, passdata, postion, rotation)
	
	self.loadPath = path
	self.loadedAssetCallback = loadCallback
	self.loadErrCallback = errCallback
	self.passdata = passdata
	self.size = size
	self.level = level

	local key = tostring(self)
	poolLoaders[key] = self
	AsynPrefabLoader.AddPoolResLoadKey(key)
	if postion and rotation then
		PoolManager.GetResourceObject(path, Util.GetPathName(path), size, level, key, postion, rotation)
	else
		PoolManager.GetResourceObject(path, Util.GetPathName(path), size, level, key)
	end
end

function M.OnPoolResLoaded(key, path, pfb)
	
	local loader = poolLoaders[key]
	if loader then
		loader.loadedAssetCallback(loader.passdata, path, pfb)
	else
		if error then error("PoolResLoader加载的资源" .. path .. "没有被使用") end
		GameObject.Destroy(pfb)
	end
end

----静态方法
function M.Recycle(obj)

	if not obj then return end

	PoolManager.Recycle(obj)
end

return M