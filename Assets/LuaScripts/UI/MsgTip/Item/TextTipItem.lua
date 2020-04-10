---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2020/3/31 14:40
---
local TextTipItem = BaseClass("TextTipItem")
local path = "UI/Prefabs/Common/Win_Comm_Tip.prefab"

local posY = 0

local defaultTextHeight = 0;
local defaultBgHeight = 0;
local defaultBgWidth = 0;

-- 初始化特效：资源已经被加载出来
local function InitGo(self, go)
    if IsNull(go) then
        return
    end
    self.gameObject = go
    self.transform = go.transform
end

local function __init(self, content, posy, callback)
    posY = posy
    self.isReady = false
    -- 资源加载
    GameObjectPool:GetInstance():GetGameObjectAsync(path, function(go, self)
        if self ~= nil then
            self:InitGo(go)
            self:OnCreate()
            self.infoText.text = content;
            self:AdaptHeight();
            if callback then
                callback(self)
            end
            self.isReady = true
        end
    end, self)
end

local function OnCreate(self)
    self.transform:SetParent(GameLayerManager:GetInstance():GetSystemInfoLayerTransform().transform, false)
    self.infoText = self.transform:Find("ep_bg_width-height/et_text").gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text))
    self.movePos = self.transform:Find("ep_bg_width-height")
    self.rectTransform = self.movePos.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
    self.rectTransform.anchoredPosition = Vector2.New(0, posY) --要回到原来位置
    self.transform.localScale = Vector3.one
    defaultTextHeight = self.infoText.preferredHeight;
    defaultBgHeight = self.rectTransform.rect.height;
    defaultBgWidth = self.rectTransform.rect.width;
end

--创建销毁计时
local function StartCountdown(self, destroyTime)
    self.timer = TimerManager:GetInstance():GetTimer(destroyTime, self.Destroy, self, true)
    self.timer:Start()
end

--自适应高度
local function AdaptHeight(self)
    local preferredHeight = self.infoText.preferredHeight;
    --背景自适应
    self.adpt = defaultBgHeight + preferredHeight - defaultTextHeight;
    if preferredHeight > defaultTextHeight then
        self.rectTransform.sizeDelta = Vector2.New(defaultBgWidth, self.adpt);
        self.infoText.alignment = CS.UnityEngine.TextAnchor.MiddleLeft;
    end
end

local function GetHeight(self)
    return self.adpt
end

local function SetPosition(self, mvy)
    local position = self.rectTransform.anchoredPosition;
    self.rectTransform.anchoredPosition = Vector2.New(position.x, position.y + mvy);
end

local function Destroy(self)
    self.timer:Stop()
    GameObjectPool:GetInstance():RecycleGameObject(path, self.gameObject)
    CommMsgTip:GetInstance():RemoveItem()
end

TextTipItem.__init = __init
TextTipItem.InitGo = InitGo
TextTipItem.OnCreate = OnCreate
TextTipItem.StartCountdown = StartCountdown
TextTipItem.AdaptHeight = AdaptHeight
TextTipItem.GetHeight = GetHeight
TextTipItem.SetPosition = SetPosition
TextTipItem.Destroy = Destroy

return TextTipItem