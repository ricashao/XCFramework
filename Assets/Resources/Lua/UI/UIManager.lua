require "UI.GameLayerManager"
require "UI.BasicCtrl"
require "UI.Common.GameUIClickEvent"
require "UI.Common.ScrollPaneEvent"
require "UI.Common.Icon.IconLoadCtrl"
require "UI.Common.Color.ConvertColor"

require "UI.Base.UIComponent"
require "UI.Base.UIDialog"
require "UI.Base.Layers.UILayer"
--require "ConfigData/GenAltasImageSetCfg"

local Singleton = require "Framework.Singleton";
UIManager = Class("UIManager", Singleton);

local M = UIManager;

local zdelta = 0
function M:Ctor( ... )
	
	self.dialogList = {}
	self.uiDialogList = {}
	self.uicomponentList = UIComponentContainer.New();
	self.zIndex = 0
	self.zIndexStack = {}

	self.componentList = {};
	self.componentDict = {};
	self.componentListCache = {};

	self.clickList = {};
	self.clickListCache = {};
	self.clickIndex = {};

	self.clickListMulti = {};
	self.clickListCacheMulti = {};
	self.clickIndexMulti = {};

	--GenAltasImageSetCfg.Init();

	-- 初始化UI的层级
	GameLayerManager.Init();
	UILayer.InitLayers();

	DOTween.Init(true, true, CS.DG.Tweening.LogBehaviour.__CastFrom(1))

end

function M:AddDialog(dialog)

	self.dialogList[tostring(dialog)] = dialog
end

function M:RemoveDialog(dialog)

	self.dialogList[tostring(dialog)] = nil
end

--(废弃)
function M:GetZIndex()
	local maxIndex = table.getn(self.zIndexStack)
	self.zIndex = maxIndex + 1
	self.zIndexStack[self.zIndex] = 1
	return self.zIndex, zdelta
end

--（废弃）
function M:RemoveZIndex(index)
	
	self.zIndexStack[index] = nil
end

--=======================================================================================
--  			UIComponent模块
--=======================================================================================

function M:GetUIComponentContainer()
	
	return self.uicomponentList;
end


function M:AddUIDialog(uidialog)
	
	self.uiDialogList[tostring(uidialog)] = uidialog
end

function M:RemoveUIDialog(uidialog)
	
	self.uiDialogList[tostring(uidialog)] = nil
end

--=======================================================================================
--  			             UIComponent模块注册区域外点击
--=======================================================================================
function M:RegisterComponentClick(component, callBack, data)
	if not component then return end

	local key = tostring(component);

	-- 防止重复注册导致和按钮点击触发事件冲突
	if self.componentDict[key] then
		self:ForceComponentClick();
	end

	local target = {};
	target.key = key;
	target.component = component;
	target.callBack = callBack;
	target.data = data;

	table.insert(self.componentListCache, target);

	-- 在下一帧添加，确保不会和按钮点击触发的事件冲突
	local timer = require "Framework.Timer".New(1, self.RealRegisterComponentClick, self, false, true);
	timer:Start();
end

--[[
	注销点击视图区域外点击
--]]
function M:UnregisterComponentClick(component)
	if not component then return end
	local key = tostring(component);

	if not self.componentDict[key] then return end

	self.componentDict[key] = nil;
	for i, v in ipairs(self.componentList) do
		if v.key == key then
			table.remove(self.componentList, i);
			break
		end
	end
end

function M:RealRegisterComponentClick()
	local target = self.componentListCache[1];
	if not target then return end

	self.componentDict[target.key] = target;
	table.insert(self.componentList, target);
	table.remove(self.componentListCache, 1);
end

function M:CheckComponentClick(position)
	if not position then return end

	local length = table.maxn(self.componentList);
	if length == 0 then return end
	
	local first = self.componentList[length];
	if not first then return end

	local rectTransform = first.component:GetBgRectTransform();
	if not rectTransform then 
		if dibug then dibug("Component not found background rectTransform.") end
		return 
	end

	local bl = UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(rectTransform, position, GameLayerManager.guiCamera);
	if bl then return end		

	if first.callBack then
		first.callBack(first.component, first.data);
	end
