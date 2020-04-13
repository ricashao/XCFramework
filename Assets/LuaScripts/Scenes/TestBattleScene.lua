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
    local battleScene = require("Battle.Scene.BattleScenePlane").New()
    battleScene:InitScene()
    -- 创建角色
    local chara = GameObjectPool:GetInstance():GetGameObjectAsync(chara_res_path, function(inst)
        if IsNull(inst) then
            error("Load chara res err!")
            do
                return
            end
        end

        inst.transform:SetParent(battleScene.planeBackground.transform, false)

        UIManager:GetInstance():OpenWindow(UIWindowNames.UIBattleMain)
    end)

end

-- 离开场景
local function OnLeave(self)
    self.charaAnim = nil
    UIManager:GetInstance():CloseWindow(UIWindowNames.UIBattleMain)
    base.OnLeave(self)
end

TestBattleScene.OnCreate = OnCreate
TestBattleScene.OnComplete = OnComplete
TestBattleScene.OnLeave = OnLeave

return TestBattleScene;