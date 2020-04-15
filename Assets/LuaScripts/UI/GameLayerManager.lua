-- 游戏UI的所有的UI层级
local GameLayerManager = BaseClass("GameLayerManager", Singleton)

local function Init(self)
    local battleCameraObj = CS.UnityEngine.GameObject.Find("BattlerCamera")
    if battleCameraObj then
        CS.UnityEngine.Object.DontDestroyOnLoad(battleCameraObj)
        battleCamera = battleCameraObj:GetComponent("Camera")
    end
    self.battleCamera = battleCamera;

    self.guiCamera = UIManager:GetInstance().UICamera

    -- 所有可用的层级
    self.layers = {}

    local battlerNameCameraObj = CS.UnityEngine.GameObject.Find("BattlerNameCamera")
    CS.UnityEngine.Object.DontDestroyOnLoad(battlerNameCameraObj)
    self.battlerNameCamera = battlerNameCameraObj.gameObject:GetComponent("Camera");
    -- 初始化层
    local layers = table.choose(Config.Debug and getmetatable(UILayers) or UILayers, function(k, v)
        return type(v) == "table" and v.OrderInLayer ~= nil and v.Name ~= nil and type(v.Name) == "string" and #v.Name > 0
    end)

    local uimanager = UIManager:GetInstance()
    table.walksort(layers, function(lkey, rkey)
        return layers[lkey].OrderInLayer < layers[rkey].OrderInLayer
    end, function(index, layer)
        assert(self.layers[layer.Name] == nil, "Aready exist layer : " .. layer.Name)
        local go = CS.UnityEngine.GameObject(layer.Name)
        local trans = go.transform
        trans:SetParent(uimanager.transform)
        local new_layer = UILayer.New(uimanager, layer.Name)
        new_layer:OnCreate(layer, layer.CameraType == 0 and self.guiCamera or self.battlerNameCamera)
        self.layers[layer.Name] = new_layer
    end)

end

local function GetSystemInfoLayerTransform(self)
    return self:GetCameraLayerTransform(UILayers.SystemInfoLayer.Name)
end

local function GetCameraLayerTransform(self, cameraLayerName)
    if not cameraLayerName then
        return
    end

    local cameraLayer = self.layers[cameraLayerName];
    if cameraLayer then
        return cameraLayer.transform
    end
end

local function GetCamera(self, cameraLayerName)
    if not cameraLayerName then
        return
    end
    
    local cameraLayer = self.layers[cameraLayerName]
    if not cameraLayer then
        return
    end

    return cameraLayer:GetCamera()

end

local function GetCameraLayerPlaneDistance(self, cameraLayerName)
    if not cameraLayerName then
        return
    end

    local cameraLayer = self.layers[cameraLayerName]
    if not cameraLayer then
        return
    end

    return cameraLayer:GetPlaneDistance()
end

local function AddGameObjectToCameraLayer(self,go, cameraLayerName)
    if (not go) or (not cameraLayerName) then
        return;
    end

    local cameraLayer = self.layers[cameraLayerName];

    if not cameraLayer then
        if error then error("CameraLayerManager AddGameObjectToCameraLayer cameraLayer " .. cameraLayerName .. " is not exist") end;
        return;
    end
    go.transform:SetParent(cameraLayer.transform, false)
end


-- 析构函数
local function __delete(self)
    self.layers = nil
end

GameLayerManager.Init = Init
GameLayerManager.GetCameraLayerTransform = GetCameraLayerTransform
GameLayerManager.GetSystemInfoLayerTransform = GetSystemInfoLayerTransform
GameLayerManager.GetCameraLayerPlaneDistance = GetCameraLayerPlaneDistance
GameLayerManager.AddGameObjectToCameraLayer = AddGameObjectToCameraLayer
GameLayerManager.GetCamera = GetCamera
GameLayerManager.__delete = __delete
return GameLayerManager