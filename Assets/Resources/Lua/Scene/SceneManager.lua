--场景管理
local Singleton = require "Framework.Singleton";
SceneManager = Class("SceneManager", Singleton);

require "UI.Loading.LoadingManager";

local Scene       = require "Scene.Scene";
local BattleScene = require "Scene.BattleScene";
local HomeScene   = require "Scene.HomeScene";

local MainCitySceneUI = require "UI.SceneUI.MainScene.SkinCtrl.MainSceneViewCtrl";
local BattleSceneUI   = require "UI.SceneUI.BattleScene.SkinCtrl.BattleSceneViewCtrl";
local CommunicateUI   = require "UI.Communication.SkinCtrl.CommunicateCtrl";
local Creqgoto=require "Net.Protocols.protolua.ares.logic.task.creqgoto";

local SCENE_ID = 4294967295;   -- 16进制 0XFFFFFFFF

local M = SceneManager;

L = {};--私有成员
 
SceneUIType = {}
SceneUIType.HOME 		 = 1;		
SceneUIType.MAINCITY 	 = 2;		
SceneUIType.BATTLE 		 = 3;  		
SceneUIType.BattleResult = 4;      

SceneLoadType = {}
SceneLoadType.LoadSceneBegin  = 0;
SceneLoadType.LoadLevel       = 1;
SceneLoadType.LoadScenePrefab = 2;
SceneLoadType.Initialize      = 3;

function M:Ctor()
	Singleton.Ctor(self);
	self.sceneTable                        = BeanConfigManager:GetInstance():GetTableByName("ares.logic.map.csceneconfig");
	self.sceneUIList                       = {};
	self.sceneLoadLsns                     = {};
	self.changeSceneParamList              = {};
	self.sceneInitList                     = {};
	self.sceneUIList[SceneUIType.MAINCITY] = MainCitySceneUI;
	self.sceneUIList[SceneUIType.BATTLE]   = BattleSceneUI;
	self.communicateUI                     = CommunicateUI;
	self.lightMapLoaded                    = false;	
	self.loading                           = false;
	self.LoadType                          = -1;
	self.loadFunction                      = nil;
	self.sceneResName                      = "";
	self.sceneFileName                     = "";
	self.curScene                          = nil;
	self.currentSceneUIType                = nil;
end

function M:DontDestroyOnLoad(target)
	if target == nil then 
		return 
	end

	GameObject.DontDestroyOnLoad(target);
end

function M:ChangeScene(newId,sceneType, callBack, sender)
	if not newId then
		return;
	end

	if self.loading then
		local param = {};
		param.sceneid   = newId;
		param.sceneType = sceneType;
		param.callBack  = callBack;
		param.sender    = sender;
		table.insert(self.changeSceneParamList, param);
		return;
	end

	local mapID    = self:SceneId2MapId(newId);
	local sceneCfg = self.sceneTable:GetRecorder(mapID);

	if not sceneCfg then
		return;
	end

	--是否销毁资源
	local sceneResEquip  = sceneCfg.resName == self.sceneResName;
	local sceneFileEquip = sceneCfg.sceneFileName == self.sceneFileName;
	local destroyAsset   = not sceneResEquip or not sceneFileEquip;

	self:DestroyCurrentScene(destroyAsset);

	LoadingManager:GetInstance():Show();
	self.loading = true;

	if destroyAsset then
		if sceneType == SceneUIType.HOME then
			self.curScene = HomeScene.New(newId, sceneType, sceneCfg);
		elseif sceneType == SceneUIType.BATTLE then
			self.curScene = BattleScene.New(newId, sceneType, sceneCfg);
		else
			self.curScene = Scene.New(newId, sceneType, sceneCfg);
		end

		if not sceneFileEquip then
			self.loadFunction = L.LoadSceneBegin;
		else
			self.loadFunction = L.LoadScenePrefab;
		end
	else
		self.curScene:SetSceneId(newId);
		self.loadFunction = L.SceneInitialize;
	end

	self.curScene:Init();
	self.sceneResName  = sceneCfg.resName;
	self.sceneFileName = sceneCfg.sceneFileName;
	self.scenePath     = sceneCfg.scenePath .. self.sceneFileName..".ga";
	self:AddListener(callBack, sender);
	self:AddSceneInitFun(self.ChangeSceneUI,self,sceneType);
