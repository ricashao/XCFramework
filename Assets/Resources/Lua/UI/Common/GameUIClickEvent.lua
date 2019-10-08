GameUIClickEvent = {}

local eventmaps = {}
local parentmaps = {}
local longeventmaps = {}


--[[ 添加点击的监听事件
 	@param target  		点击对象的父容器
 	@param name    		点击对象的名字
 	@param listener     回调函数
 	@param data         附加参数
 	@param index         附加参数 index
--]]
function GameUIClickEvent.AddListener(target, name, listener, data, index)
	if not target then
		error("无法给空对象的" .. name .. "添加事件")
		return
	end
	local lis = listener
	if not listener then
		error("添加监听事件失败")
		return
	end

	if data then
		lis = {}
		lis.func = listener
		lis.data = data
		lis.index = index;
	end

	local cKey = tostring(target)
	if eventmaps[cKey .. name] then
		if info then info("target:" .. target.name .. "compont:".. name .. "的监听事件被覆写") end
	end 

	local com = target.gameObject:GetComponent('GameComponentClick')
	if not com  then
		com = target.gameObject:AddComponent(GameComponentClick.GetClassType())
		com.cKey = cKey
	end
	if not parentmaps[cKey] then
		parentmaps[cKey] = {}
	end
	parentmaps[cKey][name] = lis
	eventmaps[cKey .. name] = lis
end

-- 移除点击监听
function GameUIClickEvent.RemoveListener(target, name)
	
	if target and name then
		local cKey = tostring(target)
		eventmaps[cKey .. name] = nil
	end
end

function GameUIClickEvent.OnClickCallFromCS(name, ckey, go )
	if info then info("click target: " .. name .. ", child:" .. go.name) end
	if go and eventmaps[ckey .. go.name] then
		local callBack = eventmaps[ckey .. go.name]
		if type(callBack) == "table" then
			callBack.func(go, callBack.data, callBack.index)
		else
			callBack(go)
		end
	end
end

function GameUIClickEvent.OnDestroyComponent( ckey )

	local t = parentmaps[ckey]
	for k, _ in pairs(t) do
		eventmaps[ckey .. k] = nil
	end
	parentmaps[ckey] = nil
end

----------------------------------------------------------------------
-----------------------------长按按钮---------------------------------
----------------------------------------------------------------------
--[[ 添加长按的监听事件
 	@param target  		长按对象
 	@param name    		长按对象的名字
 	@param listener     回调函数
 	@param data         附加参数
--]]
function GameUIClickEvent.AddLongPressListener(target, name, listener, data)
	if not target then
		error("无法给空对象添加事件")
	end
	local lis = listener
	if not listener then
		error("添加监听事件失败")
	end

	if data then
		lis = {}
		lis.func = listener
		lis.data = data
	end

	local cKey = tostring(target)
	if longeventmaps[cKey .. name] then
		error("target:" .. target.name .. "compont:".. name .. "的监听事件被覆写")
	end 

	local com = target.gameObject:GetComponent('LongPressItemScript')
	if not com  then
		com = target.gameObject:AddComponent(LongPressItemScript.GetClassType())
		com.cKey = cKey
	end
	longeventmaps[cKey .. name] = lis
end

-- 移除长按点击监听
function GameUIClickEvent.RemoveLongPressListener(target, name)
	if target and name then
		local cKey = tostring(target)
		longeventmaps[cKey .. name] = nil
	end
end

function GameUIClickEvent.LongPressCallFromCS(ckey, go, isLong)
	-- error("click target: " ..  go.name)
	if go and longeventmaps[ckey .. go.name] then
		local callBack = longeventmaps[ckey .. go.name]
		if type(callBack) == "table" then
			callBack.func(go, callBack.data, isLong)
		else
			callBack(go)
		end
	end
end

function GameUIClickEvent.OnDestroyLongPressComponent(ckey, name)
	if longeventmaps[ckey .. name] then
		longeventmaps[ckey .. name] = nil
	end
end

return GameUIClickEvent