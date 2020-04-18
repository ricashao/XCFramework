--[[
-- 使用ProtoTools，从 http://www.ricashao.com/doku.php?id=%E9%80%9A%E7%94%A8%E6%88%98%E6%96%97%E6%A8%A1%E5%9D%97 生成
-- 生成时间 2020-04-18 15:56:21
--]]

local CommonBattleService = BaseClass("CommonBattleService", WsBaseService)
local base = WsBaseService

local function TestBattle_C2S(self, _TestBattle_C2S_Msg)
    self:Send(10001, _TestBattle_C2S_Msg, "TestBattle_C2S_Msg")
end
local function TestBattle_S2C (self, data)
    --/*-*begin TestBattle_S2C*-*/--
    -- 这里填写方法中的手写内容
    BattleManager:GetInstance():InitData(data.battlePlay)
    SceneManager:GetInstance():SwitchScene(SceneConfig.TestBattleScene)
    --/*-*end TestBattle_S2C*-*/--
end

--/*-*begin $area2*-*/--
-- 这里填写类里面的手写内容
--/*-*end $area2*-*/--

local function OnRegister(self)
    base.OnRegister(self);

    self:RegMsg("TestBattle_S2C_Msg", 10001);
    self:RegHandler(Bind(self, TestBattle_S2C), 10001);
    --/*-*begin $OnRegister*-*/--
    -- 这里填写方法中的手写内容
    --/*-*end $OnRegister*-*/--
end

CommonBattleService.OnRegister = OnRegister
CommonBattleService.TestBattle_C2S = TestBattle_C2S

return CommonBattleService
