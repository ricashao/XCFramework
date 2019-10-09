-- 场景
--[[szc
require "Character.Player.PlayerManager";
require "Scene.SceneTeam.SceneTeamModule";
require "Scene.Data.SceneNetProtocols";
require "Scene.TouchAgent";
require "Scene.ColliderTriggerAgent";
]]
require "Scene.Data.SceneCommon";

local Object = require "Framework.Object";
local Scene = Class("Scene",Object);

local STOP_DISTANCE = 1;

local M = Scene;

function M:Ctor(sceneID, sceneType, sceneCfg)
	self.sceneID       = sceneID;
	self.mapID         = sceneCfg.id;
	self.prefabName    = sceneCfg.resPath..sceneCfg.resName;
	self.fileName      = sceneCfg.resName;
	self.scenePath     = sceneCfg.scenePath;
	self.loader        = AsynPrefabLoader.New();
	self.loaded        = false;
	self.visible       = false;
	self.cameraData    = nil;
	self.sceneLoadLsns = {};
	self.bgmFileName   = sceneCfg.bgm;
	self.sceneAI	   = sceneCfg.sceneAI;
	self.artCfg		   = sceneCfg.artCfg;
	self.sceneType     = sceneType;
	self.selectedCharacter = nil;
end

function M:LoadPrefab(callback,sender)
	self.sceneLoadLsns = {callback = callback,sender = sender};
	self.loader:Load(self.prefabName .. ".ga",self.OnSceneLoaded, nil, self);
	self:PlayBGM();
end

function M:OnSceneLoaded(path,pfb)
	self.gameObject = pfb;
	self.loaded  = true;
	self.visible = true;

	self.sceneLoadLsns.callback(self.sceneLoadLsns.sender);
	self.sceneLoadLsns = {};

end

function M:SceneVisible()
	return self.visible;
end

function M:OnSelectedCharacter(character)
	if not character then
		self:SetSelectedCharacter(character);
		return;
	end

	if character:GetType() == CHARACTER_TYPE.NPC then
		local hostRole  = CharacterManager:GetInstance():GetHostCharacter();
		if not hostRole then
			return;
		end

		local hostRolePos = hostRole:GetWorldPosition();
		local npcPos      = character:GetWorldPosition();

		local stopArea = require("Utils.BeanUtil").GetEnumerValue("NPC_FIND_DISTANCE");
		stopArea       = tonumber(stopArea);

		if not stopArea then
			stopArea = STOP_DISTANCE;
		end

		local distance = math.abs(hostRolePos.x - npcPos.x) + math.abs(hostRolePos.z - npcPos.z);
		if distance > tonumber(stopArea) then
			hostRole:MoveByDespos(npcPos, stopArea, self.SetSelectedCharacter, character, self);
		else
			self:SetSelectedCharacter(character);
		end
	else
		self:SetSelectedCharacter(character);
	end

end

function M:SetSelectedCharacter(character)
	local hostPlayer    = CharacterManager:GetInstance():GetHostCharacter();
	local sameCharacter = false;

	if hostPlayer == character then
		sameCharacter = true;
	end

	if character and (not sameCharacter)  then
		character:TriggerSelectEvent();
	end

	if (character) and (self.selectedCharacter) and (self.selectedCharacter:GetId() == character:GetId()) then
		return;
	end

	if (character) and (character:IsVisible() == false) then
		return;
	end

	if sameCharacter then
		return;
	end

	-- old
	if self.selectedCharacter then
		self.selectedCharacter:OnSelected(false);
	end

	self.selectedCharacter = character;

	-- new
	if self.selectedCharacter then
		self.selectedCharacter:OnSelected(true);
	end
end

function M:GetSelectedCharacter()
	return self.selectedCharacter;
end

function M:IsSceneLoaded()
	return self.loaded;
end

function M:Init()
	SceneManager:GetInstance():AddSceneInitFun(self.LoadCameraConfigFile, self);
	SceneManager:GetInstance():AddSceneInitFun(self.AddHostRole, self);
	SceneManager:GetInstance():AddSceneInitFun(self.LoadArtSettings, self);
	SceneManager:GetInstance():AddSceneInitFun(self.AfterEnterScene, self);
end

function M:AddHostRole()
	local hostPlayer = CharacterManager:GetInstance():GetHostCharacter();
	local pos        = UserManager:GetInstance():GetHostRolePos();
	local poses      = UserManager:GetInstance():GetHostRolePoses();

	if hostPlayer == nil then
		local roleBasicOct = UserManager:GetInstance():GetHostRoleBasic();
		hostPlayer = PlayerManager:GetInstance():GetPlayerByID(roleBasicOct.roleid);
		if hostPlayer == nil then
			hostPlayer = require "Character.Player.Player".New(roleBasicOct.roleid);
			hostPlayer:Initialize(roleBasicOct, pos, poses);						
			PlayerManager:GetInstance():AddPlayer(hostPlayer);
		else
			hostPlayer:Initialize(roleBasicOct, pos, poses);
		end		
		CharacterManager:GetInstance():SetHostCharacter(hostPlayer);
		SceneManager:GetInstance():DontDestroyOnLoad(hostPlayer.gameObject);
	else
		hostPlayer:SetPos(pos);
	end
	
	CameraMgr.SetCamera(hostPlayer, self.cameraData);
	self:CUpdateSceneView();

	if self.sceneAI and self.sceneAI == "1018" then 
		CheapUtil.Proxy.StepDetectProxy.Regist(hostPlayer.gameObject);
	else
		CheapUtil.Proxy.StepDetectProxy.UnRegist(hostPlayer.gameObject);
	end
