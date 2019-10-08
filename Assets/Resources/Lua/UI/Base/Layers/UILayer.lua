--[[
	每个UI层级也继承UIComponent
]]
UILayer = Class("UILayer", UIComponent)

require "UI.Base.Layers.UIComponentContainer"

local M = UILayer;

--定义每个层级的常量
M.MAP_UI_LAYER = "map_ui_layer"      			-- 地图UI层
M.SCENE_UI_LAYER = "scene_ui_layer"  			-- 场景UI
M.PANEL_LAYER = "panel_layer"        			-- 一级面板
M.CONFIRM_INFO_LAYER = "confirm_info_layer" 	-- 确认信息UI层
M.TIP_LAYER = "tip_layer"						-- tips UI层
M.SYSTEM_INFO_LAYER = "system_info_layer"    	-- 系统信息UI层

--@private 构造函数
--@param selfTransform 每个层级的transform，
--@param layeName 层级的名字
--@param dialogShowAlone 是否独占显示（一个layer同时只显示一个界面）
function M:Ctor(selfTransform, layerName, dialogShowAlone)

	self.layerName = layerName;
	self.currentShowDialog = nil;
	self.isDialogShowAlone = dialogShowAlone
	UIComponent.Ctor(self, selfTransform);
end

--@private 添加到子UIComponent列表
--@param uidialog 显示的UIDialog
function M:_AddUIComponent(uidialog)

	UIComponent._AddUIComponent(self, uidialog);
	UIManager:GetInstance():AddUIDialog(uidialog);
end

--@private 从子UIComponent列表中移除
--@uidialog 需要移除的Uidialog
function M:_RemoveUIComponent(uidialog)
	
	UIComponent._RemoveUIComponent(self, uidialog);
	UIManager:GetInstance():RemoveUIDialog(uidialog);
end

--@override protected 获取显示所在的UIComponent
function M:GetParentComponent()
	
	return M.layerParentComponent;
end

--@public 显示一个界面
function M:ShowDialog(uidialog)

	if self.isDialogShowAlone then
		if self.currentShowDialog ~= uidialog then
			if self.currentShowDialog then
				self.currentShowDialog:Close()
			end
		end
		self.currentShowDialog = uidialog
	end
end

--@public 关闭一个界面
function M:CloseDialog(uidialog)
	
	if self.isDialogShowAlone then
		if self.currentShowDialog == uidialog then
			self.currentShowDialog = nil
		end
	end
end

----------------------------------------------------------
--              public static 方法
---------------------------------------------------------
--@public static初始化
function M.InitLayers()

	M.layerList	= {};

	--uilayers 的父UIComponent
	M.layerParentComponent = UIComponentContainer.New();

	--和GameLayerManager中对应
	-- 地图UI层
	M.CreateLayer(GameLayerManager.GetMapUILayerTransform(), M.MAP_UI_LAYER, false);
	-- 场景UI层
	M.CreateLayer(GameLayerManager.GetSceneUILayerTransform(), M.SCENE_UI_LAYER, false);
	-- 一级界面界面UI层
	M.CreateLayer(GameLayerManager.GetPanelLayerTransform(), M.PANEL_LAYER, true);
	-- 确认信息UI层
	M.CreateLayer(GameLayerManager.GetInfoLayerTransform(), M.CONFIRM_INFO_LAYER, false);
	-- tips ui层
	M.CreateLayer(GameLayerManager.GetTipsLayerTransform(), M.TIP_LAYER, false);
	-- 系统信息UI层
	M.CreateLayer(GameLayerManager.GetSystemInfoLayerTransform(), M.SYSTEM_INFO_LAYER, false);
end

--@private 创建一个UILayer
--@param transform UILayer的selfTransform
--@param name UILayer的名字
--@dialogShowAlone UILayer上界面上是否独占（同时只显示一个界面）
function M.CreateLayer(transform, name, dialogShowAlone)

	M.layerList[name] = UILayer.New(transform, name, dialogShowAlone);
end

--@public static 
--@return 返回一个UILayer
function M.GetLayer(layerName)
	
	return M.layerList[layerName];
end

return M