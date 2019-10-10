local AsynPrefabObject = require "UI.AsynPrefabObject"
Dialog = Class("Dialog", AsynPrefabObject)

-- call in new function
function Dialog:Ctor( ... )

	AsynPrefabObject.Ctor(self, ...)
	self.m_bVisible = false
	self.m_pdlg = nil
	self.m_pName = ""
	self.m_pZIndex = nil
end

-- call in onClose function
function Dialog:Destroy()

	AsynPrefabObject.Destroy(self)
	Resources.UnloadUnusedAssets()
end

-- call in GetInstance() function
function Dialog:OnCreate( ... )

end

---///////////////////////// UI 的异步加载部分

----开始异步加载
function Dialog:AsynLoad( pfbname, path, name )
	self.m_pName = name
	self:LoadObject(pfbname, path, self.OnAsynLoaded, false)
end

----异步加载完成
function Dialog:OnAsynLoaded(pfb)
	self.m_pdlg = pfb
	if self.m_pName then
		self.m_pdlg.name = self.m_pName
	end

	pfb.transform:SetParent(GameLayerManager.GetPanelLayerTransform(), false)

	----设置深度
	--self:UpdateZIndex()

	self:OnUIReady()
	self:AfterUIReady()
end

---- UI 已加载完毕
function Dialog:OnUIReady()
	---开始处理UI的逻辑
	---在SingleDialog中覆写了此方法
	
	--CheapUtil.ResManager.RemoveUnUsedAb()

end

-- 设置UI背景矩形对象
function Dialog:SetBackgroundRect(path)
	self.rect = self:GetChildByPathName(path);
end

----//异步加载部分结束

----获取一个prefab上的子控件
function Dialog:GetPrefabChild(pfb, childname)

	local childern = pfb:GetComponentsInChildren(typeof(Transform), true)
	local count = childern.Length - 1;
	for i = 0, count do
		local child = childern[i]
		if child.name == childname then
			return child
		end
	end

	return nil
end

----将Dialog移动到最前面
function Dialog:MoveToTop()
	if self.m_pdlg then
		local count = self.m_pdlg.transform:GetChildCount()
		self.m_pdlg.transform:SetSiblingIndex(count - 1)
	end
end

function Dialog:Show( ... )

	self.m_bVisible = true

	UIManager:GetInstance():AddDialog(self)
end

function Dialog:OnShow()
	
end

function Dialog:UpdateZIndex()
	
	if self.m_pZIndex ~= nil then
		UIManager:GetInstance():RemoveZIndex(self.m_pZIndex)
	end
	self.m_pZIndex, zdelta = UIManager:GetInstance():GetZIndex()

	if self.m_pdlg then
		local pos = self.m_pdlg:GetComponent("RectTransform").localPosition
		self.m_pdlg.transform.localPosition = Vector3.New(pos.x, pos.y, self.m_pZIndex * zdelta)
	end
end

function Dialog:Hide()
	
	self.m_bVisible = false
	if self.m_pZIndex then
		UIManager:GetInstance():RemoveZIndex(self.m_pZIndex)
	end
	self.m_pZIndex = nil
end

function Dialog:OnHide()

end

function Dialog:Refresh()
	self:UpdateZIndex()
end

-- call in Destroy()
function Dialog:OnClose()

	UIManager:GetInstance():RemoveDialog(self)
	
	if self.m_pZIndex then
		UIManager:GetInstance():RemoveZIndex(self.m_pZIndex)
	end
	Dialog.Destroy(self)
end

function Dialog:IsVisible()
	return self.m_bVisible
end

return Dialog