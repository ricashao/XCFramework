---
--- 一个动作只需要一种，直接做全局缓存 本项目没有骑乘 所以这个方法只是走个形式
--- Created by ricashao.
--- DateTime: 2020/4/17 7:46
---
local UnitActionManager = BaseClass("UnitActionManager", Singleton)

local function __init(self)
    -- kv
    self._actions = {}
end

local function GetAction(self, action)
    local info = self._actions[action]
    if not info then
        info = { mountType = MountType.ground, action = action }
        self._actions[action] = info
    end
    return info
end

UnitActionManager.__init = __init
UnitActionManager.GetAction = GetAction
return UnitActionManager