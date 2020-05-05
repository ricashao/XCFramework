---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ricashao.
--- DateTime: 2020/4/20 10:44
---
local BattleSkill_Normal = BaseClass("BattleSkill_Normal")

--@params unitResult: RoundResultUnit[]
function __init(self, battlerId, aimId, skillId, isLoop, unitResult, callBack)
    self.battlerId = battlerId or 0
    self.skillId = skillId or 0
    self.isLoop = isLoop or false
    self.unitResult = unitResult or {}
    self.endCallBack = callBack
    self.aimId = aimId
end

local function Show(self)
    local skillUnit = require "Battle.Skill.Unit.BattleSkillUnit".New(self.battlerId, self.aimId, self.skillId, self.isLoop, self.unitResult, self.endCallBack)
    skillUnit:Show()
end

BattleSkill_Normal.__init = __init
BattleSkill_Normal.Show = Show

return BattleSkill_Normal