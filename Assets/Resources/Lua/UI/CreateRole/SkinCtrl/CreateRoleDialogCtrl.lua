local BasicCtrl = require "UI.BasicCtrl";
CreateRoleDialogCtrl = Class("CreateRoleDialogCtrl", BasicCtrl);
require "UI.CreateRole.CreateRoleManager";

local euler            = nil;
local ANGLE_RATIO      = 6;
local ROUND            = 360;
local MAX_LEN          = 12;
local MIN_LEN          = 3;
local RAWIMAGE_WIDTH   = 1000;
local RAWIMAGE_HEIGHT  = 875;
local SELECTED_COLOR   = Color.New(1, 1, 1);
local NORMAL_COLOR     = Color.New(0.58, 0.58, 0.58);
local AntiAliasing     = 8;
local MODEL_OFFSET     = nil                                 --Vector3.New(-0.03, -1.38, 2.8);
local CAMERA_OFFSET    = Vector3.New(-0.24, 100.61, 0.83);
local CAMERA_ROTATION  = Quaternion.Euler(3.09, 178.749, 357.392)

local M = CreateRoleDialogCtrl;

function M:Ctor()
	BasicCtrl.Ctor(self);
	self.roleBtns         = {};
	self.roleBtnBg        = {};
	self.roleBtnRoleBg    = {};
	self.schools          = {};
	self.shape            = nil;
	self.selectedRole     = 1;
	self.selectedSchool   = 1;
	self.bgGameObject     = {};
	self.effectModel      = nil;
	self.inputEventScript = nil;
	TickerManager:GetInstance():AddTicker(self);
end

function M:Destroy()
	TickerManager:GetInstance():RemoveTicker(self);	
	self.m_pSkin.m_modelCtrl:Destroy();
	self.effectModel = nil;
    BasicCtrl.Destroy(self);
    M._instance = nil;    
end

function M:Show()
	local createRoleDialog = require "UI.CreateRole.Skin.CreateRoleDialog";
	BasicCtrl.Show(self, createRoleDialog, nil);
end

function M:InitCtrl()
	self.m_pSkin:SetCtrlClass(M);

	-- 背景
	for i = 0, self.m_pSkin.m_bgList.Count -1 do
		local res = self.m_pSkin.m_bgList[i];
		local go = AssetManager.Clone(res, true);
		go.transform:SetParent(self.m_pSkin.m_bg, false);
		table.insert(self.bgGameObject, go);
	end

	--左侧
	GameUIClickEvent.AddListener(self.m_pSkin.m_backBtn, self.m_pSkin.m_backBtn.name, M.HandBackBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_roleBtn_1, self.m_pSkin.m_roleBtn_1.name, M.HandSelectRoleBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_roleBtn_2, self.m_pSkin.m_roleBtn_2.name, M.HandSelectRoleBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_roleBtn_3, self.m_pSkin.m_roleBtn_3.name, M.HandSelectRoleBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_roleBtn_4, self.m_pSkin.m_roleBtn_4.name, M.HandSelectRoleBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_roleBtn_5, self.m_pSkin.m_roleBtn_5.name, M.HandSelectRoleBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_roleBtn_6, self.m_pSkin.m_roleBtn_6.name, M.HandSelectRoleBtnClick);

	self:AddRoleBtnData();

	-- 右侧
	GameUIClickEvent.AddListener(self.m_pSkin.m_createRoleBtn, self.m_pSkin.m_createRoleBtn.name, M.HandRightAreaBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_randomBtn, self.m_pSkin.m_randomBtn.name, M.HandRightAreaBtnClick);
	self.m_pSkin.m_guildBtn_1.name = CreateRoleComponentName.Empty_Btn_1;
	self.m_pSkin.m_guildBtn_2.name = CreateRoleComponentName.Empty_Btn_2;
	GameUIClickEvent.AddListener(self.m_pSkin.m_guildBtn_1, self.m_pSkin.m_guildBtn_1.name, M.HandRightAreaBtnClick);
	GameUIClickEvent.AddListener(self.m_pSkin.m_guildBtn_2, self.m_pSkin.m_guildBtn_2.name, M.HandRightAreaBtnClick);

	self.inputEventScript = self.m_pSkin.m_inputFiled.gameObject:AddComponent(typeof(CS.InputFieldEvent));
	self.inputEventScript:SetKey("CreateRoleInputEvent");

	-- 中间
	self.m_pSkin.m_roleModelBtn.name = CreateRoleComponentName.ModelBtn;

	self:UpdateCreateRolePanel(self.selectedRole);
