-- 客户端保存在本地的信息操作类
require "LocalSave.LocalSaveCommon";

LocalSaveMgr = {};

local M = LocalSaveMgr;

local basicInfo = {};
basicInfo[LocalSaveCommon.IndexEnum.Account] 		= "";
basicInfo[LocalSaveCommon.IndexEnum.Password] 		= "";
basicInfo[LocalSaveCommon.IndexEnum.AreaId]       = LocalSaveCommon.RecommendAreaID;
basicInfo[LocalSaveCommon.IndexEnum.ServerId] 		= 0;
basicInfo[LocalSaveCommon.IndexEnum.ServerIp] 		= "";
basicInfo[LocalSaveCommon.IndexEnum.ServerPort] 	= 0;
basicInfo[LocalSaveCommon.IndexEnum.Music] 			= 0;
basicInfo[LocalSaveCommon.IndexEnum.AutoCharOpera] 	= {operaType = 0, operaId = 0};
basicInfo[LocalSaveCommon.IndexEnum.AutoPetOpera] 	= {operaType = 0, operaId = 0};
basicInfo[LocalSaveCommon.IndexEnum.LastCharOpera] 	= {operaType = 0, operaId = 0};
basicInfo[LocalSaveCommon.IndexEnum.LastPetOpera] 	= {operaType = 0, operaId = 0};
basicInfo[LocalSaveCommon.IndexEnum.isAutoFight] 	= 0;

local json = require "rapidjson";

M.timeStamps = {};
-- time_stamps[1] = 01231313;
-- time_stamps[2] = 01231314;
-- time_stamps[3] = 01231315;

-- 从本地文件中读取的信息表，简称读取表（做读取，改变，写入操作）
M.readSavedInfo = {};
-- M.readSavedInfo[1] = basicInfo;
-- 将读取表扩展成完整数据结构的信息表，简称扩展表（仅做外部获取时用，依赖读取表）
M.extendSavedInfo = {};
-- M.extendSavedInfo[1] = basicInfo;

local deleteTimeStamp = 0;		-- 存储需要删除账号的时间戳
local addTimeStamp = 0;			-- 存储新建账号的时间戳

M.accountNum = 0;				-- 本地存储了几个账号信息

function M.LogOut()
	M.timeStamps = {};
	M.readSavedInfo = {};
	M.extendSavedInfo = {};
	deleteTimeStamp = 0;
	addTimeStamp = 0;
	M.accountNum = 0;
end

-- 进游戏的时候初始化时间戳信息
function M.InitTimeStamps()
	-- local indexs = UnityEngine.PlayerPrefs.GetString(LocalSaveCommon.TimeStampIndex);
	local indexs = LocalStorage.Get(LocalSaveCommon.TimeStampIndex);
	if indexs then
		local tem = json.decode(indexs);
		if tem then
			M.timeStamps = tem;
		end
	end
	M.SortTimeStamps();
	M.InitReadInfo();
end
-- 给时间戳排序
function M.SortTimeStamps()
	if TableUtil.TableLength(M.timeStamps) < 2 then
		return;
	end
	table.sort(M.timeStamps, function(a, b)
		return a > b;
	end)
end
-- 进游戏时初始化读取表和扩展表
function M.InitReadInfo()
	if TableUtil.TableLength(M.timeStamps) < 1 then
		return;
	end
	M.readSavedInfo = {};
	M.extendSavedInfo = {};
	for _, timeStamp in pairs(M.timeStamps) do
		-- local info = UnityEngine.PlayerPrefs.GetString(tostring(timeStamp));
		local info = LocalStorage.Get(tostring(timeStamp));
		if info then
			M.readSavedInfo[timeStamp] = {};
			M.extendSavedInfo[timeStamp] = {};
			local tem = json.decode(info);
			for key, value in pairs(tem) do
				M.readSavedInfo[timeStamp][key] = value;
			end
			for key, value in pairs(basicInfo) do
				if M.readSavedInfo[timeStamp][key] == nil then
					M.extendSavedInfo[timeStamp][key] = value;
				else
					M.extendSavedInfo[timeStamp][key] = M.readSavedInfo[timeStamp][key];
				end
			end
			M.accountNum = M.accountNum + 1;
		else
			if error then error("no info, the info's timestamp is " .. timeStamp) end
		end
	end
end

function M.UpdateReadInfo(data)
	local time = M.timeStamps[LocalSaveCommon.CurrentIndex];
	for key, value in pairs(data) do
		if M.isSavedInfo(key) then
			if M.readSavedInfo[time] == nil then
				M.readSavedInfo[time] = {};
			end
			M.readSavedInfo[time][key] = value;
		end
	end
	M.extendSavedInfo[time] = {};
	for key, value in pairs(basicInfo) do
		if M.readSavedInfo[time][key] == nil then
			M.extendSavedInfo[time][key] = value;
		else
			M.extendSavedInfo[time][key] = M.readSavedInfo[time][key];
		end
	end
end

-- @param
-- index 指下拉框中的顺序，1,2,3。若为新创建账号，为0。
-- account 账号，新账号时才传递
-- password 密码，新账号时才传递
-- serverId 服务器的id
function M.UpdateInLogin(index, account, password, serverId, areaId)
	if index == nil then
		if error then error("the index is nil in LocalSaveMgr.UpdateInLogin") end
		return;
	end
	if M.isNewAccount(account) then
		M.AddTimeStamps();
		M.AddNewInfo(account, password, serverId, areaId);
	else
		M.UpdateTimeStamps(index);
		M.UpdateCurrentInfo(account, password, serverId, areaId);
	end
