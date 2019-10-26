--[[szc
require "UI.Login.Data.LoginNetProtocols";
]]
require "UI.Login.LoginManager";
require "UI.Login.LoginUICommon";
local BasicCtrl = require "UI.BasicCtrl";
LoginUICtrl = Class("LoginUICtrl", BasicCtrl);

local M = LoginUICtrl;

function M:Ctor()
    BasicCtrl.Ctor(self);
    self.m_serverInfoList = {};
    self.m_loginInfo = nil;
    self.m_chooseAreaId = nil;
    self.m_chooseServerId = nil;
    self.m_chooseServerName = nil;
    self.m_connectIp = nil;
    self.m_connectHost = nil;

    --错误提示
    self.errorCode = -1;
    --szc
    --LocalSaveMgr.InitTimeStamps();

end

-- 销毁
function M:Destroy()
    BasicCtrl.Destroy(self);
    LoginUICtrl._instance = nil;
end

function M:Show()
    local LoginDialog = require "UI.Login.Skin.LoginUIDialog";
    BasicCtrl.Show(self, LoginDialog, nil);
end

function M:InitCtrl()

    self.m_pSkin:SetCtrlClass(LoginUICtrl); --设置控制类
    -- 添加监听事件
    GameUIClickEvent.AddListener(self.m_pSkin.m_pLogin, self.m_pSkin.m_pLogin.name, LoginUICtrl.ConnectServer);
    GameUIClickEvent.AddListener(self.m_pSkin.m_selectServerBtn, self.m_pSkin.m_selectServerBtn.name, LoginUICtrl.GetServerList);

    self:Initialize();

    --在此临时预加载 szc
    --BeanConfigManager:GetInstance():GetTableByName("ares.logic.message.CMessageTip");

end

function M:Initialize()
    --获取服务器列表
    self.m_serverInfoList = LoginManager:GetInstance():GetServerList();
    if not (self.m_serverInfoList) then
        if error then
            error("LoginUICtrl GetSelectedServerInfo Can not load serverInfo file");
        end
        return ;
    end
    --获取本地信息
    self.m_loginInfo = LocalSaveMgr.GetCurrentInfo();

    if (self.m_loginInfo == nil) or (self.m_loginInfo[LocalSaveCommon.IndexEnum.AreaId] == nil) then
        --如果本地没有记录则取默认选区
        self.m_chooseAreaId = LocalSaveCommon.RecommendAreaID;
        self.m_chooseServerId = LocalSaveCommon.RecommendServerID;
    else
        self.m_chooseAreaId = LoginManager:GetInstance():GetAreaIdByServerId(self.m_loginInfo.serverid);
        self.m_chooseServerId = self.m_loginInfo.serverid;
    end

    self:SetCommText(self.m_chooseAreaId, self.m_chooseServerId);

    self:ErrorTips();

end

--设置面板上选择的服务器
function M:SetCommText(areaid, serverid)
    self.m_chooseAreaId = areaid;

    local serverList = self.m_serverInfoList[tostring(self.m_chooseAreaId)];
    if not serverList then
        if error then
            error("LoginUICtrl GetSelectedServerInfo there serverList is nil");
        end
        return ;
    end

    local selectedServerInfo = self:GetServerInfoById(serverList, serverid);
    if not selectedServerInfo then
        if error then
            error("LoginUICtrl GetSelectedServerInfo there is no selectedServerInfo info");
        end
        return ;
    end
    self.m_connectIp = selectedServerInfo.ip;

    math.randomseed(os.time())
    local t_port = math.floor(math.random(0, selectedServerInfo.portcount - 1));
    self.m_connectHost = selectedServerInfo.port + t_port;

    self.m_chooseServerId = selectedServerInfo.serverid;
    self.m_chooseServerName = selectedServerInfo.servername;
    if self.m_loginInfo then
        self.m_pSkin.m_inputUserName.text = self.m_loginInfo.account;
        self.m_pSkin.m_inputPassword.text = self.m_loginInfo.password;
    else
        self.m_pSkin.m_inputUserName.text = "";
        self.m_pSkin.m_inputPassword.text = "";
    end

    local areaName = LoginManager:GetInstance():GetAreaNameByID(self.m_chooseAreaId);
    self.m_pSkin.m_selectServerText.text = areaName .. "    " .. self.m_chooseServerName;

    self:ErrorTips();
end

function M:ErrorTips()
    local instance = LoginManager:GetInstance();
    local str = instance:GetLoginErrorStr();
    local code = instance:GetLoginCode();
    if str then
        if code == 20 and str == LoginErrorStrCommon.ServerError then
            CommMsgMgr:GetInstance():Show(160649);
        elseif code == 1 and str == LoginErrorStrCommon.NetException then
            CommMsgMgr:GetInstance():Show(160650);
        end
    end
end

function M.LoginTest(go)
    GameMain.EnterBattleScene();
end

function M.ConnectServer(go)
    require "UI.CreateRole.SkinCtrl.CreateRoleDialogCtrl";
    CreateRoleDialogCtrl:GetInstance():Show();
    --[[
    local instance = LoginUICtrl:GetInstance();
    local serverId = instance.m_chooseServerId;
    local ip = instance.m_connectIp;
    local port = instance.m_connectHost;
    LoginManager:GetInstance():ConnectServer(serverId, ip, port);
    ]]
end

function M:GetServerInfoById(serverList, serverid)
    for _, value in ipairs(serverList) do
        if value.serverid == serverid then
            return value;
        end
    end
    return nil;
end

function M.GetServerList(go)
    --local ServerListDialogCtrl = require "UI.Login.SkinCtrl.ChooseServerDialogCtrl";
    --ServerListDialogCtrl:GetInstance():Show();
end

function M.OnConnected()

end
--link连接成功
function M.OnAuthOk(userid)
    local p = require "Net.Protocols.protolua.ares.logic.crolelist".Create();
    if p ~= nil then
        LuaProtocolManager:getInstance():send(p);
    end
end

function M.OnAuthError(errorstr, code)

    if error then
        error(errorstr .. code);

        if code == 0 and errorstr == LoginErrorStrCommon.NetException then
            CommMsgMgr:GetInstance():Show(160648);
        else
            local instance = LoginManager:GetInstance();
            instance:SetLoginCode(errorstr, code);
        end

    end
end
--服务器连接成功 排队之后
function M:LoginUIDestory()
    LoadingManager:GetInstance():Show();
    LoginUICtrl:GetInstance():Destroy();
    --关闭排队窗口
    if LoginManager:GetInstance().isShowQueue then
        local commMsg = DoubleTipCtrl:GetInstance();
        commMsg:CloseTip();
        LoginManager:GetInstance().isShowQueue = false;
    end
    -- 启动聊天记录管理
    local account = LoginManager:GetInstance().account;
    LocalSaveChatManager:GetInstance():Login(account);


end

return M;