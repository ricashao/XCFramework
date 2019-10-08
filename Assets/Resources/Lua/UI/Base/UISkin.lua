--[[
	皮肤类

	只是作为UI资源的容器和解析器，不允许添加别的方法
--]]
local UIBase = require "UI.Base.UIBase";
UISkin = Class("UISkin", UIBase);
local M = UISkin;

--[[
	public 构造函数
	@param transform 资源
--]]
function M:Ctor(transform)
	UIBase.Ctor(self)

	if not transform then
		if error then error("UI Skin need a transform.") end
	else
		self.selfTransform = transform;
		self:OnCreate(transform);
	end 
end

--[[
	public 初始化函数
	@param transform 
--]]
function M:OnCreate(transform)
end

return M