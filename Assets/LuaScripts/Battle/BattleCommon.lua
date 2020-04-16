BattleCommon = {
    -- 战斗一方最多14个单位
    OneSideMaxNum = 14,

    --友方编号从1 - 14
    FriendMinID = 1,
    FriendMaxID = 14,
    --敌方编号从15 - 29
    EnemyMinID = 16,
    EnemyMaxID = 29,

    FriendSideDir = 1,
    EnemySideDir = 3,
    DefaultSkill = 100001
}

--战斗状态
BattleState = {
    eBattleStateNull = 0,
    eBattleStateBegin = 1, --切入战斗 包含loading and init
    eBattleStateAIBeforeShow = 2, --演示前AI演示
    eBattleStateOperateChar = 3, --战斗人物操作状态  --本项目无用
    eBattleStateOperatePet = 4, --战斗宠物操作状态   --本项目无用
    eBattleStateWaitShow = 5, --等待状态            --本项目无用
    eBattleStateShow = 6, --战斗演示状态
    eBattleStateWaitEnd = 7, --演示和操作状态中的过度阶段 --本项目无用
    eBattleStateAIBeforeBattleEnd = 8, --战斗结束前AI
    eBattleStateEnd = 9,
    eBattleStateMax = 10,
}

BattleStateEvent = {
    BattleBegin = 1,
    BattleBeforeAI = 2,
    BattleOpeChar = 3, --本项目无用
    BattleOpePet = 4, --本项目无用
    BattleWaitShow = 5, --本项目无用
    BattleShow = 6,
    BattleWaitEnd = 7,
    BattleAIBeforeEnd = 8,
    BattleEnd = 9,
}

BattlerType = {
    eBattlerCharacter = 1, --角色
    eBattlerCreeps = 2, --怪物
    eBattlerNpc = 3, --NPC（特殊的）
    eBattlerMax = 4,
}
