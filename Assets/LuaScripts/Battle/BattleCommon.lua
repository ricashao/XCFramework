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

BattleOperate = {
    eNullOperate = 0,
    eAttackOperate = 1, -- 普通攻击
    eSkillOperate = 2, --技能
    eItemOperate = 3, --物品
    eDefenceOperate = 4, --防御
    eProtectOperate = 5, --保护
    eSummonOperate = 6, --召唤
    eRecallOperate = 7, --召回
    eCatchOperate = 8, --捕捉
    eRunawayOperate = 9, --逃跑
    eRestOperate = 10, --休息
    eSpecialOperate = 11, --特殊技能
    eSummonInstant = 12, --瞬间召唤
    eEscapeInstant = 13, --瞬间逃跑
    eOperateFailure = 14, --操作失败
    eAIBattleEnd = 15, --这个客户端不用
    eEnvironmentDemo = 16, --战场环境Demo
    eEnvironmentChange = 17, --战场环境改变
    eRoundEndDemo = 18, --回合末结算demo    与战场环境改变一样，没有DemoSender
    eAINonoOperate = 19, --说话
    eOnlyMove = 20, -- 只移动
}

NewDemoResult = {
    HP_CHANGE = 1, -- 受击者血量变化，为正是加血，为负是扣血
    MP_CHANGE = 2, -- 受击者魔法变化，为正是加蓝，为负是扣蓝
    SP_CHANGE = 3, -- 受击者怒气变化，为正是加怒气，为负是扣怒气
    UL_HP_CHANGE = 4, -- 受击者当前血上限变化，为正是加，为负是减
    TARGET_RESULT = 5, -- 受击者结果类型，ResultType型枚举值叠加
    RETURN_HURT = 6, -- 受击方造成的反伤值，如果为0则代表没有反伤
    ATTACK_BACK = 7, -- 受击方造成的反击值，如果为0则代表没有反击
    STEAL_HP = 8, -- 攻击方产生的吸血值，如果为0则代表没有吸血
    ATTACKER_RESULT = 9, -- 攻击者结果类型，ResultType型枚举值叠加
    PROTECTER_ID = 10, -- 保护者ID
    PROTECTER_HP_CHANGE = 11, -- 保护者血量变化，为正是加血，为负是扣血（显然是为负的）
    PROTECTER_RESULT = 12, -- 保护者结果类型，ResultType型枚举值叠加
    ASSISTER_ID = 13, -- 合击者ID
    STEAL_MP = 14, -- 攻击方产生的吸蓝值，如果为0则代表没有吸蓝
    RETURN_HURT_DEATH = 15, -- 攻击者因为被反伤或反击致死而产生的伤的变化
    PROTECTER_MAXHP_CHANGE = 16, -- 保护者因为保护致死而产生的伤的变化
    MESSAGE_ID = 17, -- 行动时弹的提示ID
}

BattleResult = {}
BattleResult.eBattleResultHPChange = CS.BitOperator.lMove(1, 0)    --生命值变化
BattleResult.eBattleResultMPChange = CS.BitOperator.lMove(1, 1)    --魔法值变化
BattleResult.eBattleResultDefence = CS.BitOperator.lMove(1, 2)    --目标防御
BattleResult.eBattleResultDodge = CS.BitOperator.lMove(1, 3)    --目标闪避
BattleResult.eBattleResultDeath = CS.BitOperator.lMove(1, 4)    --标死亡，倒在原地(现在只有人可以这样)
BattleResult.eBattleResultSummonback = CS.BitOperator.lMove(1, 5)    --目标被召回
BattleResult.eBattleResultRunaway = CS.BitOperator.lMove(1, 6)    --目标逃跑
BattleResult.eBattleResultSeized = CS.BitOperator.lMove(1, 7)    --目标被捕捉
BattleResult.eBattleResultRelive = CS.BitOperator.lMove(1, 8)    --目标被复活
BattleResult.eBattleResultSummon = CS.BitOperator.lMove(1, 9)    --目标被召唤
BattleResult.eBattleResultRest = CS.BitOperator.lMove(1, 10)  --目标休息
BattleResult.eBattleResultULHPChange = CS.BitOperator.lMove(1, 11)    --目标当前血上限变化
BattleResult.eBattleResultFlyOut = CS.BitOperator.lMove(1, 12)    --目标被击飞
BattleResult.eBattleResultGhost = CS.BitOperator.lMove(1, 13)    --目标进入鬼魂状态
BattleResult.eBattleResultParry = CS.BitOperator.lMove(1, 14)    --目标招架 (崩击标志位)
BattleResult.eBattleResultCritic = CS.BitOperator.lMove(1, 15)    --目标被暴击
BattleResult.eBattleResultSPChange = CS.BitOperator.lMove(1, 16)    --目标怒气变化
BattleResult.eBattleResultShowInfo = CS.BitOperator.lMove(1, 17)    --目标信息显示，使用明镜草
BattleResult.eBattleResultRiseHalf = CS.BitOperator.lMove(1, 18)    --目标倒地后原地复活（半血半蓝）
BattleResult.eBattleResultRiseFull = CS.BitOperator.lMove(1, 19)    --目标倒地后原地复活（满血满蓝）
BattleResult.eBattleResultImmunity = CS.BitOperator.lMove(1, 20)    --免疫
BattleResult.eBattleResultDeadRelive = CS.BitOperator.lMove(1, 21)  --被动复活
BattleResult.eBattleResultMax = 22

BattleHitCommon = {
    HitStiff = 1, --正常受击
    HitMiss = 2, --闪避
    HitCrit = 3, --暴击
    HitDefense = 4, 防御
}

BattleArrivePointType = {
    Front = 1,
    Behind = 2,
    Left = 3,
    Right = 4,
};


