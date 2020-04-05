--[[
-- added by ricashao @ 2020-04-05
-- UINewLogin模型层
-- 注意：
-- 1、成员变量预先在OnCreate、OnEnable函数声明，提高代码可读性
-- 2、OnCreate内放窗口生命周期内保持的成员变量，窗口销毁时才会清理
-- 3、OnEnable内放窗口打开时才需要的成员变量，窗口关闭后及时清理
-- 4、OnEnable函数每次在窗口打开时调用，可传递参数用来初始化Model
--]]

local UINewLoginModel = BaseClass("UINewLoginModel", UIBaseModel)
local base = UIBaseModel

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	-- 窗口生命周期内保持的成员变量放这
end

-- 打开
local function OnEnable(self)
	base.OnEnable(self)
	-- 窗口关闭时可以清理的成员变量放这
	-- 账号
	self.account = nil
	-- 密码
	self.password = nil
	-- 客户端app版本号
	self.client_app_ver = nil
	-- 客户端资源版本号
	self.client_res_ver = nil
	
	self:OnRefresh()
end

-- 刷新全部数据
local function OnRefresh(self)
	local client_data = ClientData:GetInstance()
	self.account = client_data.account
	self.password = client_data.password
	self.client_app_ver = client_data.app_version
	self.client_res_ver = client_data.res_version
end

local function OnLoginSuccess(self)
	self:UIBroadcast(UIMessageNames.UILOGIN_ON_LOGIN_SUCCESS)
end


-- 监听选服变动
local function OnAddListener(self)
	base.OnAddListener(self)
	self:AddDataListener(DataMessageNames.ON_LOGIN_SUCCESS, OnLoginSuccess)
end

local function OnRemoveListener(self)
	base.OnRemoveListener(self)
	self:RemoveDataListener(DataMessageNames.ON_LOGIN_SUCCESS, OnLoginSuccess)
end

-- 关闭
local function OnDisable(self)
	base.OnDisable(self)
	-- 清理成员变量
	self.account = nil
	self.password = nil
	self.client_app_ver = nil
	self.client_res_ver = nil
end

-- 销毁
local function OnDistroy(self)
	base.OnDistroy(self)
	-- 清理成员变量
end

UINewLoginModel.OnCreate = OnCreate
UINewLoginModel.OnEnable = OnEnable
UINewLoginModel.OnRefresh = OnRefresh
UINewLoginModel.OnAddListener = OnAddListener
UINewLoginModel.OnRemoveListener = OnRemoveListener
UINewLoginModel.OnDisable = OnDisable
UINewLoginModel.OnDistroy = OnDistroy

return UINewLoginModel