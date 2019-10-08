--[[
---------------------------------------------------
	注意：icon（图标）的加载不要传入路径
----------------------------------------------------
]]

IconLoadCtrl = {}

-----//////////////////////////////////////从图集中异步加载图片
local targetUIList = {}
local otherImageLoadList = {}
local changeActiveList = {} --存储变更active的Object

---- 异步加载
--[[
	@param ui 需要添加RawImage
	@param abpath 图标的路径
	@param 图片名字
]]

---将此方法声明为私有方法

-- local function GetIconForUI(ui, iconpath, iconid)
-- 	if not ui then return end

-- 	local key = tostring(ui)
-- 	local com = ui.gameObject:GetComponent(UIIconScript.GetClassType())
-- 	if not com  then
-- 		---- 添加此脚本主要是用来监听ui什么时候销毁，ui销毁后清理引用
-- 		com = ui.gameObject:AddComponent(UIIconScript.GetClassType())
-- 		com:SetKey(key)
-- 		changeActiveList[key] = 1
-- 		ui.gameObject:SetActive(false)
-- 	end
	
-- 	targetUIList[key] = ui
-- 	AsynPrefabLoader.LoadIcon(iconpath, tostring(iconid), key, true)
	
-- end

---- 加载道具图标
function IconLoadCtrl.GetItemIconForUI(ui, iconid)
	
	-- local iconpath = "UI/Icon/ItemIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	UIManager.SetUIImage(iconid ..".png", ui)
end

-- 加载主界面 场景图片
function IconLoadCtrl.GetSceneIconForUI(ui, iconid)

	-- local iconpath = "UI/Icon/OtherIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	UIManager.SetUIImage(iconid ..".png", ui)

end

---- 加载 主界面右上角 主角头像
function IconLoadCtrl.GetRoleIconForUI(ui, iconid)

	-- local iconpath = "UI/Icon/RoleIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	UIManager.SetUIImage(iconid ..".png", ui)

end

---- 加载宠物图标
function IconLoadCtrl.GetPetIconForUI(ui, iconid)

	-- local iconpath = "UI/Icon/PetIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	UIManager.SetUIImage(iconid ..".png", ui)

end

-- 加载buff图标
function IconLoadCtrl.GetBuffIconForUI(ui, iconid)
	-- local iconpath = "UI/Icon/BuffIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)

	UIManager.SetUIImage(iconid ..".png", ui)
end

---- npc icon
function IconLoadCtrl.GetNpcIconForUI(ui, iconid)
	
	-- local iconpath = "UI/Icon/BustIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	UIManager.SetUIImage(iconid ..".png", ui)
end

---- skill icon
function IconLoadCtrl.GetSkillIconForUI(ui, iconid)

	-- local iconpath = "UI/Icon/SkillIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)

	UIManager.SetUIImage(iconid ..".png", ui)
end

-- wxb 图片格式 可能存在隐患
function IconLoadCtrl.GetNpcHeadIcon(ui, iconid)
	
	-- local iconpath = "UI/Icon/RoleIcon/" .. iconid ..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	UIManager.SetUIImage(iconid ..".png", ui)
end

--player school
function IconLoadCtrl.GetSchoolIconForUI(ui, iconid)
	-- local iconpath = "UI/Icon/OtherIcon/"..iconid..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	
	UIManager.SetUIImage(iconid ..".png", ui)
end

-- wc 阵营图片
function IconLoadCtrl.GetCampIconForUI(ui, iconid)
	-- local iconpath = "UI/Icon/OtherIcon/"..iconid..".png"
	-- GetIconForUI(ui, iconpath, iconid)
	
	UIManager.SetUIImage(iconid ..".png", ui)
end

-- hs 角色称谓
--[[
	ui     图片所在的transfrom
	iconid 图片资源标识(通常会是图片名称)
]]
function IconLoadCtrl.GetTitleIcon(ui, iconid)
	-- local iconpath = "UI/Icon/ModTitle/" .. iconid .. ".png";
	-- GetIconForUI(ui, iconpath, iconid);
	UIManager.SetUIImage(iconid ..".png", ui)
end


---- 加载完成的回调
function IconLoadCtrl.OnLoadedIcon(key, obj, isSprite)

	if targetUIList[key] then  ----直接设置到UI上
		
		if changeActiveList[key] then
			targetUIList[key].gameObject:SetActive(true)
			changeActiveList[key] = nil
		end

		targetUIList[key]:GetComponent("RawImage").texture = obj
	elseif otherImageLoadList[key] then  

		local t = otherImageLoadList[key]
		t.fun(t.target, obj, t.path)
		otherImageLoadList[key] = nil
	else
		if error then error("加载的图片资源没有被使用-- Recycle") end
		PoolManager.Recycle(obj);
	end
end


----其他图片的加载方法（本不应该放在这）
--[[
	@param path 资源的全路径（如果在ab中则是ab的完整路径）
	@param name 资源的名字 (如果在ab中，则是在ab中的完整路径)
	@param callback  回调函数 callback(passdata, obj, name)

	注意：UsePool 此处暂时定义为资源缓存一段时间(3m)， 谨慎使用

	注意：加载后返回的资源是一个Texture2D
]]
function IconLoadCtrl.GetImageTexture(respath, name, callback, passdata)
	
	local t = {}
	t.fun = callback
	t.target = passdata
	t.path = name
	local key = tostring(t)
	otherImageLoadList[key] = t

	AsynPrefabLoader.LoadIcon(respath, name, key, false)
end

---- 控件销毁时，移除掉监听
function IconLoadCtrl.OnDestroySprite(key)

	targetUIList[key] = nil
	changeActiveList[key] = nil
end