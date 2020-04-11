--[[
    触摸操作代理
	
	基本流程：在TouchProxy注册需要监听的 ==>> InputTouch判断，调用Lua相应函数 ==>> TouchProxy进行处理

	通用事件方法：
		TouchProxy.RegisterEvent(self, TouchType.xxx, callBack);
		TouchProxy.UnregisterEvent(self, TouchType.xxx);

	UI事件方法：
		-- 长按循环触发事件注册
		TouchProxy.RegisterUIPress(self.voice, 1, M.Test, self);
		TouchProxy.UnregisterPress(self.voice);

		function M:Test()
    		info("Bingo!!!!!!!!")
		end
	
	参数：eventData（对应InputTouch中的Finger类）
    
    Finger属性：

	PickedGameObject  			-- 选中的3D对象
	CurrentSelectedGameObject	-- EventSystem当前选中的对象（继承Selectable的组件，如Button，Toggle等）
	IsOverUI					-- 是否在UI上
	Position					-- 操作位置
	StartPosition				-- 操作开始的位置
	EndPosition					-- 操作结束的位置
	DeltaPosition				-- 变化位置
	HoldTime					-- 动作保持的时间
--]]
local TouchProxy = BaseClass("TouchProxy", Singleton)

TouchType = {
    Down = 0;
    Up = 1;
    Click = 2,
    DragBegin = 3,
    Drag = 4,
    DragEnd = 5,
    Press = 6
}

local downEventMaps = {};
local upEventMaps = {};
local clickEventMaps = {};
local pressEventMaps = {};
local dragBeginEventMaps = {};
local dragEventMaps = {};
local dragEndEventMaps = {};

local uiPressMaps = {};
local uiClickMaps = {};

local function __init(self)
    self.lastClickPosition = Vector2.zero;
end

----------------------------------------------  通用事件  ---------------------------------------------
--[[
	注册监听事件
	listener 	--监听者
	event		--监听的事件类型
	callBack 	--触发函数
--]]
local function RegisterEvent(self, listener, event, callBack)
    local key = tostring(listener);
    local list = {};
    list.callBack = callBack;
    list.listener = listener;

    if event == TouchType.Down then
        downEventMaps[key] = list;
    elseif event == TouchType.Up then
        upEventMaps[key] = list;
    elseif event == TouchType.Click then
        clickEventMaps[key] = list;
    elseif event == TouchType.Press then
        pressEventMaps[key] = list;
    elseif event == TouchType.DragBegin then
        dragBeginEventMaps[key] = list;
    elseif event == TouchType.Drag then
        dragEventMaps[key] = list;
    elseif event == TouchType.DragEnd then
        dragEndEventMaps[key] = list;
    end
end

--[[
	注销监听事件
	listener 	--监听者
	event		--监听的事件类型
--]]
local function UnregisterEvent(self, listener, event)
    local key = tostring(listener);
    if event == TouchType.Down then
        if downEventMaps[key] then
            downEventMaps[key] = nil;
        end
    elseif event == TouchType.Up then
        if upEventMaps[key] then
            upEventMaps[key] = nil;
        end
    elseif event == TouchType.Click then
        if clickEventMaps[key] then
            clickEventMaps[key] = nil;
        end
    elseif event == TouchType.Press then
        if pressEventMaps[key] then
            pressEventMaps[key] = nil;
        end
    elseif event == TouchType.DragBegin then
        if dragBeginEventMaps[key] then
            dragBeginEventMaps[key] = nil;
        end
    elseif event == TouchType.Drag then
        if dragEventMaps[key] then
            downEventMaps[key] = nil;
        end
    elseif event == TouchType.DragEnd then
        if dragEndEventMaps[key] then
            dragEndEventMaps[key] = nil;
        end
    end
end

----------------------------------------------  UI事件  -----------------------------------------------
--[[
	UI注册长按（封装了一个计时器，可以设置循环，如：长按按钮，某个数值按照间隔时间一直增长）
	
	如果后面四个参数全都没有，就是普通的回调监听，如果有，就是使用了计时器

	@param target 		--监听目标,Transform或者GameObject类型
	@param callBack     --回调方法
	@param data         --回传参数
	@param delay		--触发时间
	@param loop     	--是否循环
	@param useFrame     --是否使用帧数
--]]
local function RegisterUIPress(self, target, callBack, data, delay, loop, useFrame)
    if not target or not target.gameObject then
        if error then
            error("Register ui press timer need a gameObject as target")
        end
        return
    end

    local key = target.gameObject:GetInstanceID()
    if uiPressMaps[key] then
        local timer = uiPressMaps[key].timer
        if timer then
            timer:Stop()
            timer = nil
        end
    else
        uiPressMaps[key] = {}
    end

    if not delay and not loop and not useFrame then
        local pressTarget = {}
        pressTarget.callBack = callBack
        pressTarget.data = data
        uiPressMaps[key].pressTarget = pressTarget
    else
        uiPressMaps[key].timer = require "Framework.Timer".New(delay, callBack, data, loop, useFrame)
    end
