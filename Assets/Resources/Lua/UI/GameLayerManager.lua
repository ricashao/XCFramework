
-- 游戏UI的所有的UI层级

GameLayerManager = {};
GameLayerManager.__index = GameLayerManager;

require "Load.AsynPrefabLoader";
require "UI.Component.GButton";
require "UI.UICommonManager";
require "UI.GameCameraLayerCommon";
require "Load.SynLoader"

local M = GameLayerManager;

local Layer = require "UI.Layer";
local depth = 100;
local distanceDelta = 100

local LAYER_DISTANCE = 
{
	ToplayerDistance     = 1;
	SystemInfoLayerDistance = 2;
	TipsLayerDistance    = 3;
	InfoLayerDistance    = 4;
	PanelLayerDistance   = 5;
	SceneUILayerDistance = 6;
	MapUILayerDistance   = 7;
	BattlerLayerDistance = 8;
}

--初始化层级
function M.Init()
	
	local battleCameraObj =  GameObject.Find("BattlerCamera");
	local battleCamera;
	if battleCameraObj then
		battleCamera = battleCameraObj:GetComponent("Camera");
	end
	M.battleCamera = battleCamera;

	local guiCamera = ioo.guiCamera.gameObject:GetComponent("Camera");
	guiCamera.transform.position = Vector3(0, 0, 100)
	M.guiCamera = guiCamera;

	local battlerNameCameraObj = GameObject.Find("BattlerNameCamera");
	M.battlerNameCamera = battlerNameCameraObj.gameObject:GetComponent("Camera");

	M.trdModelSite    = M.Create3DModelCameraSite();
	M.characterModelSite = M.CreateCharacterModelSite();
	-- 地图UI层     mapUILayer
	M.CreateCameraLayer(M.guiCamera, CameraLayer.MapUILayer, 10, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.MapUILayerDistance));         
	-- 场景界面层   sceneUILayer 
	M.CreateCameraLayer(M.guiCamera, CameraLayer.SceneUILayer, 20, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.SceneUILayerDistance));
	-- 面板层       panelLayer     
	M.CreateCameraLayer(M.guiCamera, CameraLayer.PanelLayer, 30, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.PanelLayerDistance));
	--确认信息层   infoLayer    
	M.CreateCameraLayer(M.guiCamera, CameraLayer.InfoLayer, 40, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.InfoLayerDistance));
	-- tips层   tipsLayer    
	M.CreateCameraLayer(M.guiCamera, CameraLayer.TipsLayer, 50, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.TipsLayerDistance));
	-- 系统信息层   systeminfoLayer    
	M.CreateCameraLayer(M.guiCamera, CameraLayer.SystemInfosLayer, 60, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.SystemInfoLayerDistance));
	-- UI界面中最先前的层 如Loading条
	M.CreateCameraLayer(M.guiCamera, CameraLayer.TopLayer,  70,  SceneLayer.UI, distanceDelta *(LAYER_DISTANCE.ToplayerDistance)); 
	
	M.CreateCameraLayer(M.guiCamera, CameraLayer.GuiCamera_1_1, 11, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.BattlerLayerDistance));                            -- GUICamera  战斗里角色准备中等状态， 血条
	M.CreateCameraLayer(M.guiCamera, CameraLayer.GuiCamera_1_2, 12, SceneLayer.UI, distanceDelta * (LAYER_DISTANCE.BattlerLayerDistance));
	-- BattleNameCamera 战斗中角色脚底名字                            -- GUICamera  掉血数字 Battler
	M.CreateCameraLayer(M.battlerNameCamera, CameraLayer.BattlerNameCamera_1, 10, SceneLayer.BattlerName, 
																	distanceDelta * (LAYER_DISTANCE.BattlerLayerDistance));     

end

-- camera 表示相机
-- layerName 层的名称
-- 层的层级
function M.CreateCameraLayer(camera, layerName, layerIndex, layer, distance)
	if (not camera) or (not layerName) then
		return;
	end

	if (not layerIndex) or (not layer) then
		return;
	end

	if M[layerName] then
		if info then info("Layer " .. layerName .. " already exists ") end;
		return;
	end

	M[layerName] = Layer.New(camera, layerName, (depth + layerIndex), layer, distance);

end

