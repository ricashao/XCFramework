--[[
-- added by wsh @ 2018-01-08
-- 图集配置
--]]

local AtlasConfig = {
	Comm = {
		Name = "Comm",
		AtlasPath = "UI/Atlas/Atlas_Comm",
	},
	Group = {
		Name = "Group",
		PackagePath = "UI/Atlas/Atlas_Comm",
	},
	Hyper = {
		Name = "Hyper",
		AtlasPath = "UI/Atlas/Atlas_Hyper",
	},
	Login = {
		Name = "Login",
		AtlasPath = "UI/Atlas/Atlas_Login",
	},
	Role = {
		Name = "Role",
		AtlasPath = "UI/Atlas/Atlas_Role",
	},
}

return ConstClass("AtlasConfig", AtlasConfig)