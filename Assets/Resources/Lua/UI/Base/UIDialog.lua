require "UI.Base.UIComponent";
UIDialog = Class("UIDialog", UIComponent)

local M = UIDialog

--[[
	@example:
	TestDialog:Open(args);
	TestDialog:Close();

	Show/Hide方法调用时必须判断Instance是否存在
	if TestDialog:HasInstance() then
		TestDialog:GetInstance():Show(args);
	end

	if TestDialog:HasInstance() then
		TestDialog:GetInstance():Hide();
	end	
--]]


-- Dialog的生命周期等级
M.LifeLevel = {
	DestroyImmediate = 1, -- 关闭后立即销毁			（不常用Dialog）
	DestroyLater = 2,	  -- 关闭后一段时间后销毁	（常用Dialog）
	DontDestroy = 3,	  -- 关闭后不销毁			（常驻Dialog）
}

--======================================================================================================================
--   											主要使用到的一些方法和属性
--======================================================================================================================
--[[
	@public 获取Dialog的生命周期等级，子类可覆写，默认立即销毁
--]]
function M:GetLifeLevel()
	return UIDialog.LifeLevel.DestroyImmediate;
end

--[[
	TODO 根据内存调整时间
	@protected 获取关闭后销毁的计时时间，子类可覆写
	当Dialog的生命周期等级设置为DestroyLater时生效
--]]
function M:GetDestroyLaterTime()
	return 300;
end

--[[
	@protected 获取资源的加载路径
--]]
function M:GetLayoutPath()
	return "";
end

--[[
	@protected 获取皮肤类
--]]
function M:GetSkinClass()
	return nil;
end

--[[
	@protected 	标志位，子类可覆写，默认false
	@return    	true:点击Dialog以外区域关闭Dialog
--]]
function M:IsClickOutClose()
	return false;
end

--[[
	@public 获取单例
--]]
function M:GetInstance()
	return self._instance;
end

--[[
	@public 是否已创建单例
	@return 若已创建返回true，否者为false
--]]
function M:HasInstance()
	return self._instance ~= nil;
end

--[[
	@protected Dialog的构造方法
--]]
function M:Ctor()
end

--[[
	@protected 打开并显示Dialog
--]]
function M:Open(args)
	if self._instance then
		if not self._instance:IsVisible() then
			self._instance:Show(args);
		end
	else
		self._instance = self.New();
		self._instance:InitDialog(args);
	end

	return self._instance;
end

--[[
	@protected 	关闭Dialog
	覆写UIComponent的Close方法，UIdialog Close的时候会先隐藏，过一段时间后销毁
--]]
function M:Close()
	if not self._instance then return false end

	self:OnClose();

	-- 注销区域外点击监听
	if self:IsClickOutClose() then
		UIManager:GetInstance():UnregisterComponentClick(self);
	end

	local level = self:GetLifeLevel();
	if level == UIDialog.LifeLevel.DestroyImmediate then
		self:StopCloseCountdown();
		self:Destroy();
	elseif level == UIDialog.LifeLevel.DestroyLater then
		self:Hide();
		self:StartCloseCountdown();
	elseif level == UIDialog.LifeLevel.DontDestroy then
		self:Hide();
	end

	self:GetParentComponent():CloseDialog(self);
end

--[[
	@protected 显示Dialog
--]]
function M:Show(args)
	UIComponent.Show(self, args);
	self:StopCloseCountdown();
	self:GetParentComponent():ShowDialog(self);
end

--[[
	@protected 隐藏Dialog
--]]
function M:Hide()
	UIComponent.Hide(self);
end

--[[
	@protected UI加载完成后调用，开始处理逻辑
--]]
function M:OnCreate()
end

--[[
	@protected 关闭前清理数据，覆写此方法
--]]
function M:OnClose()
end

--[[
	@protected 解析创建时或者显示时带入的model参数|数据
--]]
function M:ParseArgs(args)
end

--[[
	@protected 隐藏的界面再次显示的时候，会调用到此方法
--]]
function M:Refresh()
end

--[[
	@protected 获取UIDialog显示的transform parent，可以覆写此方法
--]]
function M:GetParentTransform()
	return UILayer.GetLayer(UILayer.PANEL_LAYER):GetTransform();
