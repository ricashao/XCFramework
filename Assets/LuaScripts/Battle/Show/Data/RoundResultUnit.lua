---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Administrator.
--- DateTime: 2020/4/16 22:44
---
local RoundResultUnit = BaseClass("RoundResultUnit")

local function __init(self)
    self.targetId = 0
    self.hpChange = 0
    --被击者效果
    self.eTargetResult = 0
    --受击方造成的反击值，如果为0则代表没有反击
    self.returnHurt = 0
    self.attackBack = 0
    --攻击者效果
    self.eAttackerResult = 0
    --保护者Id
    self.protecterId = 0
    self.protectHpChange = 0
    --保护者效果
    self.eProtecterResult = 0
    --合击者ID
    self.assisterId = 0
    self.buffs = {}
end

local function Parse(self, data)
    self.targetId = data.targetId
    self.buffs = data.demobuffs
    for _, v in pairs(self.buffs) do
        if v.key == NewDemoResult.HP_CHANGE then
            self.hpChange = v
        elseif v.key == NewDemoResult.TARGET_RESULT then
            self.eTargetResult = v
        elseif v.key == NewDemoResult.RETURN_HURT then
            self.returnHurt = v
        elseif v.key == NewDemoResult.ATTACK_BACK then
            self.attackBack = v
        elseif v.key == NewDemoResult.ATTACKER_RESULT then
            self.eAttackerResult = v
        elseif v.key == NewDemoResult.PROTECTER_ID then
            self.protecterId = v
        elseif v.key == NewDemoResult.PROTECTER_HP_CHANGE then
            self.protectHpChange = v
        elseif v.key == NewDemoResult.PROTECTER_RESULT then
            self.eProtecterResult = v
        elseif v.key == NewDemoResult.ASSISTER_ID then
            self.assisterId = v
        end
    end
end

local function DealResult(self)
    local battlemgr = BattleManager:GetInstance()
    for _, buff in pairs(self.buffs) do
        local battler = battlemgr:GetBattle():FindBattlerByID(buff.fighterid)
        if battler then
            battler:GetBuffAgent():UpdateBuff(buff)
            --facade.executeMediator(ModuleId.Battle, false, "refreshBattlerBuff", true, battler.getBattlerId())
        end
    end

    local battler = battlemgr:GetBattle():FindBattlerByID(self.targetId)
    if battler then
        --TODO 临时处理，将来修改成调用hit的接口
        if self.hpChange ~= nil then
            --local skillAttr = UISkillAttr.New(battler:GetCharacter(), CameraLayer.GuiCamera_1_2)
            --skillAttr:SetUISkillAttr(self.hpChange, CHARACTER_POPUP_TYPE.HP)
        end
        battler:DealAttrWithBattleResult(self)
        battler:DealActionWithBattleResult(self)
    end
end

RoundResultUnit.__init = __init
RoundResultUnit.Parse = Parse
RoundResultUnit.DealResult = DealResult
return RoundResultUnit