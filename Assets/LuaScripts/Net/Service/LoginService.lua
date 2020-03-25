--[[
-- 使用ProtoTools，从 http://wiki.ricashao.com/doku.php?id=%E7%99%BB%E5%BD%95%E6%A8%A1%E5%9D%97 生成
-- 生成时间 2020-03-25 08:31:59
--]]

local LoginService = BaseClass("LoginService", WsBaseService)
local base = WsBaseService
local function OnRegister(self)
	base.OnRegister(self);

	self:RegMsg("Login_S2C_Msg", 101);
	self:RegHandler(self.Login_S2C, 101);
	self:RegMsg("Regist_S2C_Msg", 102);
	self:RegHandler(self.Regist_S2C, 102);
	self:RegMsg("CreateName_S2C_Msg", 103);
	self:RegHandler(self.CreateName_S2C, 103);
	self:RegMsg("RandomName_S2C_Msg", 104);
	self:RegHandler(self.RandomName_S2C, 104);
	self:RegMsg("ForceOffline_S2C_Msg", 105);
	self:RegHandler(self.ForceOffline_S2C, 105);
	--/*-*begin $onRegister*-*/--
	-- 这里写onRegister中手写内容
	--/*-*end $onRegister*-*/--
end
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
local function Login_S2C (self, data)
	--/*-*begin Login_S2C*-*/--
	-- 这里填写方法中的手写内容
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
--/*-*begin $area2*-*/--
-- 这里填写类里面的手写内容
--/*-*end $area2*-*/--

LoginService.OnRegister = OnRegister

return LoginService
