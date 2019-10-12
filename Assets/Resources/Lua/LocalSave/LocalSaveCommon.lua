-- 存储LocalSaveCommon静态变量
LocalSaveCommon = {};

-- 本地存储时间戳的索引
LocalSaveCommon.TimeStampIndex = "timestampindex";
-- 是否显示的存储到本地txt文件中
LocalSaveCommon.TxtDebug = true;

-- 本地可存储的最大数目
LocalSaveCommon.MaxCount = 3;
-- 当前账号信息的时间戳索引
LocalSaveCommon.CurrentIndex = 1;

-- 默认的区 名字
LocalSaveCommon.RecommendAreaID = 2;
LocalSaveCommon.RecommendServerID = 1;

-- 需要存储字段名字枚举
LocalSaveCommon.IndexEnum = {};
LocalSaveCommon.IndexEnum.Account = "account";
LocalSaveCommon.IndexEnum.Password = "password";
LocalSaveCommon.IndexEnum.AreaId = "areaid";
LocalSaveCommon.IndexEnum.ServerId = "serverid";
LocalSaveCommon.IndexEnum.ServerIp = "ip";
LocalSaveCommon.IndexEnum.ServerPort = "port";
LocalSaveCommon.IndexEnum.Music = "music";
LocalSaveCommon.IndexEnum.AutoCharOpera = "autoCharOpera";--{operaType = 0, operaId = 0};
LocalSaveCommon.IndexEnum.AutoPetOpera = "autoPetOpera";--{operaType = 0, operaId = 0};
LocalSaveCommon.IndexEnum.LastCharOpera = "lastCharOpera";--{operaType = 0, operaId = 0};
LocalSaveCommon.IndexEnum.LastPetOpera = "lastPetOpera";--{operaType = 0, operaId = 0};
LocalSaveCommon.IndexEnum.isAutoFight = "isAuto";--{operaType = 0, operaId = 0};




-- 存储历史消息
LocalSaveCommon.History = "history";

--服务器上已有角色信息
LocalSaveCommon.LoginPlayerInServerInfo = "login_player_info";
--最近登录服务器记录
LocalSaveCommon.LoginServerRecord = "login_server_record";