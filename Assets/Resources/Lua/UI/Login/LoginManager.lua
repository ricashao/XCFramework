local Singleton = require "Framework.Singleton";
LoginManager = Class("LoginManager", Singleton);

local M = LoginManager;

function M:Ctor()
   self.m_serverList = {};
   self.m_orderAreaList = {};
   self.m_areaList = {};
   self:LoadConfigFile();
   self.areaId = nil;
   self.serverId = -1;
   self.account = nil;
   self.isShowQueue = false;
   self.loginErrorStr = nil;
   self.loginErrorCode = -1;
end

function M:GetServerList()
	return self.m_serverList;
end

function M:GetOrderAreaList()
	return self.m_orderAreaList;
end

function M:GetAreaList()
	return self.m_areaList;
end

function M:GetAreaNameByID(id)
	local areaID = tonumber(id);
	if not areaID then
		return "";
	end

	for _, value in pairs(self.m_areaList) do
		if tonumber(value.areaid) == areaID then
			return value.areaname;
		end
	end

end

function M:GetAreaIdByServerId(id)
	local serverId = id;
	if not serverId then
		if error then error("LoginManager GetAreaIdByServerId  serverId is error"); end
		return "";
	end
	for key, value in pairs(self.m_serverList) do
		if key ~= "1" then
			for _, _data in ipairs(value) do
				if _data.serverid == serverId then
					return key;
				end
			end
		end
	end
end

function M:LoadConfigFile()
	local json = require "rapidjson";
  	self.m_serverList = json.decode(Resources.Load("Config/ServerInfo"):ToString());
  	assert(TableUtil.TableLength(self.m_serverList) > 0);

  	self.m_areaList = json.decode(Resources.Load("Config/AreaInfo"):ToString());
	assert(TableUtil.TableLength(self.m_areaList) > 0);

	for areaID, _ in pairs(self.m_serverList) do
		table.insert(self.m_orderAreaList, areaID);		
	end
	table.sort(self.m_orderAreaList);
end


function M:ConnectServer(serverId,ip,port)

	local instance = LoginUICtrl:GetInstance();
	local account = instance.m_pSkin.m_inputUserName.text;
	local password = instance.m_pSkin.m_inputPassword.text;

	-- 检测是否有汉字
	for i=1, string.len(account) do
		local curByte = string.byte(account, i)
	    if curByte > 127 then
	    		CommMsgMgr:GetInstance():Show(160668);
	        return;
	    end;
	end
	self.serverId = serverId;
	self.account = account;
	self.areaId = self:GetAreaIdByServerId(serverId);
	
	-- 检测账号格式
	if string.len(account) > 20 or string.len(account) < 1 then
		CommMsgMgr:GetInstance():Show(160668);
		return;
	end
	CheapUtil.NetManager.GetInstance():SetParam(ip, port, account, password);
	LuaProtocolManager:getInstance():connect();

 
    local index = LocalSaveMgr.GetIndexByAccount(account);
    LocalSaveMgr.UpdateInLogin(index, account, password, serverId, self.areaId);
    -- 服务器登录记录
	LoginManager:GetInstance():LoginServerRecord();
    -- 启动聊天记录管理
    LocalSaveChatManager:GetInstance():Login(account);
    -- 读取登录账号的本地战斗操作的存储
    BattleOperateMgr:GetInstance():LogIn();
end

--记录每次登陆的服务器  新登陆的放在最后
function M:LoginServerRecord()
	local json = require "rapidjson";
	local _table = json.decode(LocalStorage.Get(LocalSaveCommon.LoginServerRecord.."|"..self.account));
	if not _table then
		_table = {};
		table.insert(_table,self.serverId);
		LocalStorage.Put(LocalSaveCommon.LoginServerRecord.."|"..self.account,json.encode(_table));
		return; 
	end;
	
	local len = TableUtil.TableLength (_table);
	local has = false;
	for i = 1,len do
		if has == false then
			if _table[i] == self.serverId then
				_table[i] = _table[i+1];
				has = true;
			end
			if i == len then
				table.insert(_table,self.serverId);
			end
		else
			if i == len  then
				_table[i] = tonumber(self.serverId);
			else
				_table[i] = _table[i+1];
			end
		end
	end
	LocalStorage.Put(LocalSaveCommon.LoginServerRecord.."|"..self.account,json.encode(_table));
