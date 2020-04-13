--[[
-- added by ricashao @ 2020-04-13
-- 单位动作
--]]
local UnitAction = BaseClass("UnitAction")
local _isEnd
local defaultAction = {
    mountType = MountType.ground,
    action = ActionType.standBy,
}

--根据坐骑状态，获取人物动作序列的配置
--@param {MountType} mountType 坐骑状态
--@returns {IUnitActionInfo} 动作结果
local function GetAction(self, mountType)
    return defaultAction
end

--单位播放动作
-- 如果子类要制作动态的自定义动作，重写此方法
-- @param {Unit} unit               单位
-- @param {MountType} mountType     骑乘状态
local function PlayAction(self, unit, mountType)
    local aData = self:GetAction(mountType)
    unit:DoAction(aData.action)
end

--播放动作
local function Start(self, unit, has, callback)
    _isEnd = false
end

-- 检查当前动作是否可以结束
-- @return true 可以结束
--         false 不可结束

local function CanStop(self)
    return true
end

-- 强制结束
local function Terminate(self, unit)

end

--动画播放结束的回调
local function PlayComplete(self)
    _isEnd = true
end

--动作是否已经结束
-- @return true，动作已经结束，可以做下一个动作
--         false, 动作未结束，
local function IsEnd(self)
    return _isEnd
end

local function DispatchEvent(self, unit, eventType)

end

-- 渲染时执行
local function DoRender(self, unit)

end

UnitAction.DoRender = DoRender
UnitAction.GetAction = GetAction
UnitAction.PlayAction = PlayAction
UnitAction.Start = Start
UnitAction.CanStop = CanStop
UnitAction.Terminate = Terminate
UnitAction.PlayComplete = PlayComplete
UnitAction.IsEnd = IsEnd
UnitAction.DispatchEvent = DispatchEvent
UnitAction.DoRender = DoRender

return UnitAction