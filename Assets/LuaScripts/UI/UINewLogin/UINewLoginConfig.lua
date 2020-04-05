--[[
-- added by ricashao @ 2020-04-05
-- UINewLogin模块窗口配置，要使用还需要导出到UI.Config.UIConfig.lua
-- 一个模块可以对应多个窗口，每个窗口对应一个配置项
-- 使用范例：
-- 窗口配置表 ={
--		名字Name
--		UI层级Layer
-- 		控制器类Controller
--		模型类Model
--		视图类View
--		资源加载路径PrefabPath
-- } 
--]]

-- 窗口配置
local UINewLogin = {
    Name = UIWindowNames.UINewLogin,
    Layer = UILayers.BackgroudLayer,
    Model = require "UI.UINewLogin.Model.UINewLoginModel",
    Ctrl = require "UI.UINewLogin.Controller.UINewLoginCtrl",
    View = require "UI.UINewLogin.View.UINewLoginView",
    PrefabPath = "UI/Prefabs/View/UINewLogin.prefab",
}

local UITreaty = {
    Name = UIWindowNames.UITreaty,
    Layer = UILayers.NormalLayer,
    Model = nil,
    Ctrl = require "UI.UINewLogin.Controller.UITreatyCtrl",
    View = require "UI.UINewLogin.View.UITreatyView",
    PrefabPath = "UI/Prefabs/View/UITreaty.prefab",
}

local UIRegist = {
    Name = UIWindowNames.UIRegist,
    Layer = UILayers.NormalLayer,
    Model = nil,
    Ctrl = require "UI.UINewLogin.Controller.UIRegistCtrl",
    View = require "UI.UINewLogin.View.UIRegistView",
    PrefabPath = "UI/Prefabs/View/UIRegist.prefab",
}

return {
    -- 配置
    UINewLogin = UINewLogin,
    UITreaty = UITreaty,
    UIRegist = UIRegist,
}