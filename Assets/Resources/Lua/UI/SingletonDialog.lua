-------单例
require "UI.Dialog"
local SingletonDialog = Class("SingletonDialog", Dialog)
function SingletonDialog:Ctor(...)
    Dialog.Ctor(self)
end

function SingletonDialog:GetInstance()
	return SingletonDialog.GetSingleton(self)	
end 

function SingletonDialog:GetSingleton(parentwindow, nameprefix)
	if self._instance == nil then
		self._instance = self.New()
		self._instance.m_ctrlClass = nil
		self._instance:OnCreate(parentwindow)
	end 
	return self._instance	
end 

function SingletonDialog:GetCtrlClass()
	if self.m_ctrlClass then
		return self.m_ctrlClass
	else
		return nil
	end
end

function SingletonDialog:SetCtrlClass(ctrl)
	self.m_ctrlClass = ctrl
end

function SingletonDialog:GetInstanceNotCreate()
	return self._instance
end

function SingletonDialog:OnUIReady()
	Dialog.OnUIReady(self)
	
end

function SingletonDialog:AfterUIReady()
	
	if self.m_ctrlClass and self.m_ctrlClass.OnSkinReady then
		self.m_ctrlClass:OnSkinReady()
	end
end

--WARN:: TODO special ,
function SingletonDialog:Destroy()
	-- A:GetInstance():Destroy()
	local mtable = getmetatable(self)
	if mtable and mtable._instance then
		if mtable._instance.OnClose == nil then
			LogErr("special need to do Destroy, from SingletonDialog:Destroy()")
			return
		end	
		mtable._instance:OnClose()
		mtable._instance = nil
		return
	end	

	-- A.Destroy()
	if self._instance then
		if self._instance.OnClose == nil then
			LogErr("special need to do Destroy, from SingletonDialog:Destroy()")
			return
		end	
		self._instance:OnClose() 
		self._instance = nil
		return
	end
end	

return SingletonDialog  