-- 创建角色模块UI
local SingletonDialog = require "UI.SingletonDialog";
CreateRoleDialog = Class("CreateRoleDialog", SingletonDialog);
local M = CreateRoleDialog;

require "UI.CreateRole.CreateRoleCommon";

function M:Ctor()
	SingletonDialog.Ctor(self);
	self.bgRes = {};
end

function M:OnCreate()
	Dialog.OnCreate(self);
	self:AsynLoad(CreateRoleComponentName.Win_CreateRoleDialog, CreateRoleComponentName.CreateRoleDialogPath, CreateRoleComponentName.CreateRoleDialogName);
end

function M:OnUIReady()
	self:GenAllNameMap(self.m_pdlg);

	-- 左侧
	self.m_bg = self:GetChildByPathName(CreateRoleComponentName.EptBackGround);
	self.m_bgList = self.m_bg.gameObject:GetComponent(typeof(CS.UIObject)).ObjList;
	self.m_backBtn = self:GetChildByPathName(CreateRoleComponentName.BackBtn);

	self.m_roleBtn_1 = self:GetChildByPathName(CreateRoleComponentName.EbtnRole_1).gameObject:GetComponent(CreateRoleComponentName.Button);
	self.m_roleBtn_2 = self:GetChildByPathName(CreateRoleComponentName.EbtnRole_2).gameObject:GetComponent(CreateRoleComponentName.Button);
	self.m_roleBtn_3 = self:GetChildByPathName(CreateRoleComponentName.EbtnRole_3).gameObject:GetComponent(CreateRoleComponentName.Button);
	self.m_roleBtn_4 = self:GetChildByPathName(CreateRoleComponentName.EbtnRole_4).gameObject:GetComponent(CreateRoleComponentName.Button);
	self.m_roleBtn_5 = self:GetChildByPathName(CreateRoleComponentName.EbtnRole_5).gameObject:GetComponent(CreateRoleComponentName.Button);
	self.m_roleBtn_6 = self:GetChildByPathName(CreateRoleComponentName.EbtnRole_6).gameObject:GetComponent(CreateRoleComponentName.Button);

	self.m_roleBtn_1_img = self.m_roleBtn_1.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_roleBtn_2_img = self.m_roleBtn_2.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_roleBtn_3_img = self.m_roleBtn_3.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_roleBtn_4_img = self.m_roleBtn_4.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_roleBtn_5_img = self.m_roleBtn_5.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_roleBtn_6_img = self.m_roleBtn_6.gameObject:GetComponent(CreateRoleComponentName.Image);

	self.m_btn_role_1 = self:GetChildByPathName(CreateRoleComponentName.Btn_p_role_1).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_btn_role_2 = self:GetChildByPathName(CreateRoleComponentName.Btn_p_role_2).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_btn_role_3 = self:GetChildByPathName(CreateRoleComponentName.Btn_p_role_3).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_btn_role_4 = self:GetChildByPathName(CreateRoleComponentName.Btn_p_role_4).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_btn_role_5 = self:GetChildByPathName(CreateRoleComponentName.Btn_p_role_5).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_btn_role_6 = self:GetChildByPathName(CreateRoleComponentName.Btn_p_role_6).gameObject:GetComponent(CreateRoleComponentName.Image);

	-- 中间
	self.m_roleModel = self:GetChildByPathName(CreateRoleComponentName.RoleModel);
	self.m_rawImage  = self.m_roleModel.gameObject:GetComponent(CreateRoleComponentName.RawImage);
	self.m_modelCtrl = require "UI.Common.Model.UIModelCtrl".New();
	self.m_roleModelBtn = self:GetChildByPathName(CreateRoleComponentName.RoleModelBtn);

	self.m_roleNameObj = self:GetChildByPathName(CreateRoleComponentName.RoleInfoName);
	self.m_nameImg     = self.m_roleNameObj.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_nameImgList = self.m_roleNameObj.gameObject:GetComponent(typeof(CS.UISpriteSwap)).Spritelist;

	self.m_wordAobj     = self:GetChildByPathName(CreateRoleComponentName.RoleInfoWordA);
	self.m_wordAimg     = self.m_wordAobj.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_wordAimgList = self.m_wordAobj.gameObject:GetComponent(typeof(CS.UISpriteSwap)).Spritelist;

	self.m_wordBobj     = self:GetChildByPathName(CreateRoleComponentName.RoleInfoWordB);
	self.m_wordBimg     = self.m_wordBobj.gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_wordBimgList = self.m_wordBobj.gameObject:GetComponent(typeof(CS.UISpriteSwap)).Spritelist;

	-- 右侧
	self.m_createRoleBtn = self:GetChildByPathName(CreateRoleComponentName.CreateRoleBtn);
	self.m_randomBtn     = self:GetChildByPathName(CreateRoleComponentName.RandomBtn);
	
	self.m_guildBtn_1    = self:GetChildByPathName(CreateRoleComponentName.GuildBtn_1);
	self.m_guildName_1   = self:GetChildByPathName(CreateRoleComponentName.GuildName_1).gameObject:GetComponent(CreateRoleComponentName.Text);
	self.m_guildInfo_1   = self:GetChildByPathName(CreateRoleComponentName.GuildInfo_1).gameObject:GetComponent(CreateRoleComponentName.Text);
	self.m_guildImgList_1= self:GetChildByPathName(CreateRoleComponentName.GuildImgList_1).gameObject:GetComponent(typeof(CS.UISpriteSwap)).Spritelist;
	self.m_guildImg_1    = self:GetChildByPathName(CreateRoleComponentName.GuildImgList_1).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_guildChoose_1 = self:GetChildByPathName(CreateRoleComponentName.GuildChoose_1);

	self.m_guildBtn_2    = self:GetChildByPathName(CreateRoleComponentName.GuildBtn_2);
	self.m_guildName_2   = self:GetChildByPathName(CreateRoleComponentName.GuildName_2).gameObject:GetComponent(CreateRoleComponentName.Text);
	self.m_guildInfo_2   = self:GetChildByPathName(CreateRoleComponentName.GuildInfo_2).gameObject:GetComponent(CreateRoleComponentName.Text)
	self.m_guildImg_2    = self:GetChildByPathName(CreateRoleComponentName.GuildImgList_2).gameObject:GetComponent(CreateRoleComponentName.Image);
	self.m_guildImgList_2= self:GetChildByPathName(CreateRoleComponentName.GuildImgList_2).gameObject:GetComponent(typeof(CS.UISpriteSwap)).Spritelist;
	self.m_guildChoose_2 = self:GetChildByPathName(CreateRoleComponentName.GuildChoose_2);
	self.m_inputFiled    = self:GetChildByPathName(CreateRoleComponentName.InputFieldComponent);
	self.m_inputUserName = self.m_inputFiled.gameObject:GetComponent(CreateRoleComponentName.InputField);

	SingletonDialog.OnUIReady(self);
--	LoadingManager:GetInstance():CreateRoleComplete();

end

function M:Show()
	SingletonDialog.Show(self);
end


-- 销毁控件
function M:Destroy()
	if M:GetInstanceNotCreate() then
		GameObject.Destroy(self.m_pdlg);
		SingletonDialog.Destroy(self);
	end
end

return M;