end

--[[
	@protected 获取UIdialog的父UIComponent
--]]
function M:GetParentComponent()
	return UILayer.GetLayer(UILayer.PANEL_LAYER);
end

--[[
	????
--]]
function M:IsModelState()
	return true;
end

--[[
	废弃方法
	@public 打开界面，如果之前隐藏了，调用refresh接口
	@return 创建好的单例
--]]
function M:GetInstanceAndShow( ... )
	return self:Open(...);
end

--[[
	废弃方法
	@public 创建单例，没有时不创建
	@return 已有的实例或者空值nil
--]]
function M:GetInstanceNotCreate()
	return self._instance;
end

--[[
	废弃方法
	@protected 覆写此方法（销毁时调用）
	每个界面销毁时，需要处理的逻辑写在这个函数里
--]]
function M:OnDestroyDialog()
end

--======================================================================================================================
--   												不开放的方法
--======================================================================================================================
--[[
	@private 开始初始化界面
	这么写是为了避免外面的继承类中Ctor方法忘了写UIDialog.Ctor(self)
--]]
function M:InitDialog(args)
	UIComponent.Ctor(self, args);
	self.closeTimer = nil;
end

function M:OnAfterCreate()
	if not self.selfTransform then return end

	local skin = self.skin and self.skin or self;
	local name = self.selfTransform.name;

	local path = nil;
	local paths = {
		name .. ".g_comm.Group_Comm_Bg_a",
		name .. ".g_comm.Group_Comm_Bg_b",
		name .. ".g_comm.Group_Comm_Bg_c",
		name .. ".g_comm.Group_Comm_Bg_d",
	};

	-- 设置背景
	local index = nil;
	for i, v in ipairs(paths) do
		if skin.childrenNameMap[v .. ".p_bg"] then
			index = i;
			path = v;
			self:SetBackground(v .. ".p_bg");
			break
		end
	end

	local closePath = nil;
	if index == 1 or index == 2 then
		closePath = path .. ".Group_Btn_S_a";
	else
		closePath = name .. ".Group_Btn_S_a";
	end

	-- 添加关闭按钮点击监听事件
	if closePath then
		local closeBtn = skin:GetChildByPath(closePath);
		if closeBtn then
			GameUIClickEvent.AddListener(closeBtn, "ebtn", M.HandleCloseBtnClick, self);
		end
	end

	-- 添加区域外点击关闭监听事件
	if self:IsClickOutClose() then
		UIManager:GetInstance():RegisterComponentClick(self, M.HandleOutClick);
	end
end

function M.HandleOutClick(self)
	self:Close();
end

function M.HandleCloseBtnClick(go, self)
	self:Close();
end

--[[
	@private 销毁时调用的逻辑，不要覆写此方法
--]]
function M:OnDestroy()
	local mtable = getmetatable(self)
	if mtable and mtable._instance then
		local self = mtable._instance;
		-- self:OnDestroyDialog();
		self:StopCloseCountdown();
		self:GetParentComponent():CloseDialog(self);
		mtable._instance = nil;
	end	

	-- A.Destroy()
	if self._instance then
		self._instance:StopCloseCountdown();
		-- self._instance:OnDestroyDialog();
		self._instance:GetParentComponent():CloseDialog(self._instance);
		self._instance = nil;
		return
	end
end

--[[
	@private 开始销毁倒计时
--]]
function M:StartCloseCountdown()
	if not self.closeTimer then
		self.closeTimer = require "Framework.Timer".New(1, self.CheckCloseTime, self, true);
	end
	self.lastHitTime = GetServerTime();
	self.closeTimer:Start();
end

--[[
	@private 停止销毁倒计时
--]]
function M:StopCloseCountdown()
	if self.closeTimer then
		self.closeTimer:Stop();
	end
end

--[[
	@private 检测是否可以销毁
--]]
function M:CheckCloseTime()
	if GetServerTime() - self.lastHitTime > 300 then -- 5 * 60
		self:StopCloseCountdown(); --优先移除掉tick
		self:Destroy();
	end
end

return M