end

-- 上传屏幕坐标给服务器
function M:CUpdateSceneView()
	local p = require "Net.Protocols.protolua.ares.logic.move.cupdateview".Create();
	if not p then
		return;
	end

	local width  = UnityEngine.Screen.width;
	local height = UnityEngine.Screen.height;

	if (not width) or (not height) then
		return;
	end

	local smartCamera = CameraMgr.GetSmartCamera();
	if not smartCamera then
		return;
	end

	local distance = smartCamera:GetFollowDistance();

	local camera = smartCamera:GetCamera();
	if not camera then
		return;
	end

	local leftDownScreenPoint  = Vector3.New(0, 0, distance);
	local leftUpScreenPoint    = Vector3.New(0, height, distance);
	local rightDownScreenPoint = Vector3.New(width, 0, distance);
	local rightUpScreenPoint   = Vector3.New(width, height, distance);
	local centerScreenPoint    = Vector3.New(width/2, height/2 , distance);

	local leftDownPoint  = camera:ScreenToWorldPoint(leftDownScreenPoint);
	local leftUpPoint    = camera:ScreenToWorldPoint(leftUpScreenPoint);
	local rightDownPoint = camera:ScreenToWorldPoint(rightDownScreenPoint);
	local rightUpPoint   = camera:ScreenToWorldPoint(rightUpScreenPoint);
	local centerPoint    = camera:ScreenToWorldPoint(centerScreenPoint);

	p.leftup.x = leftUpPoint.x;
	p.leftup.y = leftUpPoint.y;
	p.leftup.z = leftUpPoint.z;

	p.leftdown.x = leftDownPoint.x;
	p.leftdown.y = leftDownPoint.y;
	p.leftdown.z = leftDownPoint.z;

	p.rightup.x  = rightUpPoint.x;
	p.rightup.y  = rightUpPoint.y;
	p.rightup.z  = rightUpPoint.z;

	p.rightdown.x = rightDownPoint.x;
	p.rightdown.y = rightDownPoint.y;
	p.rightdown.z = rightDownPoint.z;

	p.center.x = centerPoint.x;
	p.center.y = centerPoint.y;
	p.center.z = centerPoint.z;   

	LuaProtocolManager:getInstance():send(p);
end

function M:GetSceneId()
	return self.sceneID;
end

function M:GetMapId()
	return self.mapID;
end

function M:GetSceneType()
	return self.sceneType;
end

function M:SetSceneId(id)
	self.sceneID = id;
	self.mapID   =  SceneManager:GetInstance():SceneId2MapId(id);
end

function M:Destroy(destroyAsset)
	if destroyAsset then
		if self.gameObject then
			GameObject.Destroy(self.gameObject);
			self.gameObject = nil;
		end

		if self.loader then
			self.loader:Destroy();
			self.loader = nil;
		end
		ArtToolLogicApi.Clear();
	end
	CameraMgr.SetCamera(nil);
	CharacterManager:GetInstance():OnSceneDestroy();
end

function M:AddStaticNPcs()
	local path = "SceneConfigJson/" ..self.fileName .."/npc";

	local json = require "cjson";
	local jsonTable  = json.decode(Resources.Load(path):ToString());
    if jsonTable == nil then
        print("Load json file failed  file name " .. self.fileName);
    end

	local data = jsonTable["data"];
    for k,v in pairs(data) do
        local npcBasicoctets = require "Net.Protocols.protolua.autocode.ares.logic.move.npcbasic".New();
        local record = BeanConfigManager:GetInstance():GetTableByName("ares.logic.npc.cnpcshapelua"):GetRecorder(v.id);
        npcBasicoctets.pos.x = v.posx;
        npcBasicoctets.pos.y = v.posy;
        npcBasicoctets.pos.z = v.posz;
        npcBasicoctets.id = v.id;
        npcBasicoctets.dir.x = v.dirx;
        npcBasicoctets.dir.z = v.dirz;
   
        local npc =  require "Character.Npc.Npc".New(npcBasicoctets);        
    end
end

function M:LoadCameraConfigFile()
	local  mapID = tostring(self.mapID);
	local  path  = "Map/" .. mapID .. "/" .. mapID;
	local  json = require "cjson";
	local  jsonTable = json.decode(Resources.Load(path):ToString());
	if jsonTable == nil then
		if error then
			error("Can not load file " .. path);
		end
	end
	self.cameraData = jsonTable["data"];
end


function M:LoadArtSettings()
	local fileName = tostring(self.artCfg);
	ArtToolLogicApi.Load(fileName);
end

function M:AfterEnterScene()
	LuaProtocolManager:getInstance():Resume();
	local enterScene = require "Net.Protocols.protolua.ares.logic.move.cafterenterscene";
	local p = enterScene.Create();

	if (MainSceneViewCtrl:GetInstanceNotCreate()) and (MainSceneViewCtrl:GetInstanceNotCreate():IsLoaded()) then
		p.entertype = p.CHANGE_SCENE;
	else
		p.entertype = p.ENTER_WORLD;
	end
		
	LuaProtocolManager:getInstance():send(p);
end

function M:PlayBGM()
		CheapUtil.Proxy.AudioProxy.PlayBG(self.bgmFileName..".ga");
end

return M;
