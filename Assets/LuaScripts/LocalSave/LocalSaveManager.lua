---
--- 客户端保存在本地的信息操作类
---
require "LocalSave.LocalSaveCommon";
local LocalSaveManager = BaseClass("LocalSaveManager", Singleton)

local basicInfo = {};
basicInfo[LocalSaveCommon.IndexEnum.Account] = "";
basicInfo[LocalSaveCommon.IndexEnum.Password] = "";

local json = require "cjson";

local timeStamps = {}

-- 从本地文件中读取的信息表，简称读取表（做读取，改变，写入操作）
local readSavedInfo = {};

-- 将读取表扩展成完整数据结构的信息表，简称扩展表（仅做外部获取时用，依赖读取表）
local extendSavedInfo = {};

local accountNum = 0;                -- 本地存储了几个账号信息

local deleteTimeStamp = 0;        -- 存储需要删除账号的时间戳
local addTimeStamp = 0;            -- 存储新建账号的时间戳



-- 给时间戳排序
local function SortTimeStamps()
    if table.length(timeStamps) < 2 then
        return
    end
    table.sort(timeStamps, function(a, b)
        return a > b
    end)
end


-- 进游戏时初始化读取表和扩展表
local function InitReadInfo()
    if table.length(timeStamps) < 1 then
        return
    end

    for _, timeStamp in pairs(timeStamps) do
        -- 获取时间戳对应的json数据
        local info = LocalStorage.Get(tostring(timeStamp))
        if info then
            readSavedInfo[timeStamp] = {}
            extendSavedInfo[timeStamp] = {}
            local tem = json.decode(info)
            for key, value in pairs(tem) do
                readSavedInfo[timeStamp][key] = value
            end

            for key, value in pairs(basicInfo) do
                if readSavedInfo[timeStamp][key] == nil then
                    extendSavedInfo[timeStamp][key] = value
                else
                    extendSavedInfo[timeStamp][key] = readSavedInfo[timeStamp][key]
                end
            end
            
            -- 计算账号数量
            accountNum = accountNum + 1
        end
    end
end

-- 进游戏的时候初始化时间戳信息
local function InitTimeStamps(self)
    -- 获取当前设备的时间戳数组
    local indexs = LocalStorage.Get(LocalSaveCommon.TimeStampIndex);
    if indexs then
        local tem = json.decode(indexs)
        if tem then
            timeStamps = tem
        end
    end
    -- 根据时间戳进行排序
    SortTimeStamps()
    -- 初始化账号信息
    InitReadInfo()
end



-- 是不是需要存储的key
local function isSavedInfo(key)
    for _, index in pairs(LocalSaveCommon.IndexEnum) do
        if index == key then
            return true
        end
    end
    return false
end

-- 更新
local function UpdateReadInfo(data)
    local time = timeStamps[LocalSaveCommon.CurrentIndex]
    for key, value in pairs(data) do
        if isSavedInfo(key) then
            if readSavedInfo[time] == nil then
                readSavedInfo[time] = {}
            end
            readSavedInfo[time][key] = value
        end
    end
end

-- 判断是否是新建账号
local function isNewAccount(account)
    local length = table.count(readSavedInfo)
    if length == 0 then
        return true
    end
    for _, data in pairs(readSavedInfo) do
        for key, value in pairs(data) do
            if key == LocalSaveCommon.IndexEnum.Account and value == account then
                return false
            end
        end
    end
    return true
end

-- 保存时间戳
local function SaveTimeStamps()
    local stamps = json.encode(timeStamps)
    LocalStorage.Put(LocalSaveCommon.TimeStampIndex, stamps)
end

local function UpdateTimeStamps(index)
    local time = os.time() / 100000
    local beforeTimeStamp = timeStamps[index]
    -- 保存新的时间戳 
    timeStamps[index] = time
    -- 保存时间戳json
    SaveTimeStamps()
    -- 排序时间戳
    SortTimeStamps()
    
    if beforeTimeStamp then
        deleteTimeStamp = beforeTimeStamp
    else
        addTimeStamp = time
    end
end

local function AddTimeStamps()
    local time = os.time() / 100000;
    local length = table.length(timeStamps)
    if length >= LocalSaveCommon.MaxCount then
        UpdateTimeStamps(length)
    else
        UpdateTimeStamps(length + 1)
    end
end

-- 保存到LocalStorage
local function SaveCurrentInfo()
    if deleteTimeStamp ~= 0 then
        LocalStorage.Remove(tostring(deleteTimeStamp))
        deleteTimeStamp = 0
    end
    if addTimeStamp ~= 0 then
        addTimeStamp = 0
    end
    local time = timeStamps[LocalSaveCommon.CurrentIndex]
    local info = readSavedInfo[time]
    LocalStorage.Put(tostring(time), json.encode(info))
end

-- 添加新的账号信息
local function AddNewInfo(acc, pass)
    if acc == nil or pass == nil then
        error("In LocalSaveMgr.AddNewInfo, account or password is nil")
        return
    end
    if deleteTimeStamp == 0 and addTimeStamp == 0 then
        return
    end

    local data = {}
    data[LocalSaveCommon.IndexEnum.Account] = acc
    data[LocalSaveCommon.IndexEnum.Password] = pass

    -- readSavedInfo 添加账号信息
    UpdateReadInfo(data)

    if deleteTimeStamp ~= 0 and addTimeStamp == 0 then
        -- 删除之前的第三条信息，来绑定新信息
        readSavedInfo[deleteTimeStamp] = nil
        extendSavedInfo[deleteTimeStamp] = nil
    end

    SaveCurrentInfo()
end

function UpdateCurrentInfo(acc, pass)
    if deleteTimeStamp == 0 then
        return
    end
    local time = M.timeStamps[LocalSaveCommon.CurrentIndex]
    local data = {}
    data[LocalSaveCommon.IndexEnum.Account] = acc
    data[LocalSaveCommon.IndexEnum.Password] = pass
    data[LocalSaveCommon.IndexEnum.ServerId] = id
    data[LocalSaveCommon.IndexEnum.AreaId] = areaId
    readSavedInfo[time] = readSavedInfo[deleteTimeStamp]
    extendSavedInfo[time] = extendSavedInfo[deleteTimeStamp]
    readSavedInfo[deleteTimeStamp] = nil
    extendSavedInfo[deleteTimeStamp] = nil

    UpdateReadInfo(data);
    SaveCurrentInfo();
end

-- @param
-- index 指下拉框中的顺序，1,2,3。若为新创建账号，为0。
-- account 账号，新账号时才传递
-- password 密码，新账号时才传递
local function UpdateInLogin(self, index, account, password)
    if index == nil then
        error("the index is nil in LocalSaveMgr.UpdateInLogin")
        return
    end
    if isNewAccount(account) then
        -- 新账号添加时间戳
        AddTimeStamps()
        -- 添加新的账号信息
        AddNewInfo(account, password)
    else
        UpdateTimeStamps(index)
        UpdateCurrentInfo(account, password)
    end
end

LocalSaveManager.InitTimeStamps = InitTimeStamps
LocalSaveManager.SortTimeStamps = SortTimeStamps
LocalSaveManager.InitReadInfo = InitReadInfo
LocalSaveManager.UpdateInLogin = UpdateInLogin

return LocalSaveManager