end

--[[
	UI注销长按
--]]
local function UnregisterUIPress(self, target)
    if not target or not target.gameObject then
        if error then
            error("Unregister ui press timer need a gameObject as target, Please your RegisterPressTimer function.")
        end
        return
    end

    local key = target.gameObject:GetInstanceID();
    if uiPressMaps[key] then
        local timer = uiPressMaps[key].timer;
        if timer then
            timer:Stop();
            timer = nil;
        end

        uiPressMaps[key] = nil;
    end
end

--[[
	UI注册点击
	@param target 		--监听目标,Transform或者GameObject类型
	@param callBack     --回调方法
	@param data         --回传参数
--]]
local function RegisterUIClick(self, target, callBack, data)
    if not target or not target.gameObject then
        if error then
            error("Unregister ui click need a gameObject as target, Please your RegisterPressTimer function.")
        end
        return
    end

    local key = target.gameObject:GetInstanceID();
    if uiClickMaps[key] then
        uiClickMaps[key].callBack = callBack;
        uiClickMaps[key].data = data;
    else
        local clickTarget = {};
        clickTarget.callBack = callBack;
        clickTarget.data = data;
        uiClickMaps[key] = clickTarget;
    end
end

--[[
	UI注销点击
--]]
local function UnregisterUIClick(self, target)
    if not target or not target.gameObject then
        if error then
            error("Unregister ui click need a gameObject as target, Please your RegisterPressTimer function.")
        end
        return
    end

    local key = target.gameObject:GetInstanceID();
    if uiClickMaps[key] then
        uiClickMaps[key] = nil;
    end
end

----------------------------------------------  触发事件  ---------------------------------------------
-- 按下
local function OnTouchDown(self, eventData)
    --print("触发按下事件")
    self.lastClickPosition = eventData.pos;

    for k,v in pairs(downEventMaps) do
        v.callBack(eventData, v.listener);
    end

end

-- 抬起
local function OnTouchUp(self, eventData)
    --print("触发抬起事件")
    for k,v in pairs(upEventMaps) do
        v.callBack(eventData, v.listener);
    end
end

-- 开始拖拽
local function OnTouchDragBegin(self, eventData)
    --print("开始拖拽")
    for k,v in pairs(dragBeginEventMaps) do
        v.callBack(eventData, v.listener);
    end
end

-- 拖拽
local function OnTouchDrag(self, eventData)
    --print("拖拽")
    for k,v in pairs(dragEventMaps) do
        v.callBack(eventData, v.listener);
    end

end

-- 拖拽结束
local function OnTouchDragEnd(self, eventData)
    --print("拖拽结束")
    for k,v in pairs(dragEndEventMaps) do
        v.callBack(eventData, v.listener);
    end
end

-- 点击
local function OnTouchClick(self, eventData)
    --print("点击")
    for k,v in pairs(clickEventMaps) do
        v.callBack(eventData, v.listener);
    end

    -- UI点击
    if not IsNull(eventData.currentSelectedGameObject) then
        local key = eventData.currentSelectedGameObject:GetInstanceID();
        if uiClickMaps and uiClickMaps[key] then
            local clickTarget = uiClickMaps[key];
            if clickTarget.callBack then
                clickTarget.callBack(clickTarget.data);
            end
        end
    end

    -- if info then info("屏幕点击position:" .. eventData.Position.x .. "|" .. eventData.Position.y) end
    --UIManager:GetInstance():CheckOutClick(eventData.Position);
    --UIManager:GetInstance():CheckComponentClick(eventData.Position);
end

-- 触发按住事件
local function OnTouchPress(self, eventData)
    --print("触发按住事件")
    if not IsNull(eventData.currentSelectedGameObject) then
        local key = eventData.currentSelectedGameObject:GetInstanceID();
        if uiPressMaps and uiPressMaps[key] and uiPressMaps[key].timer then
            uiPressMaps[key].timer:Stop();
        end
    end
end

-- 按住事件结束
local function OnTouchPressEnd(self, eventData)
    --print("按住事件结束")
    if not IsNull(eventData.currentSelectedGameObject) then
        local key = eventData.currentSelectedGameObject:GetInstanceID();
        if uiPressMaps and uiPressMaps[key] and uiPressMaps[key].timer then
            uiPressMaps[key].timer:Stop();
        end
    end
end

TouchProxy.__init = __init
TouchProxy.OnTouchDown = OnTouchDown
TouchProxy.OnTouchDown = OnTouchDown
TouchProxy.OnTouchUp = OnTouchUp
TouchProxy.OnTouchDragBegin = OnTouchDragBegin
TouchProxy.OnTouchDrag = OnTouchDrag
TouchProxy.OnTouchDragEnd = OnTouchDragEnd
TouchProxy.OnTouchClick = OnTouchClick
TouchProxy.OnTouchPress = OnTouchPress
TouchProxy.OnTouchPressEnd = OnTouchPressEnd

return TouchProxy