--[[
Author: niyi
Date: 2015-3-10
Info: basic ui control
How to use:
	Ctrl:GetInstance():Show(dialog, data) 
	参数:
	--dialog 必须 说明：对话框表名
	--data 非必须 说明：数据表名
]]

local Singleton = require "Framework.Singleton"
BasicCtrl = Class("BasicCtrl",Singleton)

function BasicCtrl:Ctor(...)
	Singleton.Ctor(self)
	self.m_pSkin = nil
	self.m_pSkinData = nil
	self.bHaveInitDlg = true
end

function BasicCtrl:Destroy()
	local mtable = getmetatable(self)
	if mtable and mtable._instance then
	elseif self._instance then
		mtable = self
	end
	if mtable and mtable._instance then
		if mtable._instance.m_pSkin then
			mtable._instance.m_pSkin:Destroy()
			mtable._instance.m_pSkin = nil
		end
		if mtable._instance.m_pSkinData then
			mtable._instance.m_pSkinData:Destroy()
			mtable._instance.m_pSkinData = nil
		end
		mtable._instance = nil
	end
end

--TODO in children
function BasicCtrl:Show(dialog, data)

	if dialog == nil then
		LogErr("BasicCtrl.show, error!!! no dialog")
		return 
	end
	self.m_pSkinData = data;
	
	if self.m_pSkin == nil then
		self.bHaveInitDlg = false
		self.m_pSkin = dialog:GetInstance()
		self.m_pSkin:SetCtrlClass(self)
	else 
		if self.m_pSkin.m_pdlg then
			self.m_pSkin.m_pdlg.gameObject:SetActive(true);	
			self.m_pSkin.m_bVisible = true;
		end
	end
	
	if self.m_pSkin.loaded then
		self:OnSkinReady()
	end
end

----UI部分加载完成
function BasicCtrl:OnSkinReady()

	if not self.bHaveInitDlg then
		self.bHaveInitDlg = true
		if not self.m_pSkin.m_pdlg then
			self.m_pSkin.m_pdlg = self.m_pSkin.prefab
		end
		self:InitCtrl()
	end

	if self.m_pSkin:IsVisible() == true then
		self:Refresh(self.m_pSkinData)
		return
	end
	self.m_pSkin:Show()
	self.m_pSkin:OnShow()
end

--TODO in children
function BasicCtrl:InitCtrl()
end

--TODO in children
function BasicCtrl:Refresh()

	if self.m_pSkin then
		self.m_pSkin:Refresh()
	end
end

function BasicCtrl:Hide()
	
	if self.m_pSkin then
		self.m_pSkin:Hide()
	end
end

return BasicCtrl
