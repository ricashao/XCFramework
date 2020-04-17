local TweenNano = {}
local tween = require "Utils.Tween.Tween"
local tweenTarget = require "Utils.Tween.TweenTarget"

TWEEN_CLOSE_CHANGE_SCENE = 1 --- 切换场景
TWEEN_CLOSE_ENTER_BATTLE = 2 --- 进入战斗
TWEEN_CLOSE_BATTLE_OR_SCENE_CHANGE = 3 --- 进入战斗或切换场景[默认值]

TWEEN_CLOSE_CHANGE_MAINSCENEVIEW = 4 --主界面的滑动显示和隐藏

local targetList = {}
local tweenList = {}
--[[
	@param  duration   时间
	@param  ui    UI
	@param  props     目标点
	@param  easing 	   缓动函数 
	@param  onupdate   每帧变化的回调函数
	@param  onComplete 运行结束的回调函数
	@param  passdata   回传参数
  @param  closetype  销毁类型参数（比如，切换场景销毁，进入战斗销毁）
]]

function TweenNano.Create(duration, ui, props, easing, onUpdate, onComplete, passdata, closetype)

    if not ui then
        if error then
            error("无法给空对象添加tweennano")
        end
        return
    end
    ----覆盖之前的tween
    local key = tostring(ui)
    if targetList[key] then
        -- if info then info("Tween 覆盖之前的动画 " .. ui.name) end
        TweenNano.Remove(targetList[key])
    end

    local obj = tweenTarget.New(ui, props, key)
    local t = tween.new(duration, obj, props, easing, onUpdate, passdata, closetype)
    t.onComplete = onComplete
    t.passdata = passdata
    t:Start()

    targetList[key] = t
    return t

end

function TweenNano.CloseTweenByType(closetype)

    local temp = {}
    for k, v in pairs(targetList) do
        temp[k] = v
    end

    for k, v in pairs(temp) do
        if v.closetype == closetype then
            TweenNano.Remove(v)
        end
    end
    temp = nil

end

----private:
function TweenNano.RunEnd(tween, obj)

    TweenNano.Remove(tween)

    obj:TweenEnd()
    if tween.onComplete then
        tween.onComplete(tween.passdata)
        tween.onComplete = nil
    end

end

----移除动画
function TweenNano.Remove(tween)

    local key = tween.subject:GetKey()
    targetList[key] = nil

    tween:Remove()

end

----移除动画，并且设置成目标状态
function TweenNano.ForceClose(tween)

    if (not tween) or tween.isRunEnd then
        return
    end

    TweenNano.Remove(tween)
    local obj = tween.subject
    obj:TweenEnd()
    if tween.onComplete then
        tween.onComplete(tween.passdata)
        tween.onComplete = nil
    end
end

return TweenNano