function M.AddGameObjectToCameraLayer(go, cameraLayerName)
	if (not go) or (not cameraLayerName) then
		return;
	end

	local cameraLayer = M[cameraLayerName];

	if not cameraLayer then
		if error then error("CameraLayerManager AddGameObjectToCameraLayer cameraLayer " .. cameraLayerName .. " is not exist") end;
		return;
	end
	cameraLayer:AddGameObjectToLayer(go);

end

function M.Create3DModelCameraSite()
	local gb = GameObject();
	gb.name = "UI3DModelSite";
	gb.transform.position = Vector3.New(1000, 1000, 10);
	return gb;
end

function M.CreateCharacterModelSite()
	local go = GameObject();
	go.name = "CharacterModelSite";
	return go;
end

function M.GetCameraLayerTransform(cameraLayerName)
	if not cameraLayerName then
		return;
	end

	local cameraLayer = M[cameraLayerName];
	if cameraLayer then
		return cameraLayer:GetLayerTransform();
	end
end

function M.GetCamera(cameraLayerName)
	if not cameraLayerName then
		return;
	end
	local cameraLayer = M[cameraLayerName];
	if not cameraLayer then
		return;
	end

	return cameraLayer:GetCamera();

end

function M.GetGUICamera()
	return M.guiCamera;
end

function M.GetBattleCamera()
	return M.battleCamera;
end

function M.GetMapUILayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.MapUILayer);
end

function M.GetPanelLayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.PanelLayer);
end

function M.GetSceneUILayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.SceneUILayer);
end

function M.GetInfoLayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.InfoLayer);
end

function M.GetTipsLayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.TipsLayer);
end

function M.GetSystemInfoLayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.SystemInfosLayer);
end

function M.GetTopLayerTransform()
	return M.GetCameraLayerTransform(CameraLayer.TopLayer);
end

function M.GetCameraLayerResolution(cameraLayerName)
	if not cameraLayerName then
		return;
	end

	local cameraLayer = M[cameraLayerName];
	if not cameraLayer then
		return;
	end

	return cameraLayer:GetResolution();
end

function M.GetCameraLayerPlaneDistance(cameraLayerName)
	if not cameraLayerName then
		return;
	end

	local  cameraLayer = M[cameraLayerName];
	if not cameraLayer then
		return;
	end

	return cameraLayer:GetPlaneDistance();
end

----------------------------------------------
----- 修改GUI的camera的cullingmask
----------------------------------------------
function M.SwitchGUICameraCullingMask(value)
	
	local camrea = M.GetGUICamera()
	camrea.cullingMask = value--BitOperator()
end

local cullingMasks = {}
cullingMasks["gui"] = 32 -- 默认存在UI层
function M.AddGUICameraCullingMask(key, value)

	cullingMasks[key] = value

	local mask = 0
	for _, v in pairs(cullingMasks) do
		mask = BitOperator.Or(mask, v)
	end

	M.SwitchGUICameraCullingMask(mask)
end

function M.RemoveCameraCullingMask(key)

	cullingMasks[key] = nil
	
	local mask = 0
	for _, v in pairs(cullingMasks) do
		mask = BitOperator.Or(mask, v)
	end

	M.SwitchGUICameraCullingMask(mask)
end

-----------------------------------------
-- 显示隐藏一个layer
-----------------------------------------
function M.ShowHideLayer(name, show)
	
	if M[name] then
		M[name]:ShowHide(show)
	end
end

function M.SetEnterBattleLayer()
	local camera = Camera.main;
	camera.cullingMask = M.GetMainCameraCullingMask(true);
	GameLayerManager.ShowHideLayer(CameraLayer.MapUILayer, false);
end

function M.SetExitBattleLayer()
	local camera = Camera.main;
	camera.cullingMask = M.GetMainCameraCullingMask(false);
	GameLayerManager.ShowHideLayer(CameraLayer.MapUILayer, true);
end

function M.GetMainCameraCullingMask(inBattle)
	local mask =  BitOperator.lMove(1, SceneLayer.TransparentFX) + BitOperator.lMove(1, SceneLayer.IgnoreRaycast) + BitOperator.lMove(1, SceneLayer.Water) + BitOperator.lMove(1, SceneLayer.UI);
	if inBattle then
		mask = mask + BitOperator.lMove(1, SceneLayer.BattleBg) + BitOperator.lMove(1, SceneLayer.BattlerName);
	else
		mask = mask + BitOperator.lMove(1, SceneLayer.Default) + BitOperator.lMove(1, SceneLayer.Character) + BitOperator.lMove(1, SceneLayer.Effect);
	end
	return mask;
end


return M;