end

function M.UpdateTimeStamps(index)
	-- local time = GetServerTime();
	local time = os.time() / 100000;
	local beforeTimeStamp = M.timeStamps[index];
	M.timeStamps[index] = time;
	M.SaveTimeStamps();
	M.SortTimeStamps();
	if beforeTimeStamp then
		deleteTimeStamp = beforeTimeStamp;
	else
		addTimeStamp = time;
	end
end

function M.AddTimeStamps()
	-- local time = GetServerTime();
	local time = os.time() / 100000;
	local length = TableUtil.TableLength(M.timeStamps);
	if length >= LocalSaveCommon.MaxCount then
		M.UpdateTimeStamps(length);
	else
		M.UpdateTimeStamps(length + 1);
	end
end

function M.UpdateCurrentInfo(acc, pass, id, areaId)
	if deleteTimeStamp == 0 then
		return;
	end
	local time = M.timeStamps[LocalSaveCommon.CurrentIndex];
	local data = {};
	data[LocalSaveCommon.IndexEnum.Account]  = acc;
	data[LocalSaveCommon.IndexEnum.Password] = pass;
	data[LocalSaveCommon.IndexEnum.ServerId] = id;
	data[LocalSaveCommon.IndexEnum.AreaId] = areaId;
	M.readSavedInfo[time] = M.readSavedInfo[deleteTimeStamp];
	M.extendSavedInfo[time] = M.extendSavedInfo[deleteTimeStamp];
	M.readSavedInfo[deleteTimeStamp] = nil;
	M.extendSavedInfo[deleteTimeStamp] = nil;

	M.UpdateReadInfo(data);
	M.SaveCurrentInfo();
end

function M.AddNewInfo(acc, pass, id, areaId)
	if acc == nil or pass == nil then
		if error then error("In LocalSaveMgr.AddNewInfo, account or password is nil") end
		return;
	end
	if deleteTimeStamp == 0 and addTimeStamp == 0 then
		return;
	end

	local data = {};
	data[LocalSaveCommon.IndexEnum.Account] = acc;
	data[LocalSaveCommon.IndexEnum.Password] = pass;
	data[LocalSaveCommon.IndexEnum.ServerId] = id;
	data[LocalSaveCommon.IndexEnum.AreaId] = areaId;

	M.UpdateReadInfo(data);
	
	if deleteTimeStamp ~= 0 and addTimeStamp == 0 then
		-- 删除之前的第三条信息，来绑定新信息
		M.readSavedInfo[deleteTimeStamp] = nil;
		M.extendSavedInfo[deleteTimeStamp] = nil;
	end

	M.SaveCurrentInfo();
end

function M.SaveTimeStamps()
	local stamps = json.encode(M.timeStamps);
	-- UnityEngine.PlayerPrefs.SetString(LocalSaveCommon.TimeStampIndex, stamps);
	LocalStorage.Put(LocalSaveCommon.TimeStampIndex, stamps);
	if luadebugger then
		File.WriteAllText("TimeStamp.txt", stamps);
	end
end

function M.SaveCurrentInfo()
	if deleteTimeStamp ~= 0 then
		-- UnityEngine.PlayerPrefs.DeleteKey(tostring(deleteTimeStamp));
		LocalStorage.Remove(tostring(deleteTimeStamp))
		deleteTimeStamp = 0;
	end
	if addTimeStamp ~= 0 then
		addTimeStamp = 0;
	end
	local time = M.timeStamps[LocalSaveCommon.CurrentIndex];
	local info = M.readSavedInfo[time];
	-- UnityEngine.PlayerPrefs.SetString(tostring(time), json.encode(info));
	LocalStorage.Put(tostring(time), json.encode(info));
	if luadebugger then
		File.WriteAllText("LocalSave.txt", json.encode(M.readSavedInfo));
	end
end

function M.isSavedInfo(key)
	for _, index in pairs(LocalSaveCommon.IndexEnum) do
		if index == key then
			return true;
		end
	end
	return false;
end

-- 判断是否是新建账号
function M.isNewAccount(account)
	local length = TableUtil.TableLength(M.readSavedInfo);
	if length == 0 then
		return true;
	end
	for _, data in pairs(M.readSavedInfo) do
		for key, value in pairs(data) do
			if key == LocalSaveCommon.IndexEnum.Account and value == account then
				return false;
			end
		end
	end
	return true;
end

function M.GetTimeStampByAccount(account)
	for time, data in pairs(M.readSavedInfo) do
		for key, value in pairs(data) do
			if key == LocalSaveCommon.IndexEnum.Account and value == account then
				return time;
			end
		end
	end
end

-- 根据账户名获取在M.timeStamps中的位置
function M.GetIndexByAccount(account)
	if account == nil then
		if error then error("account is nil in LocalSaveMgr.GetIndexByAccount") end
	end
	if M.isNewAccount(account) then
		if M.accountNum >= LocalSaveCommon.MaxCount then
			return LocalSaveCommon.MaxCount
		else
			return M.accountNum + 1;
		end
	end

	local time = M.GetTimeStampByAccount(account);
	if time == nil then
		if error then error("cann't find account's timestamp, the account is " .. account) end
	end

	for index, timestamp in pairs(M.timeStamps) do
		if timestamp == time then
			return index;
		end
	end
end

function M.GetCurrentInfo()
	local timestamp = M.timeStamps[LocalSaveCommon.CurrentIndex];
	local data = M.extendSavedInfo[timestamp];
	if data then
		return data;
	else
		if info then info("no data in LocalSaveMgr.GetCurrentInfo") end
	end
end

return M;