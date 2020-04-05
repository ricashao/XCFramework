--[[
-- added by ricashao @ 2020-04-05
-- UITreaty视图层
-- 注意：
-- 1、成员变量最好预先在__init函数声明，提高代码可读性
-- 2、OnEnable函数每次在窗口打开时调用，直接刷新
-- 3、组件命名参考代码规范
--]]
local UITreatyView = BaseClass("UITreatyView", UIBaseView)
local base = UIBaseView

-- 各个组件路径
local close_btn_path = "ContentRoot/CloseBtn"

local function ClickOnCloseBtn(self)
    self.ctrl:CloseSelf()
end


local function OnCreate(self)
    base.OnCreate(self)
    -- 初始化各个组件
    self.close_btn = self:AddComponent(UIButton, close_btn_path)
    -- 使用方式二：私有函数、成员函数绑定
    self.close_btn:SetOnClick(self, ClickOnCloseBtn)

end

local function OnDestroy(self)
    self.close_btn = nil
    -- 测试代码
    base.OnDestroy(self)
end

UITreatyView.OnCreate = OnCreate
UITreatyView.OnDestroy = OnDestroy

return UITreatyView