end


function M:LocalLoadPlayerInServer(serverId)
	if serverId < 0 then
		if error then error("LoginManager LocalLoadPlayerInServer  serverId is error"); end
		return;
	end
	local account =  LoginUICtrl:GetInstance().m_pSkin.m_inputUserName.text;
	local _data = LocalStorage.Get(LocalSaveCommon.LoginPlayerInServerInfo.."|"..account.."|"..serverId);
	if not _data then return nil end;
	local json = require "cjson";
	data = json.decode(_data);
	if data then
		return data;
	end
	return nil;
end

function M:LocalSavePlayerInServer()
	if self.serverId < 0 then
		if error then error("LoginManager LocalSavePlayerInServer  serverId is -1"); end
		return;
	end

	local userManager = UserManager:GetInstance();
	local data = {};
	data.name = userManager:GetRoleName();
	--创建角色后 name还未赋值
	if not data.name then
		return;
	end
	data.shape = userManager:GetRoleShape();
	data.level = userManager:GetLevel();
	
	local json = require "cjson";
	LocalStorage.Put(LocalSaveCommon.LoginPlayerInServerInfo.."|"..self.account.."|"..self.serverId, json.encode(data));
end

function M:SetLoginCode(errorstr,code)
	if not errorstr then
		if error then error("LoginManager SetLoginCode errorstr is nil"); end
		return;
	end
	if not code then
		if error then error("LoginManager SetLoginCode code is nil"); end
		return;
	end
	self.loginErrorCode = code;
	self.loginErrorStr = errorstr;
end

function M:GetLoginCode()
	if self.loginErrorCode >= 0 then
		local code = self.loginErrorCode;
		self.loginErrorCode = -1;
		return code;
	end	
	return -1;
end

function M:GetLoginErrorStr()
	if self.loginErrorStr ~= nil then
		local str = self.loginErrorStr;
		self.loginErrorStr = nil;
		return str;
	end	
	return nil;
end


function M:ShowQueueInfo(order,queuelength)
	if self.isShowQueue then
		local instance = DoubleTipCtrl:GetInstance();
		if instance then
			instance:RefreshContent({order, queuelength});
		end
	else
		CommMsgMgr:GetInstance():Show(160653, {content = {order, queuelength} }, nil, LoginManager.QueueInfoClose , LoginManager.QueueInfoClose);
		self.isShowQueue = true;
	end

end

function M.QueueInfoClose()
	LoginManager:GetInstance().isShowQueue = false;
end

--服务器开启时间与当前时间比较
function M:IsSeverOpen(time)
	if not time then
		if error then error("LoginManager IsServerOpen time is nil"); end
		return;
	end
	local y2 = tostring(System.DateTime.Now.Year);
	local mo2 = tostring(System.DateTime.Now.Month);
	local d2 = tostring(System.DateTime.Now.Day);
	local h2 = tostring(System.DateTime.Now.Hour);
	local m2 = tostring(System.DateTime.Now.Minute);
	local y1,mo1,d1,h1,m1 = string.match(time,"(%d+)-(%d+)-(%d+) (%d+):(%d+)")
	local t1 = y1 * 12 * 30 * 24 * 60 + mo1 * 30 * 24 * 60 + d1 * 24 * 60 + h1 * 60 + m1 ;
	local t2 = y2 * 12 * 30 * 24 * 60 + mo2 * 30 * 24 * 60 + d2 * 24 * 60 + h2 * 60 + m2 ;
	return t1 <= t2;
end

return M;