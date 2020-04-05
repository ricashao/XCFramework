--[[
-- added by ricashao @ 2020-04-05
-- UIRegistCtrl控制层
--]]

local UIRegistCtrl = BaseClass("UIRegistCtrl", UIBaseCtrl)
local MsgIDMap = require "Net.Config.MsgIDMap"

local function CloseSelf(self)
    UIManager:GetInstance():CloseWindow(UIWindowNames.UIRegist)
end

local function RegistAccount(self, account, id, pwd, pwd2)
    if (account == "") then
        CommMsgTip:GetInstance():Show(10121)
        return
    end
    if (pwd == "") then
        CommMsgTip:GetInstance():Show(10123)
        return
    end
    if (pwd2 == "") then
        CommMsgTip:GetInstance():Show(10124)
        return
    end
    if (id.text == "") then
        CommMsgTip:GetInstance():Show(10122)
        return
    end

    if (pwd ~= pwd2) then
        CommMsgTip:GetInstance():Show(10120)
        return
    end

    local msg = MsgIDMap.Regist_C2S_Msg()
    msg.username = account
    msg.password = pwd
    local service = WsHallConnector:GetInstance():GetService(ServiceName.LoginService)
    service:Regist_C2S(msg)
    
end

UIRegistCtrl.CloseSelf = CloseSelf
UIRegistCtrl.RegistAccount = RegistAccount

return UIRegistCtrl