--[[
-- added by wsh @ 2018-02-26
-- UIBattleMain视图层
--]]

local UIBattleMainView = BaseClass("UIBattleMainView", UIBaseView)
local base = UIBaseView

-- 各个组件路径
local back_btn_path = "BackBtn"
local battle_btn_path = "BattleBtn"

local function OnCreate(self)
	base.OnCreate(self)
	-- 退出按钮
	self.back_btn = self:AddComponent(UIButton, back_btn_path)
	self.back_btn:SetOnClick(function()
		self.ctrl:Back()
	end)
	self:AddComponent(UIButton, battle_btn_path):SetOnClick(function()
		BattleManager:GetInstance():PlayRound()
	end)
end

local function OnEnable(self)
	base.OnEnable(self)
end

local function OnDestroy(self)
	base.OnDestroy(self)
end

UIBattleMainView.OnCreate = OnCreate
UIBattleMainView.OnEnable = OnEnable
UIBattleMainView.OnDestroy = OnDestroy

return UIBattleMainView