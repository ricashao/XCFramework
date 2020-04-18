--[[
-- added by wsh @ 2017-11-19
-- 战斗场景
-- TODO：这里只是做一个战斗场景展示Demo，大部分代码以后需要挪除
--]]

local TestBattleScene = BaseClass("BattleScene", BaseScene)
local base = BaseScene

local CharacterAnimation = require "GameLogic.Battle.CharacterAnimation"

-- 临时：角色资源路径
local chara_res_path = "Models/xixuegui/xixuegui.prefab"
local testCharacter
TestGlobal = {}
TestGlobal.battleScene = nil

-- 创建：准备预加载资源
local function OnCreate(self)
    base.OnCreate(self)
    -- TODO
    -- 预加载资源
    self:AddPreloadResource(chara_res_path, typeof(CS.UnityEngine.GameObject), 1)
    self:AddPreloadResource(UIConfig[UIWindowNames.UIBattleMain].PrefabPath, typeof(CS.UnityEngine.GameObject), 1)

    -- 临时：角色动画控制脚本
    self.charaAnim = nil
end

-- 准备工作
local function OnComplete(self)
    base.OnComplete(self)
    InputTouch:GetInstance():SetCamera(GameLayerManager:GetInstance().battleCamera)
    BattleManager:GetInstance():Start()
    UIManager:GetInstance():OpenWindow(UIWindowNames.UIBattleMain)
    --TestGlobal.battleScene = require("Battle.Scene.BattleScenePlane").New()
    --TestGlobal.battleScene:InitScene()
    ---- 创建角色
    --testCharacter = require "Character.Warrior.Warrior".New()
    --testCharacter:Initialize({ shape = chara_res_path }, { x = 4, y = 4 }, 3, function()
    --    testCharacter.transform:SetParent(TestGlobal.battleScene.planeBackground.transform, false)
    --end)
    --testCharacter:SetName(tostring("testname"), UILayers.BattlerNameCamera_1.Name, HUD_TYPE.TOP_NAME);
    --testCharacter:MoveInBattle({ { x = 4, y = 5 }, { x = 4, y = 6 }, { x = 5, y = 6 }, { x = 4, y = 6 }, { x = 4, y = 5 } }, Bind(self, self.TestSpeak))
    --
end

-- 离开场景
local function OnLeave(self)
    self.charaAnim = nil
    UIManager:GetInstance():CloseWindow(UIWindowNames.UIBattleMain)
    BattleManager:GetInstance():Clear()
    base.OnLeave(self)
end

TestBattleScene.OnCreate = OnCreate
TestBattleScene.OnComplete = OnComplete
TestBattleScene.OnLeave = OnLeave

return TestBattleScene;