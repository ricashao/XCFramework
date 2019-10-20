local PrefabObject = require "UI.PrefabObject"
local TextTipItem = Class("TextTipItem", PrefabObject)
local M = TextTipItem;

--local itemMaxWith = 400;

local defaultTextHeight = 0;
local defaultBgHeight = 0;
local defaultBgWidth = 0;

function M:Ctor(content, posY)
	PrefabObject.Ctor(self);

	self.prefabCtrl = require "UI.Common.Model.UIPrefabCtrl".New()           --池操作
	self.itemSkin,self.isAddEpt = self.prefabCtrl:CreatePrefab("Win_Comm_Tip","UI/Prefabs/Win")

	if not self.itemSkin then
		return nil
	end
	self.itemSkin.transform:SetParent(GameLayerManager.GetSystemInfoLayerTransform(), false)

	self:AddAllGroupPrefabs(self.itemSkin)
	self:GenAllNameMap(self.itemSkin, "Root.systemtipslayer") 
	self.movePos = self:GetChildByPathName("Win_Comm_Tip.ep_bg_width-height")
	self.rectTransform = self.movePos.gameObject:GetComponent(typeof(RectTransform))
	self.rectTransform.anchoredPosition = Vector2.New(0, posY) --要回到原来位置
	self.infoText = self:GetChildByPathName("Win_Comm_Tip.ep_bg_width-height.et_text").gameObject:GetComponent("Text");
	
	--获取初始的预制体 各种高度
	if self.isAddEpt == false then
		defaultTextHeight = self.infoText.preferredHeight;
		defaultBgHeight = self.rectTransform.rect.height;
		defaultBgWidth = self.rectTransform.rect.width;
	end

	self.infoText.text = content;
	self:AdaptHeight();
end

--创建销毁计时
function M:StartCountdown(destroyTime)
	local delaycall = require "Framework.Timer".New(destroyTime, self.Destroy, self);    --销毁计时
	delaycall:Start();
end

--自适应高度
function M:AdaptHeight()
	local preferredHeight = self.infoText.preferredHeight;
	--背景自适应
	self.adpt = defaultBgHeight + preferredHeight - defaultTextHeight;
	if preferredHeight > defaultTextHeight then
		self.rectTransform.sizeDelta = Vector2.New(defaultBgWidth, self.adpt);
		self.infoText.alignment = UnityEngine.TextAnchor.MiddleLeft;
	end
end

function M:GetHeight()
	
	return self.adpt
end

function M:SetPosition(mvy)
	local position = self.rectTransform.anchoredPosition;
	self.rectTransform.anchoredPosition = Vector2.New(position.x, position.y + mvy);
end

--销毁文字提示框
function M:Destroy()
	self.infoText.alignment = CS.UnityEngine.TextAnchor.MiddleCenter;
	self.rectTransform.sizeDelta = Vector2.New(defaultBgWidth, defaultBgHeight);
	self.prefabCtrl:Destroy()			--池操作
	local TextTipItemCtrl = require "UI.CommMsgTip.SkinCtrl.TextTipCtrl"--预制体从ctrl列表中删除
	TextTipItemCtrl:GetInstance():RemoveItem()
end

return M