end

function M:ForceComponentClick()
	local length = table.maxn(self.componentList);
	if length == 0 then return end

	local first = self.componentList[length];
	if not first then return end

	if first.callBack then
		first.callBack(first.component, first.data);
	end
end

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
--[[
	注册点击视图区域外点击 by jinwen

	listener 		--监听者（Controller或者GameObject对象）
	notCtrl			--如果值为false，触发时会直接调用Destroy方法
	callBack 		--触发函数
	data		

	Controller:
		UIManager:GetInstance():RegisterOutClick(self, false, callBack);

	Transform:
		UIManager:GetInstance():RegisterOutClick(gameObject, true, callBack, self);

	注意：
	1.不要对同一个对象进行重复监听！！！
	2.Ctrl对应的Dialog需要调用SetBackgroundRect(path)函数来设置背景区域，否则无法判断点击
		
		例：聊天设置界面

		ChatSettingDialog:
		function M:OnUIReady()
    		self:GenAllNameMap(self.m_pdlg);
    		-- 这里设置一下Dialog的背景矩形
    		self:SetBackgroundRect("ChatSettingWin.g_var.Group_Comm_Bg_d");
    		SingletonDialog.OnUIReady(self);
		end

		ChatSettingDialogCtrl:
		function M:OnSkinReady()
    		BasicCtrl.OnSkinReady(self);
    		-- 监听在Dialog加载完成后添加
    		UIManager:GetInstance():RegisterOutClick(self, false);
		end

	3.UIManager会自动关闭Dialog，回调函数主要用来进行其他自定义操作
	4.UIManager不会自动隐藏Transform，因为用到控制Transform的情况可能比较复杂，在回调函数中手动控制更好
--]]
function M:RegisterOutClick(listener, notCtrl, callBack, data)
	if not listener then return end
	local key = tostring(listener);

	-- 防止重复注册导致和按钮点击触发事件冲突
	if self.clickList[key] then
		self:ForceOutClick();
	end

	local target = {};
	target.key = key;
	target.listener = listener;
	target.notCtrl = notCtrl;
	target.callBack = callBack;
	target.data = data;

	local rectTransform = nil;
	if not notCtrl and listener.m_pSkin and listener.m_pSkin.rect then
		rectTransform = listener.m_pSkin.rect:GetComponent(RectTransform.GetClassType());
	elseif notCtrl then
		rectTransform = listener:GetComponent(RectTransform.GetClassType());
	else 
		error("Out click Register need dialog with background rect, please set it.");
	end

	target.rectTransform = rectTransform;

	table.insert(self.clickListCache, target);

	-- 在下一帧添加，确保不会和按钮点击触发的事件冲突
	local timer = require "Framework.Timer".New(1, self.RealRegisterOutClick, self, false, true);
	timer:Start();
end

--[[
	注销点击视图区域外点击
--]]
function M:UnregisterOutClick(listener)
	if not listener then return end
	local key = tostring(listener);

	if self.clickList[key] then
		self.clickList[key] = nil;

		local length = table.maxn(self.clickIndex);
		table.remove(self.clickIndex, length);
	end
end

function M:RealRegisterOutClick()
	if self.clickListCache[1] then
		local target = self.clickListCache[1];
		self.clickList[target.key] = target;
		table.insert(self.clickIndex, target.key);
		table.remove(self.clickListCache, 1);
	end
end