end

function M:SceneId2MapId(sceneid)
	if not sceneid then
		return;
	end

	local mapID = BitOperator.And(sceneid, SCENE_ID);
	return mapID;
end

--跳转到空场景
function M:GoToEmptyScene()
	LoadingManager:GetInstance():Show();
	self:DestroyCurrentScene(true);
	self.loading       = true;
	self.sceneResName  = "";
	self.sceneFileName = "Empty";
	self.loadFunction  = L.LoadSceneBegin;
end


function M:ChangeSceneUI(sceneType)
	if not sceneType then return end

	if self.currentSceneUIType == sceneType then
		self.sceneUIList[sceneType]:GetInstance():Refresh();
		return
	end

	TweenNano.CloseTweenByType(TWEEN_CLOSE_CHANGE_SCENE);
	local scene;

	if self.currentSceneUIType then
		scene = self.sceneUIList[self.currentSceneUIType];
		if scene:GetInstanceNotCreate() then
			scene:GetInstanceNotCreate():Destroy();
		end
	end

	scene = self.sceneUIList[sceneType];
	scene:GetInstance():Show();
	self.currentSceneUIType = sceneType;

	-- 创建交流层UI
	self.communicateUI:GetInstance():Show();
end

--加载Scene的assetBoundle
function L:LoadSceneBegin()
	self.LoadType = SceneLoadType.LoadSceneBegin;
	if AssetManager.LoadScene(self.scenePath) then
		self.loadFunction = L.LoadLevel;
	else
		error("Lua:: SceneManager Error:Dont load scene , path:"..self.scenePath);
	end
end
--Application加载场景
function L:LoadLevel()
	self.LoadType = SceneLoadType.LoadLevel;
	Application.LoadLevel(tostring(self.sceneFileName));
	L:UpdateLoadingProgress(0.3);
	self.loadFunction = L.LoadScenePrefab;
end

--加载Scene的Prefab
function L:LoadScenePrefab()
	if self.curScene ~= nil then
		self.LoadType = SceneLoadType.LoadScenePrefab;
		self.curScene:LoadPrefab(L.OnScenePrefabComplete,self);
		L:UpdateLoadingProgress(0.5);
	else
		--在返回主界面，切换的是空场景，所以curScene有可能为空
		self.loadFunction = L.SceneInitialize;
	end
end



--Scene的Prefab加载完成
function L:OnScenePrefabComplete()
	self.loadFunction = L.SceneInitialize;
	L:UpdateLoadingProgress(0.8);
end
--Scene初始化
function L:SceneInitialize()
	self.LoadType = SceneLoadType.Initialize;
	self.loadFunction = L.DoSceneInitialize;
end 
--递归执行初始化队列
function L:DoSceneInitialize()
	local n = table.getn(self.sceneInitList);
	if n > 0 then
		local v = self.sceneInitList[1];
		v.callBack(v.sender,v.param);
		table.remove(self.sceneInitList,1);

		self.loadFunction = L.DoSceneInitialize;
	else
		self.loadFunction = nil;
		L:UpdateLoadingProgress(1);
	end
end

function M.OnLightMapLoaded()
	SceneManager:GetInstance().lightMapLoaded = true;
end

function M:OnLoadCompleted()
	self.loading = false;

	for k,v in pairs(self.sceneLoadLsns) do
		v.callBack(v.sender);
		v = nil;
	end
	self.sceneLoadLsns = {};
	
	LoadingManager:GetInstance():Close();

	local len = table.getn(self.changeSceneParamList);
	if len > 0 then
		local v = self.changeSceneParamList[1];
		self:ChangeScene(v.sceneid, v.sceneType, v.callBack, v.sender);
		table.remove(self.changeSceneParamList, 1);
	end
