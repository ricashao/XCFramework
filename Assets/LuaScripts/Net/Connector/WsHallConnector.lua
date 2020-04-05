--[[
-- added by ricashao @ 2020-03-24
-- websocket网络连接器
--]]

local WsHallConnector = BaseClass("WsHallConnector", Singleton)
local SendMsgDefine = require "Net.Config.SendMsgDefine"
local NetUtil = require "Net.Util.NetUtil"
local MsgIDMap = require("Net.Config.MsgIDMap")

local ConnStatus = {
    Init = 0,
    Connecting = 1,
    WaitLogin = 2,
    Done = 3,
}

local function __init(self)
    self.listenerMaps = {}
    self.recieveMSG = {}
    self.hallSocket = nil
    self.globalSeq = 0
end

local function Startup(self)
    self.serviceMaps = {};
    local loginService = require("Net.Service.LoginService").New();
    self.serviceMaps[ServiceName.LoginService] = loginService;
    loginService:OnRegister();
end

local function OnReceivePackage(self, data)
    local index = 1
    --数据长度
    local length = string.unpack(">I4", data, index) - 12;
    index = index + 4
    --cmd
    local cmd = string.unpack(">I4", data, index)
    index = index + 4
    --code
    local code = string.unpack(">I4", data, index)
    index = index + 4
    if (code > 0) then
        --todo 弹消息框
        CommMsgTip:GetInstance():Show(code)
        return ;
    end

    local ref = self.recieveMSG[cmd];
    local msg_obj = MsgIDMap[ref]();
    if msg_obj == nil then
        Logger.LogError("No proto type match msg id : " .. msg_id)
    end
    local pb_data = string.sub(data, index, index + length - 1)
    msg_obj:ParseFromString(pb_data)
    local func = self.listenerMaps[cmd];

    if (func ~= nil) then
        func(msg_obj)
    end
end

local function Connect(self, host_ip, host_port, on_connect, on_close)
    if not self.hallSocket then
        self.hallSocket = CS.Networks.WsNetwork()
        self.hallSocket.ReceivePkgHandle = Bind(self, OnReceivePackage)
    end
    self.hallSocket.OnConnect = on_connect
    self.hallSocket.OnClosed = on_close
    self.hallSocket:SetHostPort(host_ip, host_port)
    self.hallSocket:Connect()
    Logger.Log("Connect to " .. host_ip .. ", port : " .. host_port)
    return self.hallSocket
end

local function SendMessage(self, msg_id, msg_obj, show_mask, need_resend)
    show_mask = show_mask == nil and true or show_mask
    need_resend = need_resend == nil and true or need_resend

    local request_seq = 0
    local send_msg = SendMsgDefine.New(msg_id, msg_obj, request_seq)
    local msg_bytes = NetUtil.WsSerializeMessage(send_msg)
    Logger.Log(tostring(send_msg))
    self.hallSocket:SendMessage(msg_bytes)
end

local function Update(self)
    if not IsNull(self.hallSocket) then
        self.hallSocket:UpdateNetwork()
    end
end

local function Disconnect(self)
    if self.hallSocket then
        self.hallSocket:Disconnect()
    end
end

local function Dispose(self)
    if self.hallSocket then
        self.hallSocket:Dispose()
    end
    self.hallSocket = nil
end

-- 基础类型消息
local function RegRecieveMSGRef(self, cmd, ref)
    self.recieveMSG[cmd] = ref;
end

-- 注册处理器
-- @param cmd 协议号
-- @param handler 处理网络数据的处理器
-- @param {number} priority 处理优先级
local function Register(self, cmd, handler, priotity)
    self.listenerMaps[cmd] = handler;
end

local function GetService(self, servicename)
    return self.serviceMaps[servicename];
end

WsHallConnector.__init = __init
WsHallConnector.Connect = Connect
WsHallConnector.SendMessage = SendMessage
WsHallConnector.Update = Update
WsHallConnector.Disconnect = Disconnect
WsHallConnector.Dispose = Dispose
WsHallConnector.Startup = Startup
WsHallConnector.RegRecieveMSGRef = RegRecieveMSGRef
WsHallConnector.Register = Register
WsHallConnector.GetService = GetService

return WsHallConnector