function M:CheckOutClick(position)
	local length = table.maxn(self.clickIndex);
	local topLevel = self.clickList[self.clickIndex[length]];

	if topLevel and topLevel.rectTransform then
		local bl = false;
		if not position then
			bl = false;
		else
			bl = UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(topLevel.rectTransform,
																position, GameLayerManager.guiCamera);
		end
		
		if not bl then
			if topLevel.callBack then
				if topLevel.notCtrl then
					topLevel.callBack(topLevel.data);
				else
					topLevel.callBack(topLevel.listener);
				end
			end

			if not topLevel.notCtrl then
				topLevel.listener:Destroy();
			end

		end
		
	end
	

	length = table.maxn(self.clickIndexMulti);
	topLevel = self.clickListMulti[self.clickIndexMulti[length]];
	if topLevel and topLevel.rectTransformTable then
		local bl = false;
		if not position then
			bl = false;
		else
			for _, rect in pairs(topLevel.rectTransformTable) do
				if not rect then
					return false;
				end
				if UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(rect,
																position, GameLayerManager.guiCamera) then
				bl = true;
				end
			end
			
		end
		
		if not bl then
			if topLevel.callBack then
				topLevel.callBack(topLevel.data);
			end
		end
	end
end

function M:ForceOutClick()
	local length = table.maxn(self.clickIndex);
	local topLevel = self.clickList[self.clickIndex[length]];
	if topLevel and topLevel.rectTransform then
		if topLevel.callBack then
			if topLevel.notCtrl then
				topLevel.callBack(topLevel.data);
			else
				topLevel.callBack(topLevel.listener);
			end
		end

		if not topLevel.notCtrl then
				topLevel.listener:Destroy();
		end
	end
end




-----------------------------
--多个RectTransform注册点击区域外关闭

function M:RegisterOutClickMulti(rectTransformTable, callBack, data)
	if not rectTransformTable then return end
	local key = tostring(rectTransformTable);

	--防止重复注册导致和按钮点击触发事件冲突
	if self.clickListMulti[key] then
		self:ForceOutClickMulti();
	end

	local target = {};
	target.key = key;
	target.listener = listener;
	target.callBack = callBack;
	target.data = data;
	target.rectTransformTable = rectTransformTable;

	table.insert(self.clickListCacheMulti, target);
	-- 在下一帧添加，确保不会和按钮点击触发的事件冲突
	local timer = require "Framework.Timer".New(1, self.RealRegisterOutClickMulti, self, false, true);
	timer:Start();
end

function M:RealRegisterOutClickMulti()
	if self.clickListCacheMulti[1] then
		local target = self.clickListCacheMulti[1];
		self.clickListMulti[target.key] = target;
		table.insert(self.clickIndexMulti, target.key);
		table.remove(self.clickListCacheMulti, 1);
	end
end

function M:ForceOutClickMulti()
	local length = table.maxn(self.clickIndexMulti);
	local topLevel = self.clickListMulti[self.clickIndexMulti[length]];
	if topLevel and topLevel.rectTransform then
		if topLevel.callBack then
			topLevel.callBack(topLevel.data);
		end
	end
end

function M:UnregisterOutClickMulti(listener)
	if not listener then return end
	local key = tostring(listener);

	if self.clickListMulti[key] then
		self.clickListMulti[key] = nil;
		local length = table.maxn(self.clickIndexMulti);
		table.remove(self.clickIndexMulti, length);
	end
end

function M:CheckOutClickMulti()
end
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

-- 进入战斗
function M:OnEnterBattle()
	
	for k, v in pairs(self.dialogList) do
		if v and v.m_pdlg and v.m_ctrlClass then
			local ctr = v.m_ctrlClass:GetInstanceNotCreate() 
			if ctr then 
				ctr:Destroy()
			end
		end
	end
	self.dialogList = {}
end

function M:LogOut()

	for k, v in pairs(self.dialogList) do
		if v and v.m_pdlg and v.m_ctrlClass then
			local ctr = v.m_ctrlClass:GetInstanceNotCreate() 
			if ctr then 
				ctr:Destroy()
			end
		end
	end
	self.dialogList = {}
end

-- 切换场景
function M:OnChangeScene()
	
end

function M:OnTouch(mousePosition, mouseUpState)
	self.mouseposition = mousePosition;
	self.mouseupstate = mouseUpState;
end


---/////////////////////////////////////////////////////////
--				从图集中加载一张图片 模块
--//////////////////////////////////////////////////////////

