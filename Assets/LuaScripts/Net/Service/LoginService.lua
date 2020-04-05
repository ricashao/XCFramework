--[[
-- 使用ProtoTools，从 http://wiki.ricashao.com/doku.php?id=%E7%99%BB%E5%BD%95%E6%A8%A1%E5%9D%97 生成
-- 生成时间 2020-04-05 15:37:19
--]]

local LoginService = BaseClass("LoginService", WsBaseService)
local base = WsBaseService

local function Login_C2S(self, _Login_C2S_Msg) 
	self:Send(101, _Login_C2S_Msg, "Login_C2S_Msg")
end
local function Regist_C2S(self, _Regist_C2S_Msg) 
	self:Send(102, _Regist_C2S_Msg, "Regist_C2S_Msg")
end
local function CreateName_C2S(self, _CreateName_C2S_Msg) 
	self:Send(103, _CreateName_C2S_Msg, "CreateName_C2S_Msg")
end
local function RandomName_C2S(self, _RandomName_C2S_Msg) 
	self:Send(104, _RandomName_C2S_Msg, "RandomName_C2S_Msg")
end
local function EnterGame_C2S(self, _EnterGame_C2S_Msg) 
	self:Send(106, _EnterGame_C2S_Msg, "EnterGame_C2S_Msg")
end
local function Login_S2C (self, data)
	--/*-*begin Login_S2C*-*/--
	-- 这里填写方法中的手写内容
	CommMsgTip:GetInstance():Show(10119);
	DataManager:GetInstance():Broadcast(DataMessageNames.ON_LOGIN_SUCCESS)
	--/*-*end Login_S2C*-*/--
end

local function Regist_S2C (self, data)
	--/*-*begin Regist_S2C*-*/--
	-- 这里填写方法中的手写内容
	--/*-*end Regist_S2C*-*/--
end

local function CreateName_S2C (self, data)
	--/*-*begin CreateName_S2C*-*/--
	-- 这里填写方法中的手写内容
	--/*-*end CreateName_S2C*-*/--
end

local function RandomName_S2C (self, data)
	--/*-*begin RandomName_S2C*-*/--
	-- 这里填写方法中的手写内容
	--/*-*end RandomName_S2C*-*/--
end

local function ForceOffline_S2C (self, data)
	--/*-*begin ForceOffline_S2C*-*/--
	-- 这里填写方法中的手写内容
	--/*-*end ForceOffline_S2C*-*/--
end

local function EnterGame_S2C (self, data)
	--/*-*begin EnterGame_S2C*-*/--
	-- 这里填写方法中的手写内容
	--/*-*end EnterGame_S2C*-*/--
end

--/*-*begin $area2*-*/--
-- 这里填写类里面的手写内容
--/*-*end $area2*-*/--

local function OnRegister(self)
	base.OnRegister(self);

	self:RegMsg("Login_S2C_Msg", 101);
	self:RegHandler(Bind(self, Login_S2C), 101);
	self:RegMsg("Regist_S2C_Msg", 102);
	self:RegHandler(Bind(self, Regist_S2C), 102);
	self:RegMsg("CreateName_S2C_Msg", 103);
	self:RegHandler(Bind(self, CreateName_S2C), 103);
	self:RegMsg("RandomName_S2C_Msg", 104);
	self:RegHandler(Bind(self, RandomName_S2C), 104);
	self:RegMsg("ForceOffline_S2C_Msg", 105);
	self:RegHandler(Bind(self, ForceOffline_S2C), 105);
	self:RegMsg("EnterGame_S2C_Msg", 106);
	self:RegHandler(Bind(self, EnterGame_S2C), 106);
	--/*-*begin $OnRegister*-*/--
	-- 这里填写方法中的手写内容
	--/*-*end $OnRegister*-*/--
end

LoginService.OnRegister = OnRegister
LoginService.Login_C2S = Login_C2S
LoginService.Regist_C2S = Regist_C2S
LoginService.CreateName_C2S = CreateName_C2S
LoginService.RandomName_C2S = RandomName_C2S
LoginService.EnterGame_C2S = EnterGame_C2S

return LoginService
