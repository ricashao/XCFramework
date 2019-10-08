ScrollPaneEvent = {}

local eventmaps = {}

function ScrollPaneEvent.AddListener(target, listener, data)
	if not target then
		error("无法给空对象的" .. name .. "添加ScrollPaneEvent")
		return
	end
	if not listener then
		error("添加监听事件失败")
		return
	end

	local lis = {};
	lis.func = listener;
	lis.gameObject = target;
	if data then
		lis.data = data;
	end

	local cKey = tostring(target)
	local name = target.name;
	if eventmaps[cKey .. name] then
		if info then info("target:" .. target.name .. "compont:".. name .. "的监听事件被覆写") end
	end 

	local com = target.gameObject:GetComponent('ScrollViewEvent')
	if not com  then
		com = target.gameObject:AddComponent(ScrollViewEvent.GetClassType())
		
	end
	com:SetCallBackData(lis);
	target.name = "ScrollPaneEvent";
	eventmaps[cKey .. name] = lis;
    

end

function ScrollPaneEvent.RemoveListener(target, name)
	
	if target and name then
		local cKey = tostring(target)
		eventmaps[cKey .. name] = nil
	end
end


function ScrollPaneEvent.OnValChange(v, k, passdata)

	if not passdata then
		-- if error then error("ScrollPaneComponent OnValChange illegal passdata") end;
		return;
	end
	local listener = passdata.func;
	local data = passdata.data;
	local target = passdata.gameObject;

	if passdata.flag then
		if listener then
			if not data then
				listener();
			else
				listener(data);
			end
		end
		passdata.flag = false;
	end
	

end

function ScrollPaneEvent.OnBeginDrag(eventData, passData)
	if not passData then
		-- if error then error("ScrollPaneComponent OnValChange illegal passdata") end;
		return;
	end
	if passData then
		passData.flag = true;
	end
	
end


function ScrollPaneEvent.OnEndDrag(eventData, passData)
	if not passData then
		-- if error then error("ScrollPaneComponent OnValChange illegal passdata") end;
		return;
	end
	if passData then
		passData.flag = false;
	end

end




