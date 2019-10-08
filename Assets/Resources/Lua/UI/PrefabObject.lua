local Object = require "Framework.Object"
local PrefabObject = Class("PrefabObject", Object)

function PrefabObject:Ctor( ... )
	self.m_pNameMap = {}
	self.m_pNamePath = nil
end

function PrefabObject:Destroy()
	self.m_pNameMap = nil
end

function PrefabObject:AddAllGroupPrefabs(pfb)
	AssetManager.MountResource(pfb)
end

---同步加载(暂时移除掉)
-- function PrefabObject.SynLoadPrefab( path )
-- 	return LoadUtils.SynLoadPrefab(path);
-- end

---------------------------------------////////////////////////////
---- 用例： local btn = self:GetChildByPathName("Panel.et_Button")
---- 通过名字路径来获取控件
function PrefabObject:GetChildByPathName( name )
	if self.m_pNamePath == "" then
		return self.m_pNameMap[name]
	else
		return self.m_pNameMap[self.m_pNamePath ..".".. name]
	end
end

function PrefabObject:GenAllNameMap( pfb, namepath )

	self.m_pNamePath = "Root.panellayer"
	if namepath ~= nil then
		self.m_pNamePath = namepath
	end

	local childern = pfb:GetComponentsInChildren(Transform.GetClassType(), true)
	local count = childern.Length - 1
	for i = 0, count do
		local temp = {}
		PrefabObject.FindNamePath(childern[i], temp)
		local name = table.concat(temp, ".")
		self.m_pNameMap[name] = childern[i]
	end
end

function PrefabObject.FindNamePath( gb, t )
	if gb and gb.transform  then
		if gb.transform.parent then
			PrefabObject.FindNamePath(gb.transform.parent, t)
			table.insert(t, gb.name)
		else
			table.insert(t, gb.name)
		end
	end
end

---- 标记prefab，截止到prefab的名字
function PrefabObject:GenPrefabNameMap(pfb, namepath)

	self.m_pNamePath = ""

	self.rootPfb = pfb
	local childern = pfb:GetComponentsInChildren(Transform.GetClassType(), true)
	local count = childern.Length - 1
	for i = 0, count do
		local temp = {}
		PrefabObject.FindNamePathStopBySelfName(childern[i], pfb, temp)
		local name = table.concat( temp, ".")
		self.m_pNameMap[name] = childern[i]
	end
end

function PrefabObject.FindNamePathStopBySelfName(gb, rootPfb, t )
	if gb and gb.transform  then
		if gb.transform.parent and gb.name ~= rootPfb.name then
			PrefabObject.FindNamePathStopBySelfName(gb.transform.parent, rootPfb, t)
			table.insert(t, gb.name)
		else
			table.insert(t, gb.name)
		end
	end
end

-----------------------------------------------------------------
---  生成子控件的路径并包装成
-----------------------------------------------------------------
function PrefabObject:GenNameMapAndWrapVirtualObj(pfb)
	
end

function PrefabObject:GetChildPlaceHodler(name)
	
end

return PrefabObject