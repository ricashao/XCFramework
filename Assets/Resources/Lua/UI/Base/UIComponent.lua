--[[
	所有UI控件的基础类
]]
require "UI.Base.UIComponentBase";
require "UI.Base.UISkin";
UIComponent = Class("UIComponent", UIComponentBase)

local M = UIComponent;

--[[
	@example
	local component = UIComponent.New(transform);		-- 使用已有transfrom创建，不带model参数|数据
	local component = UIComponent.New(transform, args);	-- 使用已有transfrom创建，带model参数|数据

	local component = UIComponent.New();				-- 加载资源创建，不带model参数|数据
	local component = UIComponent.New(args);			-- 加载资源创建，带model参数|数据
--]]

--======================================================================================================================
--   											主要使用到的一些方法
--======================================================================================================================

--[[
	@public 构造方法
	两种方式：1.使用已有的transfrom创建UIComponent
			  2.加载资源创建UIComponent

	@param selfTransform 	已有的transfrom，如果不传就执行加载资源创建UIComponent
	@param args 			初始化时需要的model参数|数据
--]]
function M:Ctor(selfTransform, args)
	UIComponentBase.Ctor(self);

	self.inited = false;
	self.visible = true;			-- 默认加载完成后显示

	self.parentComponent = nil;		-- 逻辑父UIComponent
	self.parentTransform = nil;   	-- 资源父Transform
	
	self.cmpChildren = {};			-- 子UIComponent
	self.cmpChildrenKeyValue = {};	-- 防止重复添加的验证table
	self.childrenCount = 0;
	self.childrenLoadedCount = 0;
	
	self.skin = nil;
	self.skincls = nil;

	self.eventDict = {};			-- 广播事件表
	self.eventRegistered = false;	-- 广播事件是否注册 

	self.parseArgs = nil;			-- 由构造方法带入的需要解析的model参数|数据

	self:Init(selfTransform, args);
end

--[[
	@protected 	资源的加载路径
--]]
function M:GetLayoutPath()
	return "";
end

--[[
	@protected 	皮肤类
--]]
function M:GetSkinClass()
	return self.skincls;
end

--[[
	@protected 		处理带入的model参数|数据
	@param 	  args 	创建时或者显示时带入的model参数|数据
--]]
function M:ParseArgs(args)
end

--[[
	@protected 	全局刷新方法
--]]
function M:Refresh()
end

--[[
	@public 显示
--]]
function M:Show(args)
	self.parseArgs = args;
	self:SetVisible(true);
end

--[[
	@public 隐藏
--]]
function M:Hide()
	self:SetVisible(false);
end

--[[
	@public: 关闭（销毁）调用的方法(仅有的对外关闭接口, 不要覆写此方法)
--]]
function M:Close()
	self:OnClose();
	self:Destroy();
end

--[[
	@protected 销毁前清理数据，覆写此方法
--]]
function M:OnClose()
end

--[[
	废弃方法
	@protected 销毁前清理数据，覆写此方法
--]]
function M:OnDestroy()
	--覆写此方法
end

--[[
	@protected 资源准备好后，开始处理逻辑，覆写此方法
--]]
function M:OnCreate()
	--覆写此方法
end

--[[
	@public 				在最前面添加一个子UIComponent
	@param UIComponent 		子UIComponent
--]]
function M:AddChildAsFirst(childComponent)
	self:_AddChild(childComponent, 1);
end

--[[
	@public 				添加子UIComponent
	@param childComponent 	子UIComponent
--]]
function M:AddChild(childComponent)
	
	self:_AddChild(childComponent);
end

--[[
	@public 				移除子UIComponent
	@param childComponent 	需要移除的子UIComponent
--]]
function M:RemoveChild(childComponent)

	if not childComponent then
		if error then error("无法移除空对象"); end
		return;
	end
	childComponent:SetParentTransform(nil);
	childComponent:SetParentComponent(UIManager:GetInstance():GetUIComponentContainer());

end