end


function M:AddRoleBtnData()
	table.insert(self.roleBtns, self.m_pSkin.m_roleBtn_1);
	table.insert(self.roleBtns, self.m_pSkin.m_roleBtn_2);
	table.insert(self.roleBtns, self.m_pSkin.m_roleBtn_3);
	table.insert(self.roleBtns, self.m_pSkin.m_roleBtn_4);
	table.insert(self.roleBtns, self.m_pSkin.m_roleBtn_5);
	table.insert(self.roleBtns, self.m_pSkin.m_roleBtn_6);

	table.insert(self.roleBtnBg, self.m_pSkin.m_roleBtn_1_img);
	table.insert(self.roleBtnBg, self.m_pSkin.m_roleBtn_2_img);
	table.insert(self.roleBtnBg, self.m_pSkin.m_roleBtn_3_img);
	table.insert(self.roleBtnBg, self.m_pSkin.m_roleBtn_4_img);
	table.insert(self.roleBtnBg, self.m_pSkin.m_roleBtn_5_img);
	table.insert(self.roleBtnBg, self.m_pSkin.m_roleBtn_6_img);

	table.insert(self.roleBtnRoleBg, self.m_pSkin.m_btn_role_1);
	table.insert(self.roleBtnRoleBg, self.m_pSkin.m_btn_role_2);
	table.insert(self.roleBtnRoleBg, self.m_pSkin.m_btn_role_3);
	table.insert(self.roleBtnRoleBg, self.m_pSkin.m_btn_role_4);
	table.insert(self.roleBtnRoleBg, self.m_pSkin.m_btn_role_5);
	table.insert(self.roleBtnRoleBg, self.m_pSkin.m_btn_role_6);

end

function M.HandBackBtnClick(go)
	local self = CreateRoleDialogCtrl:GetInstance();
	if go.name == self.m_pSkin.m_backBtn.name then
		self:Destroy();
		LoginUICtrl:GetInstance():Show();
	end
end

function M.HandSelectRoleBtnClick(go)
	if go == nil then
		return;
	end
	local self = CreateRoleDialogCtrl:GetInstance();
	local prefixLen = string.len(CreateRoleComponentName.RoleBtnPrefix);
	local len = string.len(go.name);	
	local id = string.sub(go.name, prefixLen + 3, len);
	id = tonumber(id);
	self.selectedRole = id;
	self:UpdateCreateRolePanel(id);
end

function M.HandRightAreaBtnClick(go)
	local self = CreateRoleDialogCtrl:GetInstance();
	if go.name == self.m_pSkin.m_randomBtn.name then
		 CreateRoleManager:GetInstance():RequestRoleName(self.selectedRole);

	elseif go.name == self.m_pSkin.m_createRoleBtn.name then
		self:EnterCreateRole(self.m_pSkin.m_inputUserName.text);

	elseif go.name == self.m_pSkin.m_guildBtn_1.name then
		self.m_pSkin.m_guildChoose_1.gameObject:SetActive(true);
		self.m_pSkin.m_guildChoose_2.gameObject:SetActive(false);
		self.selectedSchool = 1;
		self:UpdateCenterModel(self.selectedRole);

	elseif go.name == self.m_pSkin.m_guildBtn_2.name then
		self.m_pSkin.m_guildChoose_1.gameObject:SetActive(false);
		self.m_pSkin.m_guildChoose_2.gameObject:SetActive(true);
		self.selectedSchool = 2;
		self:UpdateCenterModel(self.selectedRole);

	else
		
	end
end

