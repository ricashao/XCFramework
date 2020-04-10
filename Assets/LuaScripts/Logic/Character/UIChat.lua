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

UIChat.__init = __init
UIChat.OnPrefabLoad = OnPrefabLoad

return UIChat