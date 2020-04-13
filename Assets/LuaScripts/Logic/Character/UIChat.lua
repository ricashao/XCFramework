---设置头顶聊天泡泡
local UIChat = BaseClass("UIChat")

local POS = Vector3.zero;
local OFFSET = Vector3.New(0, 2, 0);
local path = "UI/Prefabs/Model/Win_Somethfly_ChatPao"

local function Init(self)
    if not self.character then
        return
    end

    local characterType = self.character:GetType()
    self.isBattle = characterType == CHARACTER_TYPE.WARRIOR
    self.isScene = (characterType == CHARACTER_TYPE.PLAYER) or (characterType == CHARACTER_TYPE.NPC)

    if self.isScene then
        self.cameraLayer = CameraLayer.MapUILayer
    elseif self.isBattle then
        self.cameraLayer = CameraLayer.GuiCamera_1_2
    end

    if not self.cameraLayer then
        return
    end

    self.camera = GameLayerManager.GetCamera(self.cameraLayer)
    self.planeDistance = GameLayerManager.GetCameraLayerPlaneDistance(self.cameraLayer)
    GameObjectPool:GetInstance():GetGameObjectAsync(path, BindCallback(self, self.OnPrefabLoad))
end

local function __init(self, character)
    self.pfb = nil
    self.message = nil
    self.loaded = false
    self.timer = nil        -- 计时器
    self.camera = nil
    self.isBattle = false
    self.isScene = false

    self.visible = false
    self.character = character
    self.planeDistance = nil
    Init(self)
end

local function OnPrefabLoad(self, pfb)
    self.rectTransform = pfb:GetComponent(CS.UnityEngine.RectTransform)
    self.bgRT = pfb.transform:FindChild("p_pic"):GetComponent("RectTransform")
    self.txt = pfb.transform:FindChild("p_pic/et_text"):GetComponent("Text")
    self.txtRT = self.txt.gameObject:GetComponent("RectTransform")
    self.maxWidth = self.txtRT.rect.width

    GameLayerManager.AddGameObjectToCameraLayer(pfb, self.cameraLayer)
    self.loaded = true
    if self.message and self.character:IsVisible() then
        self:SetVisible(true)
        self:ShowChat(self.message)
    else
        self:SetVisible(false)
    end
end

local function SetVisible(self, visible)
    self.visible = visible
    if self.prefab then
        self.prefab.gameObject:SetActive(false)
    end
end

local function IsVisible(self)
    return self.visible
end

local function TimerComplete(self)
    self.message = nil;
    if self.prefab then
        self.prefab.gameObject:SetActive(false);
    end
end

local function ShowChat(self, message)
    self.message = message
    if not IsNull(self.txt) and not IsNull(self.prefab) and self.message then
        self.prefab.gameObject:SetActive(true)
        -- 文本赋值前设置一次RectTransform可以避免出现Text.preferredHight取值错误的BUG
        self.txtRT.sizeDelta = Vector2.New(self.maxWidth, self.txtRT.sizeDelta.y)
        self.txt.text = message.msg
        self:UpdateLayout()

        local time = 3
        if not self.timer then
            self.timer = TimerManager:GetInstance():GetTimer(time, self.TimerComplete, self, true, true)
        else
            self.timer:Reset()
        end

        self.timer:Start()
    end
end

--自身布局
local function UpdateLayout(self)
    if not IsNull(self.txt) and not IsNull(self.txtRT) and not IsNull(self.bgRT) and not IsNull(self.rectTransform) then
        --文本宽高
        local preferredWidth = self.txt.preferredWidth
        local width = ((preferredWidth >= self.maxWidth) and self.maxWidth) or preferredWidth
        self.txtRT.sizeDelta = Vector2.New(width, self.txt.preferredHeight)
        -- 消息泡泡大小调整
        self.bgRT.sizeDelta = Vector2.New(
                math.abs(self.txtRT.anchoredPosition.x) + self.txtRT.sizeDelta.x + 20,
                math.abs(self.txtRT.anchoredPosition.y) + self.txtRT.sizeDelta.y + 5)
        self.rectTransform.sizeDelta = self.bgRT.sizeDelta
    end
end

local function __delete(self)
    GameObjectPool:GetInstance():RecycleGameObject(path, self.prefab)
    self.timer = nil
    self.prefab = nil
end

UIChat.__init = __init
UIChat.OnPrefabLoad = OnPrefabLoad
UIChat.SetVisible = SetVisible
UIChat.IsVisible = IsVisible
UIChat.ShowChat = ShowChat
UIChat.TimerComplete = TimerComplete
UIChat.UpdateLayout = UpdateLayout
UIChat.__delete = __delete

return UIChat