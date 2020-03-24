--[[
-- added by ricashao @ 2020-03-24
-- 用于和服务端通信基类
-- 注意：
--]]
local WsBaseService = BaseClass("WsBaseService")

-- 创建：变量定义，初始化，消息注册
-- 注意：窗口生命周期内保持的成员变量放这
local function OnRegister(self)
    --注册的时候连接器一定存在
    self.__ns = WsHallConnector:GetInstance()
    assert(self.__ns ~= nil)
end

--注册消息引用
local function RegMsg(self, ref, ...)
    local ns = this.__ns;
    for _, cmd in ipairs(...) do
        ns:RegRecieveMSGRef(cmd, ref);
    end
end

--注册消息处理函数
local function RegHandler(self, func, cmd)
    local ns = this.__ns;
    ns:Register(cmd, func);
end

--发送消息
--@param cmd 指令
--@param data 数据
--@param msgType 数据类型
--@param limit 最短发送时间
local function Send(self, cmd, data, msgType, limit)
    local limit = limit or 100;
    this.__ns:Send(cmd, data, msgType, limit);
end

WsBaseService.OnRegister = OnRegister
WsBaseService.RegMsg = RegMsg
WsBaseService.RegHandler = RegHandler
WsBaseService.Send = Send

return WsBaseService;


