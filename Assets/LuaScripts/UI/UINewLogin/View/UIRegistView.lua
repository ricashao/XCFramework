--[[
-- added by ricashao @ 2020-04-05
-- UIRegist视图层
-- 注意：
-- 1、成员变量最好预先在__init函数声明，提高代码可读性
-- 2、OnEnable函数每次在窗口打开时调用，直接刷新
-- 3、组件命名参考代码规范
--]]
local UIRegistView = BaseClass("UIRegistView", UIBaseView)
local base = UIBaseView

-- 各个组件路径
local close_btn_path = "ContentRoot/CloseBtn"
local regist_btn_path = "ContentRoot/RegistBtn"
local account_input_path = "ContentRoot/AccountRoot/AccountInput"
local id_input_path = "ContentRoot/IdRoot/IdInput"
local pwd_input_path = "ContentRoot/PwdRoot/PwdInput"
local pwd2_input_path = "ContentRoot/Pwd2Root/Pwd2Input"

local function ClickOnCloseBtn(self)
    self.ctrl:CloseSelf()
end

local function ClickOnRegistBtn(self)
    local account = self.account_input:GetText()
    local id = self.id_input:GetText()
    local pwd = self.pwd_input:GetText()
    local pwd2 = self.pwd2_input:GetText()
    self.ctrl:RegistAccount(account, id, pwd, pwd2)
end

local function OnCreate(self)
    base.OnCreate(self)
    -- 初始化各个组件
    self.close_btn = self:AddComponent(UIButton, close_btn_path)
    self.regist_btn = self:AddComponent(UIButton, regist_btn_path)
    self.account_input = self:AddComponent(UIInput, account_input_path)
    self.id_input = self:AddComponent(UIInput, id_input_path)
    self.pwd_input = self:AddComponent(UIInput, pwd_input_path)
    self.pwd2_input = self:AddComponent(UIInput, pwd2_input_path)
    -- 使用方式二：私有函数、成员函数绑定
    self.close_btn:SetOnClick(self, ClickOnCloseBtn)
    self.regist_btn:SetOnClick(self, ClickOnRegistBtn)

end

local function OnDestroy(self)
    self.close_btn = nil
    self.regist_btn = nil
    self.account_input = nil
    self.id_input = nil
    self.pwd_input = nil
    self.pwd2_input = nil
    -- 测试代码
    base.OnDestroy(self)
end

UIRegistView.OnCreate = OnCreate
UIRegistView.OnDestroy = OnDestroy

return UIRegistView