function M:EnterCreateRole(name)
	if name == nil or name == "" then
		self:ErrorAlert(CREATE_STATE.CREATE_SHORTLEN);
		return;
	elseif (string.len(name)) < MIN_LEN then
		self:ErrorAlert(CREATE_STATE.CREATE_SHORTLEN);
		return;
	else

	end

	local number = tonumber(name);
	if number then
		self:ErrorAlert(CREATE_STATE.CREATE_ROLE_NAME_PURE_NUMBER);
		return;
	end

	CreateRoleManager:GetInstance():SetRoleName(name);
	local school = tonumber((self.schools[self.selectedSchool]).id);
	CreateRoleManager:GetInstance():CreateRole(school, self.shape);
end

-- 刷新界面
function M:UpdateCreateRolePanel(id)
	if id == nil then
		return;
	end

	self:UpdateBackGround(id);
	self:UpdateTabState(id);
	self:UpdateCenterModel(id);
	self:UpdateRightAea(id);

end

function M:UpdateBackGround(id)
	if id == nil then
		return;
	end

	for i,v in ipairs(self.bgGameObject) do
		if i == id then
			self.bgGameObject[i]:SetActive(true);
		else
			self.bgGameObject[i]:SetActive(false);
		end
	end
end

-- 刷新左侧创建角色按钮组
function M:UpdateTabState(selectedID)
	if selectedID == nil then
		return;
	end
	for id,btn in ipairs(self.roleBtns) do
		if selectedID == id then
			btn.interactable = false;
		else
			btn.interactable = true;
		end
	end

	for id, bg in ipairs(self.roleBtnBg) do
		if selectedID == id then
			bg.color = SELECTED_COLOR;
		else
			bg.color = NORMAL_COLOR;
		end
	end

	for id, roleBg in ipairs(self.roleBtnRoleBg) do
		if selectedID == id then
			roleBg.color = SELECTED_COLOR;
		else
			roleBg.color = NORMAL_COLOR;
		end
	end

end

-- 刷新中间的模型和文字
function M:UpdateCenterModel(id)
	if id == nil then
		return;
	end

	local shapeRecord = CreateRoleManager:GetInstance():GetRoleRecord(id);
	if shapeRecord == nil then
		return;
	end

	local modelRecord, effctModelName;
	if self.selectedSchool == 1 then
--		modelRecord = CreateRoleManager:GetInstance():GetRoleModelRecord(tonumber(shapeRecord.rolemodel1));
		effctModelName = shapeRecord.effectmodel1;
	elseif self.selectedSchool == 2 then
--		modelRecord = CreateRoleManager:GetInstance():GetRoleModelRecord(tonumber(shapeRecord.rolemodel2));
		effctModelName = shapeRecord.effectmodel2;
	else
		return;
	end

	--if modelRecord == nil then
	--	return;
	--end

	if self.selectedSchool == 2 then
		self.shape = tonumber(shapeRecord.createmodelid2);
	else
		self.shape = tonumber(shapeRecord.createmodelid1);
	end
	
	self.m_pSkin.m_modelCtrl:Destroy();
	self.m_pSkin.m_modelCtrl:CreateModel("6001_player_lutianxingzj_normal", "Actor/Prefab/Player", self.m_pSkin.m_rawImage, RAWIMAGE_WIDTH, RAWIMAGE_HEIGHT, AntiAliasing, CAMERA_OFFSET, MODEL_OFFSET, CAMERA_ROTATION); 
   	self.m_pSkin.m_modelCtrl.mCamera.fieldOfView = 72;

   	local effctModelPath = shapeRecord.effectpath;
	if effctModelName and (string.len(effctModelName)) > 0 then
		if effctModelPath and (string.len(effctModelPath)) > 0 then
			self.m_pSkin.m_modelCtrl:AddEffectModel(effctModelName, effctModelPath);
		end
	end

	-- 刷新名字还有对应的文字
	self.m_pSkin.m_nameImg.sprite  = self.m_pSkin.m_nameImgList[id -1];
	self.m_pSkin.m_wordAimg.sprite = self.m_pSkin.m_wordAimgList[id -1];
	self.m_pSkin.m_wordBimg.sprite = self.m_pSkin.m_wordBimgList[id -1];

end

function M:OnEffectLoaded(pfb)
	if pfb == nil then
		return;
	end

	self.effectModel = pfb;	
