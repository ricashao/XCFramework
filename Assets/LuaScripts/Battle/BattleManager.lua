---
--- 战斗管理器
--- Created by ricashao.
--- DateTime: 2020/4/16 11:18
---
local BattleManager = BaseClass("BattleManager", Singleton)

local isBattle = false
local battle = nil
--- 播放数据
local battlePlay = nil
local playIndex = 1
local rounds = nil
local curRound = nil

--- private start --- 
local function InitBattleStart(data)
    if (isBattle == true) then
        Logger.LogError("BattleManager EnterBattle warn, already in battle")
    end
    isBattle = true
    --- 创建新的战场
    battle = require "Battle.Battle".New()
    battle:EnterBattle(data)
end

local function InitBattlerData(data)
    if (this.isBattle == false) then
        Logger.LogError("BattleManager InitRoundScript warn, not in battle")
    end
    battle:AddBattlerData(data)
    ---初始化战斗界面上的数据
    --todo 添加
    --local hostList = {}
    --local guestList = {}
    --for (let info of data.fighterlist) {
    --let vo = new BattleCardVO;
    --vo.cardId = info.dataid;
    --vo.fighterIndex = info.index;
    --vo.leader = info.isLeader;
    --info.index < BattleCommon.OneSideMaxNum ? hostList.push(vo) : guestList.push(vo);
    --}
    --facade.executeMediator(ModuleId.Battle, false, "initBattleFighter", true, hostList, guestList)
end

local function InitBattleEnd(battleEnd)
    if (isBattle == false) then
        return
    end
end

local function InitRoundScript(data)
    if (isBattle == false) then
        Logger.LogError("BattleManager InitRoundScript warn, not in battle")
    end
    battle:AddRoundScript(data)
end

local function InitRoundStart(data)
    if (isBattle == false) then
        Logger.LogError("BattleManager InitRoundScript warn, not in battle")
    end

    battle:DoBattleClear()
    battle:RoundStart(data)
    battle:GetBattleState():TriggerEvent(BattleStateEvent.BattleBeforeAI)
end

local function InitRound(data)
    rounds = data
    playIndex = 0
end

--- private end --- 

local function InitData(self, data)
    battlePlay = data
end

local function Start(self)
    InitBattleStart(battlePlay.battleStart)
    InitBattlerData(battlePlay.addFighters)
    InitBattleEnd(battlePlay.battleEnd)
    InitRound(battlePlay.roundList)
end

local function GetBattle(self)
    if (isBattle == false) then
        return null
    end
    return battle
end

local function Clear(self)
    isBattle = false
    battle:Deleta()
    battle = nil
end

local function Replay(self)
    self:Clear()
    self:Start()
    self:PlayRound()
end

local function PlayRound(self)
    curRound = rounds[playIndex]
    --facade.executeMediator(ModuleId.Battle, false, "setBattleRound", true, this.playIndex + 1)
    InitRoundScript(curRound.roundScript)
    InitRoundStart(curRound.roundStart)
end

local function PlayNextRound(self)
    playIndex = playIndex + 1
    if playIndex > table.length(rounds) then
        battle:PrintResult()
        --TODO 战斗结束前AI
        battle:GetBattleState():TriggerEvent(BattleStateEvent.BattleAIBeforeEnd)
        return
    end
    curRound = rounds[playIndex]
    --facade.executeMediator(ModuleId.Battle, false, "setBattleRound", true, this.playIndex)
    InitRoundScript(round.roundScript)
    InitRoundStart(round.roundStart)
end

BattleManager.InitData = InitData
BattleManager.Start = Start
BattleManager.GetBattle = GetBattle
BattleManager.Clear = Clear
BattleManager.Replay = Replay
BattleManager.PlayRound = PlayRound
BattleManager.PlayNextRound = PlayNextRound
return BattleManager