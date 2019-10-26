-- 创建角色模块
CreateRoleComponentName =
{
	Win_CreateRoleDialog = "Win_Create";
	CreateRoleDialogName = "CreateRoleDialog";
	CreateRoleDialogPath = "UI/Prefabs/Win";
	BackBtn              = "CreateRoleDialog.g_var.ebtn_back";
	EptBackGround        = "CreateRoleDialog.g_comm.ept_Module_Create_Bg";

	EbtnRole_1 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_01";
	EbtnRole_2 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_02";
	EbtnRole_3 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_03";
	EbtnRole_4 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_04";
	EbtnRole_5 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_05";
	EbtnRole_6 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_06";

	Btn_p_role_1 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_01.p_mask.p_role";
	Btn_p_role_2 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_02.p_mask.p_role";
	Btn_p_role_3 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_03.p_mask.p_role";
	Btn_p_role_4 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_04.p_mask.p_role";
	Btn_p_role_5 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_05.p_mask.p_role";
	Btn_p_role_6 = "CreateRoleDialog.g_var.g_left.g_role.ebtn_role_06.p_mask.p_role";

	RoleModel     = "CreateRoleDialog.g_var.g_center.RoleModel";
	RoleModelBtn  = "CreateRoleDialog.g_var.g_center.RoleModel.ebtn_empty";
	RoleInfoName  = "CreateRoleDialog.g_var.g_center.g_info.ep_name";
	RoleInfoWordA = "CreateRoleDialog.g_var.g_center.g_info.ep_word_a";
	RoleInfoWordB = "CreateRoleDialog.g_var.g_center.g_info.ep_word_b";

	CreateRoleBtn       = "CreateRoleDialog.g_var.g_right.ebtn_enter";
	RandomBtn           = "CreateRoleDialog.g_var.g_right.ebtn_random";
	InputFieldComponent = "CreateRoleDialog.g_var.g_right.InputField";

	GuildImgList_1 = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_01.ep_guild";
	GuildName_1    = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_01.et_name";
	GuildInfo_1    = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_01.et_info";
	GuildChoose_1  = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_01.ep_choose_active";
	GuildBtn_1     = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_01.ebtn_empty";

	GuildImgList_2  = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_02.ep_guild";
	GuildName_2     = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_02.et_name";
	GuildInfo_2     = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_02.et_info";
	GuildChoose_2   = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_02.ep_choose_active";
	GuildBtn_2      = "CreateRoleDialog.g_var.g_right.g_guild.g_guild_02.ebtn_empty";

	ButtonClickFlag = "ebtn";

	RawImage    = "RawImage";
	Image       = "Image";
	InputField  = "InputField";
	Button      = "Button";
	Text        = "Text";

	Empty_Btn_1 = "ebtn_empty_1";
	Empty_Btn_2 = "ebtn_empty_2";
	ModelBtn    = "RoleModelBtnEmpty";

	RoleBtnPrefix      = "ebtn_role";
	CreateRoleBgPrefix = "Module_Create_Bg_0";

	ModelEffectPath_1  = "effect/prefab/role/player";
	ModelEffectName_1  = "jiyuedan_pose01";
}

CREATE_STATE = 
{
	CREATE_ERROR = 2;
	CREATE_INVALID = 3;
	CREATE_DUPLICATED = 4;
	CREATE_OVERCOUNT = 5;
	CREATE_OVERLEN = 6;
	CREATE_SHORTLEN = 7;
	CREATE_ROLE_NAME_PURE_NUMBER = 8;
}

CREATEROLE_TIP_ID = 
{
	CREATE_ERROR =160524;
	CREATE_INVALID = 160525;
	CREATE_DUPLICATED = 160527;
	CREATE_OVERCOUNT = 160531;
	CREATE_OVERLEN = 160529;
	CREATE_SHORTLEN = 160528;
	CREATE_ROLE_NAME_PURE_NUMBER = 160545;
}