local EventDispatcher = require "Framework.Basic.EventDispatcher"
local Singleton = Class("Singleton", EventDispatcher)

function Singleton:Ctor( ... )
	EventDispatcher.Ctor(self, ...)
end

function Singleton:Destroy()
	local mtable = getmetatable(self)
	if mtable and mtable._instance then
	elseif self._instance then
		mtable = self
	end
	if mtable and mtable._instance then
		mtable._instance = nil
	end
end

function Singleton:GetInstance(...)
	return Singleton.GetSingleton(self,...)	
end 

function Singleton:GetSingleton(...)
	if self._instance == nil then
		self._instance = self.New(...)
	end 
	return self._instance	
end 

function Singleton:GetInstanceNotCreate()
	return self._instance
end

return Singleton    	