---设置头顶聊天泡泡
local UIChat = BaseClass("UIChat")

local OFFSET = Vector3.New(0, 2, 0);
local path = "UI/Prefabs/Model/Win_Somethfly_ChatPao.prefab"

local function Init(self)
    if not self.character then
        return
    end

    --self.isBattle = characterType == CHARACTER_TYPE.WARRIOR
    self.isBattle = true
    self.cameraLayer = UILayers.GuiCamera_1_2.Name

    self.camera = GameLayerManager:GetInstance():GetCamera(self.cameraLayer)
    self.planeDistance = GameLayerManager.GetCameraLayerPlaneDistance(self.cameraLayer)
    GameObjectPool:GetInstance():GetGameObjectAsync(path, BindCallback(self, self.OnPrefabLoad))
end

local function __init(self, character)
    self.prefab = nil
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
    self.prefab = pfb
    self.rectTransform = pfb:GetComponent(typeof(CS.UnityEngine.RectTransform))
    self.bgRT = pfb.transform:Find("p_pic"):GetComponent(typeof(CS.UnityEngine.RectTransform))
    self.txt = pfb.transform:Find("p_pic/et_text"):GetComponent("Text")
    self.txtRT = self.txt.gameObject:GetComponent(typeof(CS.UnityEngine.RectTransform))
    self.maxWidth = self.txtRT.rect.width

    GameLayerManager:GetInstance():AddGameObjectToCameraLayer(pfb, self.cameraLayer)
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
    self.timer = nil
    self.message = nil
    if self.prefab then
        self.prefab.gameObject:SetActive(false)
    end
end

local function ShowChat(self, message)
    self.message = message
    if not IsNull(self.txt) and not IsNull(self.prefab) and self.message then
        self.prefab.gameObject:SetActive(true)
        -- 文本赋值前设置一次RectTransform可以避免出现Text.preferredHight取值错误的BUG
        self.txtRT.sizeDelta = Vector2.New(self.maxWidth, self.txtRT.sizeDelta.y)
        self.txt.text = message
        self:UpdateLayout()

        local time = 2
        if not self.timer then
            self.timer = TimerManager:GetInstance():GetTimer(time, self.TimerComplete, self, true, false)
        else
            self.timer:Reset()
        end

        self.timer:Start()
    end
end

local function LateTick(self, delta)
    if not self.loaded or not self.visible or IsNull(self.camera) or not self.character then
        return
    end

    self.handPoint = self.character:GetModel():GetHandPos(CharacterHandPoint.Bottom)
    if self.handPoint == nil then
        self.handPoint = self.character:GetWorldPosition()
    end

    if self.handPoint == nil then
        self = nil
        return false
    end

    local pos1 = self.handPoint + OFFSET

    pos1 = GameLayerManager:GetInstance().battleCamera:WorldToScreenPoint(pos1)

    if self.planeDistance then
        pos1.z = self.planeDistance
    end

    pos1 = self.camera:ScreenToWorldPoint(pos1)
    self.rectTransform.position = pos1
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
UIChat.LateTick = LateTick
UIChat.__delete = __delete

return UIChat