local imageSpriteLoadList = {}
local changeActiveList = {}
--@public 为一个transform的Image控件添加Sprite
--@param imageName 图片的名字，需要添加后缀
--@param uiTransform 
--@return
--[[

	Example:
	UIManager.SetUIImage("1002.png", self.skin.icon);
]]
function M.SetUIImage(imageName, uiTransform)
	
	--获取图片的路径
	local path = GenAltasImageSetCfg.GetImagePath(imageName);
	M.GetImageSpriteByPathAndName(path, imageName, uiTransform);
end

--@private 从图集中加载一张图并赋值给uiTransform的Image
--@param atlasPath 图集路径
--@param imageName 图片的名字
--@param uiTransform 显示图片的UI的Transfrom
--@return
function M.GetImageSpriteByPathAndName(atlasPath, imageName, uiTransform)

	if not uiTransform then

		if error then error("加载图集中的图片必须要有要显示的UI"); end
		return
	end

	if not atlasPath then
		if error then error(imageName .. "资源路径为空") end
		return
	end

	local data = {};
	data.listener = M;
	data.callback = M.OnImageSpriteLoadedForUI;
	data.uiTransform = uiTransform;

	local key = tostring(uiTransform);
	local com = uiTransform:GetComponent("UISetImageScript")
	if not com  then
		---- 添加此脚本主要是用来监听ui什么时候销毁，ui销毁后清理引用
		com = uiTransform.gameObject:AddComponent(UISetImageScript.GetClassType());
		com:SetKey(key);
		changeActiveList[key] = 1
		uiTransform.gameObject:SetActive(false)
	end

	imageSpriteLoadList[key] = data;
	ImageSetManager.GetImageSprite(atlasPath, imageName, key);

end

--@public 从图集中加载一张图
--@param imageName 图片的名字
--@param callback 加载完的回调函数
--@param listener 
--@param uiTransform 显示图片的UI的Transfrom
--@return
function M.GetImageSprite(imageName, callback, listener, uiTransform)
	
	if not uiTransform then

		if error then error("加载图集中的图片必须要有要显示的UI"); end
		return
	end

	local path = GenAltasImageSetCfg.GetImagePath(imageName);
	if not path then
		if error then error(imageName .. "资源路径为空") end
		return
	end

	local data = {};
	data.listener = listener;
	data.callback = callback;

	local key = tostring(uiTransform);
	local com = uiTransform:GetComponent("UISetImageScript")
	if not com  then
		---- 添加此脚本主要是用来监听ui什么时候销毁，ui销毁后清理引用
		com = uiTransform.gameObject:AddComponent(UISetImageScript.GetClassType());
		com:SetKey(key);
	end

	imageSpriteLoadList[key] = data;
	ImageSetManager.GetImageSprite(path, imageName, key);
end

--@private 从c#调用
function M.OnImageLoaded(sprite, key, name)
	
	if imageSpriteLoadList[key] then
		if imageSpriteLoadList[key].uiTransform then
			--OnImageSpriteLoadedForUI
			if changeActiveList[key] then
				imageSpriteLoadList[key].uiTransform.gameObject:SetActive(true)
				changeActiveList[key] = nil
			end
			imageSpriteLoadList[key].callback(imageSpriteLoadList[key].uiTransform, sprite, name);
		else
			imageSpriteLoadList[key].callback(imageSpriteLoadList[key].listener, sprite, name);

		end
	else
		--没有被使用,直接交回
		ImageSetManager.ReturnImageSprite(sprite);
	end
end

--@private 图片加载完成赋值给uiTransform
function M.OnImageSpriteLoadedForUI(uiTransform, sprite)
	
	if uiTransform then
		local com = uiTransform:GetComponent("Image")
		if com then
			com.sprite = sprite;
		else
			if uiTransform.parent then
				if error then error(uiTransform.parent.name.. ", " .. uiTransform.name .. "上没有找到Image Component") end
			else
				if error then error(uiTransform.name .. "上没有找到Image Component") end
			end
			ImageSetManager.ReturnImageSprite(sprite);
		end
	end
end

--@public static 从C#调用
function M.OnDestroyImageTransform(key)

	imageSpriteLoadList[key] = nil;
end

---////从图集中加载一张图片的模块结束



return M