end

RoleModelBtnEmpty = {};
function RoleModelBtnEmpty.OnRotationChanged(angle)
	 if CreateRoleDialogCtrl:GetInstanceNotCreate() then
        local modeCtrl = CreateRoleDialogCtrl:GetInstance().m_pSkin.m_modelCtrl;
        local euler = modeCtrl.mModel.transform.localRotation.eulerAngles;
        euler.y = euler.y + angle;
        modeCtrl.mModel.transform.localRotation = Quaternion.Euler(0, euler.y, 0);   
    end
end

function M:UpdateRightAea(id)
	self.m_pSkin.m_guildChoose_1.gameObject:SetActive(true);
	self.m_pSkin.m_guildChoose_2.gameObject:SetActive(false);
	self.selectedSchool = 1;

	if id == nil then
		return;
	end

	local records = CreateRoleManager:GetInstance():GetShoolRecords(id);
	self.schools = records;
	if records == nil then
		return;
	end

	local record1 = records[1];
	if record1 then
		local imgID_1 = ((record1.id) %10) -1;
		if imgID_1 >=0 then
			self.m_pSkin.m_guildImg_1.sprite = self.m_pSkin.m_guildImgList_1[imgID_1];
			self.m_pSkin.m_guildName_1.text  = record1.name;
			self.m_pSkin.m_guildInfo_1.text  = record1.describe;
		end
	end

	local record2 = records[2];
	if record2 then
		local imgID_2 = ((record2.id) %10) -1;
		if imgID_2 >= 0 then
			self.m_pSkin.m_guildImg_2.sprite = self.m_pSkin.m_guildImgList_2[imgID_2];
			self.m_pSkin.m_guildName_2.text  = record2.name;
			self.m_pSkin.m_guildInfo_2.text  = record2.describe;
		end
	end
end

function M:UpdateRoleName(roleName)
	if roleName then
		self.m_pSkin.m_inputUserName.text = roleName;
		self.m_pSkin.m_inputUserName.textComponent.text = roleName;
	end	
end

-- 错误提示
function M:ErrorAlert(errorID)
	if errorID == CREATE_STATE.CREATE_ERROR then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_ERROR);
	elseif errorID == CREATE_STATE.CREATE_INVALID then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_INVALID);
	elseif errorID == CREATE_STATE.CREATE_DUPLICATED then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_DUPLICATED);
	elseif errorID == CREATE_STATE.CREATE_OVERCOUNT then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_OVERCOUNT);
	elseif errorID == CREATE_STATE.CREATE_OVERLEN then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_OVERLEN);
	elseif errorID == CREATE_STATE.CREATE_SHORTLEN then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_SHORTLEN);
	elseif errorID == CREATE_STATE.CREATE_ROLE_NAME_PURE_NUMBER then
		CommMsgMgr:GetInstance():Show(CREATEROLE_TIP_ID.CREATE_ROLE_NAME_PURE_NUMBER);
	else
		
	end
end

function M:Tick(delta)
	if self.m_pSkin == nil then
		return;
	end

	if self.m_pSkin.m_modelCtrl == nil then
		return;
	end

	local model = self.m_pSkin.m_modelCtrl.mModel;
	if model and model.transform then
		euler = model.transform.localRotation.eulerAngles;
		if euler then
			euler.y = (euler.y - (ANGLE_RATIO * delta) + ROUND) % ROUND;
        	model.transform.localRotation = Quaternion.Euler(0, euler.y, 0);
		end
	end
end

CreateRoleInputEvent = {};

function CreateRoleInputEvent.OnValueChange(text)
 	
end 


function CreateRoleInputEvent.OnEndEdit(text)
	local self = CreateRoleDialogCtrl:GetInstance();
	self:UpdateLabelDisplay();
end 

function CreateRoleInputEvent.OnSubmit(text)
	local self = CreateRoleDialogCtrl:GetInstance();
	self:UpdateLabelDisplay();
end

function M:UpdateLabelDisplay()
	local str = self.m_pSkin.m_inputUserName.text;	
	self.m_pSkin.m_inputUserName.textComponent.text = str;
end

return M;