--[[
	@public 统一注册广播事件接口
			后三个参数和BroadcastEvent:Add()方法参数一致
			走统一接口的事件监听会根据IsHideRemoveEvent标志位在Show/Hide时添加/移除事件监听
			
	@param broadcaseEvent 	广播事件实例
	@param func				回调方法
	@param object			
	@userdata				
--]]
function M:AddBroadcastEventListener(broadcaseEvent, func, object, userdata)
	if not broadcaseEvent or not func then
		if error then error("UIComponent:RegisterEvent() function need parameter broadcaseEvent and func.") end
	end

	local key = tostring(broadcaseEvent) .. "@" .. tostring(func);
	if self.eventDict[key] then
		if dibug then dibug("UIComponent repeat register event.") end
	else
		local target = {};
		target.event = broadcaseEvent;
		target.func = func;
		target.object = object;
		target.userdata = userdata;
		self.eventDict[key] = target;
	end
end

--[[
	@public 统一注销广播事件接口
--]]
function M:RemoveBroadcastEventListener(broadcaseEvent, func, object)
	if not broadcaseEvent or not func then
		if error then error("UIComponent:UnregisterEvent() function need parameter broadcaseEvent and func.") end
	end

	local key = tostring(broadcaseEvent) .. "@" .. tostring(func);
	if self.eventDict[key] then
		self.eventDict[key] = nil;
	end
end

--[[
	@public UIComponent置灰
--]]
function M:Gray()

	self:_SetGray();
end

--[[
	@public UIComponent 由置灰变亮
--]]
function M:DeGray()
	
	self:_DeGray();
end

--[[
	@protected 在OnCreate前调用
--]]
function M:OnBeforeCreate()
	if self.skin == nil and self:GetSkinClass() then
		self.skin = self:GetSkinClass().New();
		self.skin:OnCreate(self.selfTransform);
	end
end

--[[
	@protected 在OnCreate之后调用
--]]
function M:OnAfterCreate()
end

--======================================================================================================================
--   													  属性
--======================================================================================================================
--[[
	@public 	获取UIComponent的prefab是否已准备好
	@return 	true:已准备好， false:还没有准备好
--]]
function M:IsLoaded()
	return self:GetTransform() ~= nil;
end

--[[
	@public 是否显示
	@return 如果显示中，返回true，否则为false
--]]
function M:IsVisible()
	if self.parentComponent and self.parentComponent.IsUIComponent then
		return self.visible and self.parentComponent:IsVisible()
	end
	return self.visible;
end

--[[
	@public 标志位，是否隐藏时移除事件监听，子类可以覆写

	@return true：	隐藏时移除广播事件监听
			false：	隐藏时不移除广播事件监听
--]]
function M:IsHideRemoveEvent()
	return true;
end

--======================================================================================================================
--   												   Get/Set方法
--======================================================================================================================
--[[
	@public 获取自己的transform
--]]
function M:GetTransform()
	return self.selfTransform
end

--[[
	@public 获取子UIComponent列表
--]]
function M:GetChildrenComponent()
	return self.cmpChildren;
end

--[[
	@protected 获取父UIComponent
--]]
function M:GetParentComponent()
	if not self.parentComponent then
		self:SetParentComponent(self:GetRootComponent());
	end

	return self.parentComponent;
end

--[[
	@public 获得背景RectTransform
--]]
function M:GetBgRectTransform()
	return self.bgRectTransfrom;
end

--[[
	@public 设置已创建好的皮肤
--]]
function M:SetSkin(skin)
	if not skin then
		if error then error("Set skin can't be nil.") end
	end

	self.skin = skin;
end

--[[
	TODO 统一背景路径后可以移除该方法，该方法供临时使用
	@public 设置背景，在资源加载完调用
	@param path 背景路径
--]]
function M:SetBackground(path)
	if not path then return end

	local bg = nil;
	if self.skin then
		bg = self.skin:GetChildByPath(path)
	else
		bg = self:GetChildByPath(path);
	end

	if bg then
		self.bgRectTransfrom = bg:GetComponent("RectTransform");
	else
		if error then error("Wrong background path.") end
	end
end

--[[
	@public 设置图片（图集上的图片）
--]]
function M:SetImageSprite(imageName)
	UIManager.SetUIImage(imageName, self:GetTransform());
