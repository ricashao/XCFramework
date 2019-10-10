local SingletonDialog = require "UI.SingletonDialog";
local LoginUIDialog = Class("LoginUIView", SingletonDialog);

local M = LoginUIDialog;

function M:Destroy()

	if LoginUIDialog:GetInstanceNotCreate() then
		GameObject.Destroy(self.m_pdlg);
		SingletonDialog.Destroy(self);
	end
	
end

function M:Ctor()
	SingletonDialog.Ctor(self);
end

function M:OnCreate()
	Dialog.OnCreate(self);
	self.m_pdlg = self:AsynLoad(LoginUIComponentName.LoginDialogRes, LoginUIComponentName.LoginDialogResPath, LoginUIComponentName.LoginDialogTitle);
end

function M:OnUIReady()
	
	self:GenAllNameMap(self.m_pdlg);

	self.m_pLogin = self:GetChildByPathName(LoginUIComponentName.LoginBtn);
	self.m_selectServerBtn = self:GetChildByPathName(LoginUIComponentName.SelectServerBtn);
	self.m_selectServerText = self:GetChildByPathName(LoginUIComponentName.SelectServerText).gameObject:GetComponent(typeof(CS.UnityEngine.UI.Text));

    self.m_inputUserName = self:GetChildByPathName(LoginUIComponentName.UserNameInputField):GetComponent('InputField');
    self.m_inputPassword = self:GetChildByPathName(LoginUIComponentName.PassWordInputField):GetComponent('InputField');

    SingletonDialog.OnUIReady(self);
end

return M
