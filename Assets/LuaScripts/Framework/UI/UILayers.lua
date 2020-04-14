--[[
-- added by wsh @ 2017-12-04
-- UILayers配置
--]]

local UILayers = {
    -- 场景UI，如：点击建筑查看建筑信息---一般置于场景之上，界面UI之下
    SceneLayer = {
        Name = "SceneLayer",
        PlaneDistance = 1000,
        OrderInLayer = 0,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    GuiCamera_1_1 = {
        Name = "GuiCamera_1_1",
        PlaneDistance = 800,
        OrderInLayer = 110,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    GuiCamera_1_2 = {
        Name = "GuiCamera_1_2",
        PlaneDistance = 800,
        OrderInLayer = 120,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    BattlerNameCamera_1 = {
        Name = "BattlerNameCamera_1",
        PlaneDistance = 800,
        OrderInLayer = 0,
        CameraType = 1,
        SceneLayer = SceneLayer.BattlerName,
    },
    -- 背景UI，如：主界面---一般情况下用户不能主动关闭，永远处于其它UI的最底层
    BackgroudLayer = {
        Name = "BackgroudLayer",
        PlaneDistance = 900,
        OrderInLayer = 1000,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    -- 普通UI，一级、二级、三级等窗口---一般由用户点击打开的多级窗口
    NormalLayer = {
        Name = "NormalLayer",
        PlaneDistance = 800,
        OrderInLayer = 2000,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    -- 信息UI---如：跑马灯、广播等---一般永远置于用户打开窗口顶层
    InfoLayer = {
        Name = "InfoLayer",
        PlaneDistance = 700,
        OrderInLayer = 3000,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    -- 提示UI，如：错误弹窗，网络连接弹窗等
    TipLayer = {
        Name = "TipLayer",
        PlaneDistance = 600,
        OrderInLayer = 4000,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    SystemInfoLayer = {
        Name = "SystemInfoLayer",
        PlaneDistance = 500,
        OrderInLayer = 5000,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
    -- 顶层UI，如：场景加载
    TopLayer = {
        Name = "TopLayer",
        PlaneDistance = 400,
        OrderInLayer = 6000,
        CameraType = 0,
        SceneLayer = SceneLayer.UI,
    },
}

return ConstClass("UILayers", UILayers)