-- 登录模块， 包括登录界面，选择服务器界面

LoginUIComponentName = 
{
	LoginDialogRes = "Win_Login";
	LoginDialogResPath = "UI/Prefabs/Win";
	LoginDialogTitle = "LoginUIDialog";

	LoginBtn = "LoginUIDialog.g_var.btn_Login";
	SelectServerBtn = "LoginUIDialog.g_var.g_group3.btn_empty";
	SelectServerText = "LoginUIDialog.g_var.g_group3.btn_empty.et_text_03";
	UserNameInputField = "LoginUIDialog.g_var.g_group1.et_InputField_01";
	PassWordInputField = "LoginUIDialog.g_var.g_group2.et_InputField_02";
}

ChooseServerComponentName = 
{
	ChooseServerDialogRes = "win_login_servernew";
	ChooseServerDialogResPath = "ui/prefabs/win";
	ChooseServerDialogTitle = "ChooseServerDialog";

	BackBtn       = "ChooseServerDialog.g_var.ept_Group_Btn_M_a-01.btn01.ebtn";
	OKBtn         = "ChooseServerDialog.g_var.ept_Group_Btn_M_a-02.btn02.ebtn";

	BackBtnText   = "ChooseServerDialog.g_var.ept_Group_Btn_M_a-01.btn01.ebtn.et_text";
	OKBtnText     = "ChooseServerDialog.g_var.ept_Group_Btn_M_a-02.btn02.ebtn.et_text";

	RecommendBtn = "ChooseServerDialog.g_var.ebtn_recommend";
	ServerScrollRect = "ChooseServerDialog.g_var.ScrollView_list.ScrollRect";
	ServerListItem = "ChooseServerDialog.g_var.ScrollView_list.ScrollRect.esl_Module_Server";

	AreaScrollRect = "ChooseServerDialog.g_var.ScrollView_area.ScrollRect";
	AreaListItem = "ChooseServerDialog.g_var.ScrollView_area.ScrollRect.esl_Module_Server_Area";

}

ServerAreaItemComponentName = 
{
	ServerAreaItemRes     = "module_server_area";
	ServerAreaItemResPath = "ui/prefabs/module";
	ServerAreaItemName    = "server_item_btn";
}

ServerItemComponentName = 
{
	ServerItemRes     = "module_server";
	ServerItemResPath = "ui/prefabs/module";

	ServerItemName    = "Module_Server.et_name";
	ServerItemState   = "Module_Server.ep_state";
	ServerOpenTime    = "Module_Server.et_open";
	ServerPlayer  = "Module_Server.g_player";
	ServerPlayerName  = "Module_Server.g_player.et_player";
	ServerPlayerIcon  = "Module_Server.g_player.p_mask.ep_icon";
	ServerPlayerLevel = "Module_Server.g_player.et_level";
	ServerItemChoose  = "Module_Server.ep_choose";
	ServerItemBtn     = "Module_Server.ebtn_empty";
}

LoginModuleCommon = 
{
	RecommendBtnName = "推荐";
	BackBtnTextName  = "返回";
	OKBtnTextName    = "确定";
}

ServerItemStateIcon =
{
	StateItemHuoBao = 0;
	StateItemXinFu = 1;
}

LoginErrorStrCommon = 
{
	ServerError = "Server";
	NetException = "NetException";

}