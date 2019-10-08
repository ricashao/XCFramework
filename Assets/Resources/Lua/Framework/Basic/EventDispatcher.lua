local Object = require "Framework.Object";
EventDispatcher = Class("EventDispatcher", Object);
local handle = 0;
local deleteList = {};
function EventDispatcher:Ctor()
	Object.Ctor(self);
	self.events = {};
end

function EventDispatcher:AddEventListener(eType, eListener, passdata)
	local event = {};
	handle = handle + 1
	event.ehandle = handle;
	event.etype = eType;
	event.eListener = eListener;
	event.passdata = passdata
	self.events[event.ehandle] = event;
	return handle;
end

function EventDispatcher:DispatchEvent(eType, edata)
	local protect = 0
	for _, v in pairs(self.events) do
		if v.etype == eType then
			protect = protect + 1
			if protect > 10 then
				error("there may be something wrong in run event:" .. eType)
				if protect > 15 then
					assert(false)
				end
			end
			v.eListener(self, edata, v.passdata);
		end
	end
	return true;
end

function EventDispatcher:HasEventListener(eType)
	for _, v in pairs(self.events) do
		if v.etype == eType then
			return true;
		end
	end
	return false;
end

function EventDispatcher:RemoveEventListenerByID(handle)
	if self.events[handle] == nil then
		return false
	end
	self.events[handle] = nil;
end

function EventDispatcher:RemoveEventListener(eType, eListener)
	for _, v in pairs(self.events) do
		if v.etype == eType and v.eListener == eListener then
			table.insert(deleteList, v);
		end
	end

	for _, v in pairs(deleteList) do
		self:RemoveEventListenerByID(v.ehandle)
	end
end

function EventDispatcher:RemoveEventListenerByType(eType)

	for _, v in pairs(self.events) do
		if v.etype == eType then
			table.insert(deleteList, v);
		end
	end

	for _, v in pairs(deleteList) do
		self:RemoveEventListenerByID(v.ehandle)
	end
end

function EventDispatcher:RemoveAllEventListener()
	for _, v in pairs(self.events) do
		v = nil
	end
	self.events = nil;
	self.events = {};
end

return EventDispatcher;