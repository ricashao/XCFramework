--[[
	所有UILayer层级的父UIComponent
]]
UIComponentContainer = Class("UIComponentContainer", Object)

local M = UIComponentContainer

function M:Ctor(type)

	self.list = {}
end

function M:_AddUIComponent(component)
	
	self.list[tostring(component)] = component;
end

function M:_RemoveUIComponent(component)
	
	self.list[tostring(component)] = nil;

end

function M:GetTransform()
	
	return GameLayerManager.GetPanelLayerTransform();
end

return M