end

--======================================================================================================================
--   													私有方法
--======================================================================================================================
--[[
	@private 				初始化方法
	@param selfTransform 	已有的transfrom，如果不传就执行加载资源创建UIComponent
	@param args 			初始化时需要的model参数|数据
--]]
function M:Init(selfTransform, args)
	if self.inited then return end
		
	self.inited = true;

	local realSelfTransform = nil;
	self.parseArgs = nil;

	if selfTransform then
		-- 传入了第一个参数
		if type(selfTransform) == 'userdata' then
			-- 第一个参数是userdata类型，说明传入了Transfrom
			realSelfTransform = selfTransform;
			self.parseArgs = args;
		else
			-- 第一个参数不是userdata类型，说明传入了初始化需要的参数或者数据
			self.parseArgs = selfTransform;
		end
	end

	if realSelfTransform then
		self.selfTransform = realSelfTransform;
		self.parentTransform = realSelfTransform.parent;

		self:AddComponentScript();

		self.parentComponent = self:GetParentComponent();
		self:ResetChildrenComponent();

		self:OnBeforeCreate();
		self:OnCreate();
		self:OnAfterCreate();

		self:SetVisible(self.visible, true);
		self:Refresh();
	else
		local path = self:GetLayoutPath();
		self:LoadResource(path);
	end
end

--[[
	@private   处理带入的model参数|数据
--]]
function M:HandleArgs()
	self:ParseArgs(self.parseArgs);
	self.parseArgs = nil;

	-- self:Refresh();
end

--[[
	@private 资源加载后的回调
--]]
function M:OnLoadEnd(path, pfb)
	UIComponentBase.OnLoadEnd(self, path, pfb);
	
	self:AddComponentScript();

	self:OnBeforeCreate();
	self:OnCreate();
	self:OnAfterCreate();

	self.parentComponent = self:GetParentComponent();

	if self.parentComponent.IsUIComponent then
		self.parentComponent:OnChildLoaded(self);
	else
		self:SetParentTransform(self:GetParentComponent():GetTransform(), false);
	end

	self:SetVisible(self.visible, true);
	self:Refresh();
end

--@private 挂载UIComponentScript脚本
function M:AddComponentScript()
	
	local com = self.selfTransform:GetComponent("UIComponentScript");
	if not com then
		com = self.selfTransform.gameObject:AddComponent(UIComponentScript.GetClassType());
		com.uicomponent = self;
		-- com.uiComponentName = self.selfTransform.name;
	else
		if dibug then dibug("【UIComponent】" .. com.name .. " 已经创建过UIComponent") end
	end
end

--[[
	@private 				添加子UIComponent
	@param childComponent 	子UIComponent
	@param position 		位置
--]]
function M:_AddChild(childComponent, position)
	
	if not childComponent then
		if error then error("UIComponent无法添加空对象"); end
		return;
	end

	if not self:GetTransform() then
		if error then error("UIcomponent的transform为空") end
		return;
	end

	--添加到父UIComponent列表，保持加入的顺序
	childComponent:SetParentComponent(self, position);

	--如果已加载完成添加到，父transform
	if childComponent:GetTransform() ~= nil then

		childComponent:SetParentTransform(self:GetTransform());
		if position and position > 0 then
			childComponent:GetTransform():SetSiblingIndex(position - 1);
		end
	end
end

--[[
	@private 设置父容器
	@param worldPositionStays 是否保持原始世界坐标
--]]
function M:SetParentTransform(transform, worldPositionStays)

	if not self.selfTransform then
		return;
	end

	self.parentTransform = transform;
	if transform then

		if self.selfTransform.parent ~= transform then

			if not worldPositionStays then worldPositionStays = false end
			self.selfTransform:SetParent(transform, worldPositionStays);

			--标记一下，方便查看
			-- if self.parentComponent.selfTransform then
			-- 	local com = self.selfTransform:GetComponent("UIComponentScript");
			-- 	com.uiComponentName = self.parentComponent.selfTransform.name;
			-- end
		end
	else
		--移除后放置到固定的地方暂存
		self.selfTransform:SetParent(self:GetParentLayer());
	end
