-----------------------------
-- 用法：
--	local btn = GButton.New(self.m_pSkin.m_baGarrangeBut)
--  btn:SetEnabled(false)
--
------------------------------

GButton = Class("GButton", Object)
local M = GButton

require "UI.Common.Mat.MatLoadCtrl"

function M:Ctor(btnObj)
	self.btn = btnObj
	self.enable = true

	self.imagesCmp = nil
	self.textsCmp = nil
end

function M:SetEnabled(enable)
	
	if self.btn then
		
		if self.enable ~= enable then
			self.btn:GetComponent("Button").interactable = enable
			self.enable = enable

			if enable then
				self:SetBtnImageMat(nil)
			else
				self:SetBtnImageMat(MatLoadCtrl.GetMat("ui_gray", "UI/Materials"))
			end
			self:SetTextCmpEnabled(enable)
		end
	end
end

function M:SetBtnImageMat(mat)
	if self.btn then
		local images = self:GetImagesCmp()
		for k, v in pairs(images) do
			v.material = mat
		end
		-- self.btn:GetComponent("Image").material = mat
	end
end

function M:SetButtonTextColor(color)
	
end

function M:GetEnabled()
	
	return self.enable
end

function M:SetText(text)
	-- todo
end

----设置按钮上文字的置灰状态
function M:SetTextCmpEnabled(enable)
	
	local texts = self:GetTextsCmp()
	for k, v in pairs(texts) do
		if enable then
			v:Degray()
		else
			v:Gray()
		end
	end
end

function M:GetTextsCmp()
	
	if self.textsCmp == nil then
		self.textsCmp = {}
		local childern = self.btn:GetComponentsInChildren(UIText.GetClassType())
		local count = childern.Length - 1
		for i = 0, count do
			table.insert(self.textsCmp, GText.New(childern[i].gameObject))
		end
	end

	return self.textsCmp
end

function M:GetImagesCmp()

	if self.imagesCmp == nil then
		self.imagesCmp = {}
		local childern = self.btn:GetComponentsInChildren(UnityEngine.UI.Image.GetClassType())
		local count = childern.Length - 1
		for i = 0, count do
			table.insert(self.imagesCmp, childern[i])
		end
	end

	return self.imagesCmp
end

return M