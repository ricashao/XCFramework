-- 设置角色头顶名字
local UIName = BaseClass("UIName")

local pos1;
local function Init(self)
    self.camera = GameLayerManager.GetCamera(self.cameraLayer)
    if not self.camera then
        if error then
            error("UIName camera can not nil")
        end
        return
    end
    if not self.character then
        return
    end

    self.type = self.character:GetType()
    self.planeDistance = GameLayerManager.GetCameraLayerPlaneDistance(self.cameraLayer)
    self.loadPath = "UI/Prefabs/Model/Win_SomethFly_Name"
    GameObjectPool:GetInstance():GetGameObjectAsync(path, BindCallback(self, self.OnPrefabLoad))
end

local function __init(self, character, cameraLayer, offset)
    self.pfb = nil
    self.nameTxt = nil
    self.name = ""
    self.color = nil
    self.camera = nil
    self.handPoint = nil
    self.type = nil
    self.loaded = false
    self.character = character
    self.cameraLayer = cameraLayer
    self.offset = offset
    self.planeDistance = nil
    self.rectTransform = nil
    self.visible = false
    Init(self)
end

local function OnPrefabLoad(self, pfb)
    self.pfb = pfb
    self.rectTransform = pfb:GetComponent(CS.UnityEngine.RectTransform)
    local txtTransform = pfb.transform:FindChild("et_text")
    self.nameTxt = txtTransform.gameObject:GetComponent("Text")

    GameLayerManager.AddGameObjectToCameraLayer(pfb, self.cameraLayer)
    self.loaded = true
    if self.color ~= nil then
        self.nameTxt.color = self.color
    end
    self.nameTxt.text = self.name

    self:SetVisible(self.character:IsVisible())
    self:UpdateTransformPos()
end

local function SetUIName(self, name, color)
    self.name = name
    self.color = color

    if not self.loaded then
        return
    end

    if not self.color then
        self.nameTxt.color = self.color
    end

    if not self.name then
        self.nameTxt.text = self.name
    end
end

local function LateTick(self, delta)
    self:UpdateTransformPos();
end

local function SetVisible(self, visible)
    self.visible = visible
    if self.pfb then
        self.pfb.gameObject:SetActive(visible)
    end
end

local function IsVisible(self)
    return self.visible
end

local function UpdateTransformPos(self)
    if not self.visible then
        return
    end

    if (not self.loaded) or (not self.character) then
        return
    end

    self.handPoint = self.character:GetModel():GetHandPos(CharacterHandPoint.Bottom)

    if self.handPoint == nil then
        self.handPoint = self.character:GetWorldPosition()
    end

    pos1 = self.handPoint + self.offset

    if (self.type == CHARACTER_TYPE.PLAYER) or (self.type == CHARACTER_TYPE.NPC) then
        if Camera.main then
            pos1 = CS.UnityEngine.Camera.main:WorldToScreenPoint(pos1)
        else
            return
        end
    elseif (self.type == CHARACTER_TYPE.WARRIOR) then
        pos1 = GameLayerManager.battleCamera:WorldToScreenPoint(pos1)
    else

    end

    if self.planeDistance then
        pos1.z = self.planeDistance
    end

    pos1 = self.camera:ScreenToWorldPoint(pos1)
    self.rectTransform.position = pos1
end

local function __delete(self)
    self.camera = nil
    self.character = nil
    self.isNeedToDestory = false
    GameObjectPool:GetInstance():RecycleGameObject(self.loadPath, self.pfb)
    self.loadPath = nil
    self.pfb = nil
    self.color = nil
end

UIName.__init = __init
UIName.OnPrefabLoad = OnPrefabLoad
UIName.SetUIName = SetUIName
UIName.LateTick = LateTick
UIName.SetVisible = SetVisible
UIName.IsVisible = IsVisible
UIName.UpdateTransformPos = UpdateTransformPos
UIName.__delete = __delete
return UIName