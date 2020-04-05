--[[
-- added by ricashao @ 2020-04-05
-- UINewLogin视图层
-- 注意：
-- 1、成员变量最好预先在__init函数声明，提高代码可读性
-- 2、OnEnable函数每次在窗口打开时调用，直接刷新
-- 3、组件命名参考代码规范
--]]

local UINewLoginView = BaseClass("UINewLoginView", UIBaseView)
local base = UIBaseView

-- 各个组件路径
local account_input_path = "ContentRoot/LoginRoot/AccountRoot/AccountInput"
local password_input_path = "ContentRoot/LoginRoot/PasswordRoot/PasswordInput"
local login_btn_path = "ContentRoot/LoginRoot/LoginBtn"
local app_version_text_path = "BottomRoot/AppVersionText"
local res_version_text_path = "BottomRoot/ResVersionText"
local agree_toggle_path = "ContentRoot/LoginRoot/TreatyRoot/TreatyToggle"
local enter_btn_path = "ContentRoot/EnterBtn"
local login_view_path = "ContentRoot/LoginRoot"
local treaty_btn_path = "ContentRoot/LoginRoot/TreatyRoot/TreatyBtn"


local function ClickOnLoginBtn(self)
    local name = self.account_input:GetText()
    local password = self.password_input:GetText()
    self.ctrl:LoginServer(name, password)
end

local function ClickOnTreatyBtn(self)
    self.ctrl:OpenTreaty()
end

local function OnCreate(self)
    base.OnCreate(self)
    -- 初始化各个组件
    self.app_version_text = self:AddComponent(UIText, app_version_text_path)
    self.res_version_text = self:AddComponent(UIText, res_version_text_path)
    self.account_input = self:AddComponent(UIInput, account_input_path)
    self.password_input = self:AddComponent(UIInput, password_input_path)
    self.agree_toggle = self:AddComponent(UIToggleButton, agree_toggle_path)
    self.login_btn = self:AddComponent(UIButton, login_btn_path)
    self.enter_btn = self:AddComponent(UIButton, enter_btn_path)
    self.login_view = self:AddComponent(UIBaseComponent, login_view_path)
    self.treaty_btn = self:AddComponent(UIButton, treaty_btn_path)
    -- 使用方式二：私有函数、成员函数绑定
    self.login_btn:SetOnClick(self, ClickOnLoginBtn)
    self.treaty_btn:SetOnClick(self, ClickOnTreatyBtn)
    
end

local function OnEnable(self)
    base.OnEnable(self)
    self:OnRefresh()
    --临时TODO
    self.enter_btn:SetActive(false)
    -- 登录开启链接服务器
    self.ctrl:ConnectServer();
    AudioManager:GetInstance():PlayBg("Music/BGM/op.mp3")
end

-- Update测试
local function Update(self)
    --self.update_value = self.update_value + Time.deltaTime
    --self.test_updater_text:SetText(tostring(string.format("%.3f", self.update_value)))
end

local function OnRefresh(self)
    -- 各组件刷新
    self.app_version_text:SetText("游戏版本号：" .. self.model.client_app_ver)
    self.res_version_text:SetText("资源版本号：" .. self.model.client_res_ver)
    self.account_input:SetText(self.model.account)
    self.password_input:SetText(self.model.password)
end

local function OnLoginSuccess(self)
    self.login_view:SetActive(false)
    self.enter_btn:SetActive(true)
end

local function OnAddListener(self)
    base.OnAddListener(self)
    -- UI消息注册
    self:AddUIListener(UIMessageNames.UILOGIN_ON_LOGIN_SUCCESS, OnLoginSuccess)
end

local function OnRemoveListener(self)
    base.OnRemoveListener(self)
    -- UI消息注销
    self:RemoveUIListener(UIMessageNames.UILOGIN_ON_LOGIN_SUCCESS, OnLoginSuccess)
end

local function OnDestroy(self)
    self.app_version_text = nil
    self.res_version_text = nil
    self.account_input = nil
    self.password_input = nil
    self.agree_toggle = nil
    self.login_btn = nil
    self.login_btn = nil
    self.enter_btn = nil
    self.login_view = nil
    -- 测试代码
    base.OnDestroy(self)
end

UINewLoginView.OnCreate = OnCreate
UINewLoginView.OnEnable = OnEnable
UINewLoginView.Update = Update
UINewLoginView.OnRefresh = OnRefresh
UINewLoginView.OnAddListener = OnAddListener
UINewLoginView.OnRemoveListener = OnRemoveListener
UINewLoginView.OnDestroy = OnDestroy

return UINewLoginView