end

--[[
	@privtae 获取父transform
--]]
function M:GetParentTransform()

	----如果没有父容器，默认显示在固定的层级上
	if self.parentTransform == nil then
		self.parentTransform = self:SetParentTransform(self:GetParentLayer());
	end
	return self.parentTransform;
end

--[[
	@private 默认放置的地方
--]]
function M:GetParentLayer()
	
	return GameLayerManager.GetPanelLayerTransform();
end

--[[
	@private 设置父UIComponenet
--]]
function M:SetParentComponent(component, position)
	
	if not component then
		if error then error("无法设置空对象为UIcomponent的父容器") end
		return;
	end

	if self.parentComponent == component then
		if info then info("无需重复设置同一个父容器") end
		return;
	end

	if self.parentComponent then
		self.parentComponent:_RemoveUIComponent(self);
	end
	self.parentComponent = component;
	self.parentComponent:_AddUIComponent(self, position);
end

--[[
	@private 重新设置父UIComponent
--]]
function M:ResetChildrenComponent()
	if not self.parentComponent or not self.parentComponent.IsUIComponent then return end

	local list = self.parentComponent:GetChildrenComponent();
	for i, v in ipairs(list) do
		if v:GetRootComponent() == self then
			v:SetParentComponent(self);
			i = i - 1;
		end
	end
end

--[[
	@private 遍历查找父UIComponent
--]]
function M:FindParent(selfTransform)

	if selfTransform and not self.finded then
		local com = selfTransform:GetComponent("UIComponentScript");
		if com then
			self.finded = com.uicomponent;
			return self.finded;
		else
			self:FindParent(selfTransform.parent);
		end
	end
	return self.finded;
end

--[[
	@private 获取默认的父UIComponent
--]]
function M:GetRootComponent()
	
	self.finded = nil

	local component = nil;
	if self.selfTransform then

		component = self:FindParent(self.selfTransform.parent);
	else
		if dibug then dibug("selfTransform is nil when get ParentComponent") end
	end
	
	if not component then
		component =  UIManager:GetInstance():GetUIComponentContainer();
	end

	return component;
end

--[[
	@private 添加到子UIComponent列表
	@param uicomponent 子UIComponent
	@param position  位置，可以为空
	@return
--]]
function M:_AddUIComponent(uicomponent, position)
	if not uicomponent then
		if error then error("无法添加空对象UIComponent") end;
		return;
	end

	local key = tostring(uicomponent);
	if self.cmpChildrenKeyValue[key] then
		return;
	end
	self.childrenCount = self.childrenCount + 1;
	self.cmpChildrenKeyValue[key] = uicomponent;
	if position and position > 0 then
		table.insert(self.cmpChildren, position, uicomponent);
	else
		table.insert(self.cmpChildren, uicomponent);
	end
end

--[[
	@private 从子UIComponent列表中移除
--]]
function M:_RemoveUIComponent(uicomponent)
	
	if not uicomponent then
		if error then error("无法移除空对象UIComponent") end;
		return;
	end

	local key = tostring(uicomponent);
	if not self.cmpChildrenKeyValue[key] then
		return;
	end

	for i, v in ipairs(self.cmpChildren) do
		if v == uicomponent then
			self.childrenCount = self.childrenCount - 1;
			table.remove(self.cmpChildren, i);
			break;
		end
	end
	self.cmpChildrenKeyValue[key] = nil;
end

--[[
	@private 子对象准备好的回调方法
--]]
function M:OnChildLoaded(childComponent)
	
	self.childrenLoadedCount = self.childrenLoadedCount + 1;

	childComponent:SetParentTransform(self:GetTransform(), false);

	self:CheckChildrenIsAllLoaded();

end

--[[
	@private 检测所有子UIComponent是否已加载完成
--]]
function M:CheckChildrenIsAllLoaded()
	
	if self.childrenCount > 0 and self.childrenCount == self.childrenLoadedCount then
		self:OnAllChildrenLoaded();
	end
end

