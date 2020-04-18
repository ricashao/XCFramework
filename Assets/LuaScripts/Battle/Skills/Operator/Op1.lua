---
--- 对单点进行普通攻击(包含连击)
--- Created by ricashao.
--- DateTime: 2020/4/17 23:54
---
local Op1 = BaseClass("Op1",AttackAction)
local base = AttackAction

local function OnFire(self, context)
    base.OnFire(self, context)
    BattleHit:GetInstance():ResponseHitByEvent(context.fighterId, context.skillConfig, context.unitResult, Bind(self, self.OnHitEnd))
    if CS.BitOperator.And(BattleResult.eBattleResultDodge, context.unitResult[1].eTargetResult) ~= BattleResult.eBattleResultDodge and cfg.hitEf ~= "" then
        local decode = EfDecode.Decode(context.skillConfig.hitEf)
        local aniOption = {
            handler = BindCallback(self, self.HandlerAniEvent)
        }

        self._ac:PlayAniByType(decode.efType, decode.ef, context.mainTarget, aniOption)
    end
end

local function HandlerAniEvent(self, event, ani, ...)

end

local function OnHitEnd(self)
    self.finalCallback()
end

Op1.HandlerAniEvent = HandlerAniEvent
Op1.OnFire = OnFire
Op1.OnHitEnd = OnHitEnd
return Op1