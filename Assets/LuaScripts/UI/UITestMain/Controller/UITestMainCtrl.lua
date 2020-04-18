--[[
-- added by wsh @ 2018-02-26
-- UITestMain控制层
--]]

local UITestMainCtrl = BaseClass("UITestMainCtrl", UIBaseCtrl)

local function StartFighting(self)
	local msg = MsgIDMap.TestBattle_C2S_Msg()
	WsHallConnector:GetInstance():GetService(ServiceName.CommonBattleService):TestBattle_C2S(msg)
	--SceneManager:GetInstance():SwitchScene(SceneConfig.TestBattleScene)
end

local function Logout(self)
	SceneManager:GetInstance():SwitchScene(SceneConfig.LoginScene)
end

UITestMainCtrl.StartFighting = StartFighting
UITestMainCtrl.Logout = Logout

return UITestMainCtrl