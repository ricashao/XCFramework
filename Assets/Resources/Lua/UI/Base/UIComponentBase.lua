--[[
	具有加载功能的控件基类
--]]
local UIBase = require "UI.Base.UIBase";
UIComponentBase = Class("UIComponentBase", UIBase);
local M = UIComponentBase;

function M:Ctor()

	UIBase.Ctor(self)
	self.selfTransform = nil;
	self.loadPath = nil;
	self.loaded = false;
	self.inLoading = false;
	self.onLoadedCallBack = nil;

	self.loader = AsynPrefabLoader.New()
end

function M:Destroy()
	if self.loader then
		self.loader:Destroy();
		self.loader = nil;
	end

	if self.selfTransform then
		GameObject.Destroy(self.selfTransform.gameObject);
		self.selfTransform = nil;
	end

	self.childrenNameMap = nil;
end

--[[
	protected  加载资源
	@param path(string) 	   资源路径
	@param onloaded(function)  回调函数
--]]
function M:LoadResource(path, onloaded)
	if path == nil or path == "" then
		if error then error("Load resource path can't be nil or empty.") end
	end

	if self.inLoading then
		return
	end

	self.inLoading = true;
	self.onLoadedCallBack = onloaded;
	self.loadPath = path;
	self.loader:Load(path, self.OnLoadEnd, self.OnLoadErr, self);
end

--[[
	protected 加载完成
	@param path(string) 	资源路径
	@param pfb(GameObject)	加载到的资源
--]]
---protected 
function M:OnLoadEnd(path, pfb)
	self.selfTransform = pfb.transform;
	self.inLoading = false;
	self.loaded = true;
end

function M:OnLoadErr()
	-- TODO:
end

return M