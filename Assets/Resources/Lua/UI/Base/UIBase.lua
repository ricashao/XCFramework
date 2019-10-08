--[[
	基类
	只是作为UI资源的容器和解析器，不允许添加别的方法
--]]
local Object = require "Framework.Object";
UIBase = Class("UIBase", Object);
local M = UIBase;

--组件类型定义
-- local UIComponentsDef = require "UI.Base.UIComponentTypeDef";

--[[
	public 构造函数
--]]
function M:Ctor()
	self.childrenNameMap = {};
	self.childernComponentMap = {};
end

--[[
	protected 获取指定路径对象
	@param 	  path(string)    对象路径
	@return   对象(Transform) 需要获取的对象
--]]
function M:GetChildByPath(path)
	if not path or path == "" then 
		return nil;
	else
		local child = self.childrenNameMap[path];
		if not child then
			if error then error("prefab上没有找到: " .. path ) end
		end
		return child;
	end
end

--[[
	protected 解析路径
	@param transform 资源
--]]
function M:GenChildPathMap(transform)
	if not transform then
		if error then error("Source can't be nil when you want to gen transform child path map.") end
	end

	self.root = transform;
	---- 生成namemap
	local childern = transform:GetComponentsInChildren(Transform.GetClassType(), true);
	local count = childern.Length - 1;
	for i = 0, count do
		local temp = {};
		self:FindChildPath(childern[i], temp);
		local name = table.concat(temp, ".");
		self.childrenNameMap[name] = childern[i];
	end

	local UIComponentsDef = require "UI.Base.UIComponentTypeDef";
	----生成UIComponent组件
	childern = transform:GetComponentsInChildren(UIComponentScript.GetClassType(), true);
	count = childern.Length - 1;
	for i = 0, count do
		local com = childern[i]:GetComponent("UIComponentScript");
		if com then
			local componentType = com.componentType;
			if UIComponentsDef[componentType] then
				local temp = {};
				self:FindChildPath(childern[i].transform, temp);
				local name = table.concat(temp, ".");
				self.childernComponentMap[name] = UIComponentsDef[componentType].New(childern[i]);
			end
		end
	end
end

function M:GetChildUIComponentByPath(path)
	
	if not path or path == "" then 
		return nil;
	else
		local child = self.childernComponentMap[path];
		if not child then
			if error then error("没有找到UIComponent: " .. path) end
		end
		return child;
	end
end

--[[
	private 递归解析
	@param node(Transform) 递归节点
	@param t   (string)	   路径表
--]]
function M:FindChildPath(node, t)
	if not node then return end

	if node == self.root then
		table.insert(t, node.name);
	else
		local parent = node.parent;
		if parent then
			self:FindChildPath(parent, t);
		end
		table.insert(t, node.name);
	end
end

return M