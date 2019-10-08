SynLoader = {}

local M = SynLoader

----同步加载资源
function M.Load(path)
	
	return AssetManager.LoadAsset(path);
end

return M