--[[
	@protected 所有的子UIComponent已加载完毕, 设置显示的顺序
--]]
function M:OnAllChildrenLoaded()
	
	--NOTICE: 这里假设所有的子UIComponent都是加载完成的，而且需要排序
	--如果存在非加载的子UIComponent,就会有问题
	for i, v in ipairs(self.cmpChildren) do

		if v:GetTransform() and v:GetTransform():GetSiblingIndex() ~= i - 1 then

			v:GetTransform():SetSiblingIndex(i - 1);
		end

	end

end

--[[
	@private:销毁，不要覆写，不要调用
--]]
function M:Destroy()
	self:ClearBroadcastEventListeners();
	self.parentComponent:_RemoveUIComponent(self);
	self:OnDestroy();
  
  	local temp = {}
  	for k, v in pairs(self.cmpChildren) do
  		temp[k] = v
  	end

	for _, v in pairs(temp) do

		v:Destroy();
	end

	UIComponentBase.Destroy(self);
end

--[[
	@private 设置visible
--]]
function M:SetVisible(visible, force)
	if self.visible == visible and not force then
		return
	end

	self.visible = visible;
	if self.selfTransform then
		self.selfTransform.gameObject:SetActive(visible);

		if visible then
			self:HandleArgs();
			self:RealRegisterBroadcastEvent();
		elseif self.IsHideRemoveEvent() then
			self:RealUnregisterBroadcastEvent();
		end
	end
end

--[[
	@private 和其他UIComponent容器作区分
--]]
function M:IsUIComponent()
	return true;
end

--[[
	@private 执行添加事件监听
--]]
function M:RealRegisterBroadcastEvent()
	if self.eventRegistered then return end

	for k, v in pairs(self.eventDict) do
		local broadcaseEvent = v.event;
		local func = v.func;
		local object = v.object;
		local userdata = v.userdata;
		broadcaseEvent:Add(func, object, userdata);
	end

	self.eventRegistered = true;
end

--[[
	@private 执行移除事件监听
--]]
function M:RealUnregisterBroadcastEvent()
	if not self.eventRegistered then return end

	for k, v in pairs(self.eventDict) do
		local broadcaseEvent = v.event;
		local func = v.func;
		local object = v.object;
		broadcaseEvent:Del(func, object);
	end

	self.eventRegistered = false;
end

--[[
	@private 销毁时清除所有广播事件监听和广播事件表
--]]
function M:ClearBroadcastEventListeners()
	self:RealUnregisterBroadcastEvent();
	self.eventDict = {};
end

--[[
	@private UIComponent置灰
--]]
function M:_SetGray()
	
	--图片置灰
	local mat = MatLoadCtrl.GetMat("ui_gray", "UI/Materials");
	local images = self:GetImagesCmp();
	for k, v in pairs(images) do
		v.material = mat;
	end

	--文字置灰
	local texts = self:GetTextsCmp();
	for k, v in pairs(texts) do
		v:Gray();
	end
end

--[[
	@private UIComponent由置灰变亮
--]]
function M:_DeGray()
	
	--图片置灰
	local images = self:GetImagesCmp();
	for k, v in pairs(images) do
		v.material = nil;
	end
	
	--文字置灰
	local texts = self:GetTextsCmp();
	for k, v in pairs(texts) do
		v:Degray();
	end
end

--[[
	@private 获取所有的文字
--]]
function M:GetTextsCmp()
	
	require "UI.Component.GText"
	if self.textsCmp == nil then
		self.textsCmp = {};
		local childern = self.btn:GetComponentsInChildren(UIText.GetClassType());
		local count = childern.Length - 1;
		for i = 0, count do
			table.insert(self.textsCmp, GText.New(childern[i].gameObject));
		end
	end

	return self.textsCmp;
end

--[[
	@private 获取所有的图片（Image和RawImage）
--]]
function M:GetImagesCmp()

	if self.imagesCmp == nil then
		self.imagesCmp = {};
		local childern = self.btn:GetComponentsInChildren(UnityEngine.UI.Image.GetClassType());
		local count = childern.Length - 1;
		for i = 0, count do
			table.insert(self.imagesCmp, childern[i]);
		end
	end

	return self.imagesCmp;
end

return M