end


--添加场景完成后的回调函数
function M:AddListener(callBack, sender)
	if callBack then
		local t    = {};
		t.sender   = sender;
		t.callBack = callBack;
		table.insert(self.sceneLoadLsns, t);
	end
end

--添加场景初始化函数
function M:AddSceneInitFun(callBack,sender,...)
	if callBack and sender then
		table.insert(self.sceneInitList, {sender = sender,callBack = callBack,param = ...});
	end
end

function M:GetCurSceneId()
	if self.curScene ~= nil then
		return self.curScene:GetSceneId();
	end
end

function M:GetCurMapId()
	if not self.curScene then
		return;
	end
	return self.curScene:GetMapId();
end

function M:GetCurSceneType()
	if not self.curScene then
		return;
	end
	return self.curScene:GetSceneType();
end

function M:GetCurSceneUIType()
	return self.currentSceneUIType;
end

function M:GetCurScene()
	return self.curScene;
end

function M:isLoading()
	return self.loading;
end

function M:Tick(deltaTime)
	if self.loading then
		if self.loadFunction then
			local fun = self.loadFunction;
			self.loadFunction = nil;
			fun(self);
		else 
			if self.LoadType == SceneLoadType.Initialize and LoadingManager:GetInstance():ProgressEnd() and self.lightMapLoaded then
				self:OnLoadCompleted();
			end
		end
	end
end

-- sceneid  场景id
-- random   random为1 表示切换场景完成后随机到某点， 0表示切换场景到指定点
function M:ReqGoToScene(sceneid, random, pos, callBack, sender)
	self:AddListener(callBack, sender);
	local req = Creqgoto.New();
	req.mapid = sceneid;

	if pos == nil then
		pos = Vector3.zero;
	end

	if random == nil then
		random = 1;
	end

	req.xpos = pos.x;
	req.ypos = pos.y;
	req.zpos = pos.z;
	req.israndom = random;
	LuaProtocolManager:getInstance():send(req);	
end

function M:Reset()
	self.currentSceneUIType = nil;
	self.sceneInitList      = {};
	self.loading            = false;
	self.LoadType           = -1;
	self.loadFunction       = nil;
	self.sceneResName       = "";
	self.sceneFileName      = "";
	self.lightMapLoaded     = false;
	self.curScene           = nil;
end

function M:DestroyCurrentScene(destroyAsset)
	if self.curScene  ~= nil then
		self.curScene:Destroy(destroyAsset);
		if destroyAsset then self.curScene = nil; end
	end
end

function M:DestroySceneUI()
	for k,v in pairs(self.sceneUIList) do
		if v:GetInstanceNotCreate() then
			v:GetInstanceNotCreate():Destroy();
		end
		v = nil;
	end
end

function M:Destroy()
	self:DestroyCurrentScene(true);
	self:DestroySceneUI();
	self:Reset();
end

function L:UpdateLoadingProgress(progress)
	LoadingManager:GetInstance():UpdateProgress(progress);
end

function M:RefreshSceneCharacter(seeroles)
	require "Task.TaskMgr";
	TaskMgr:GetInstance():ShowAllTaskNpc();

	if not seeroles then
		return;
	end
	local roleID, player, pos, destPos;
	local hostRole = CharacterManager:GetInstance():GetHostCharacter();

	for _, rolePos in pairs(seeroles) do
		roleID  = rolePos.roleid;
		pos     = rolePos.poses[1];
		destPos = rolePos.poses[2];
		player  = PlayerManager:GetInstance():GetPlayerByID(roleID);
		if player then
			if pos then
				player:SetPos(pos);
			end

			if destPos then
				if player ~= hostRole then
					player:MoveByDespos(destPos);
				end
			end
		end
	end
end

return M;