--[[
-- added by ricashao @ 2020-04-05
-- UINewLogin控制层
--]]

local UINewLoginCtrl = BaseClass("UINewLoginCtrl", UIBaseCtrl)
local MsgIDMap = require "Net.Config.MsgIDMap"


local function OnConnect(self, sender, result, msg)
    if result < 0 then
        Logger.LogError("Connect err : " .. msg)
        return
    end
    return
    -- TODO
end

local function OnClose(self, sender, result, msg)
    if result < 0 then
        Logger.LogError("Close err : " .. msg)
        return
    end
end

local function ConnectServer(self)
    WsHallConnector:GetInstance():Connect("127.0.0.1", 10001, Bind(self, OnConnect), Bind(self, OnClose))
end

local function LoginServer(self, name, password)
    -- 合法性检验
    if string.len(name) > 20 or string.len(name) < 1 then
        -- TODO：错误弹窗
        return
    end
    if string.len(password) > 20 or string.len(password) < 1 then
        -- TODO：错误弹窗
        Logger.LogError("password length err!")
        return
    end
    -- 检测是否有汉字
    for i = 1, string.len(name) do
        local curByte = string.byte(name, i)
        if curByte > 127 then
            -- TODO：错误弹窗
            Logger.LogError("name err : only ascii can be used!")
            return
        end
    end

    ClientData:GetInstance():SetAccountInfo(name, password)

    local msg = MsgIDMap.Login_C2S_Msg();
    msg.username = name;
    msg.password = CS.Md5Helper.Md5(password)
    local service = WsHallConnector:GetInstance():GetService(ServiceName.LoginService)
    service:Login_C2S(msg);
    --SceneManager:GetInstance():SwitchScene(SceneConfig.HomeScene)
end


UINewLoginCtrl.LoginServer = LoginServer
UINewLoginCtrl.ConnectServer = ConnectServer

return UINewLoginCtrl