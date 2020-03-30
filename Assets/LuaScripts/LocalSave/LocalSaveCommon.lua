-- 存储LocalSaveCommon静态变量
LocalSaveCommon = {}

-- 本地存储时间戳的索引
LocalSaveCommon.TimeStampIndex = "timestampindex"

-- 本地可存储的最大数目
LocalSaveCommon.MaxCount = 3;
-- 当前账号信息的时间戳索引
LocalSaveCommon.CurrentIndex = 1;


-- 需要存储字段名字枚举
LocalSaveCommon.IndexEnum = {}
LocalSaveCommon.IndexEnum.Account = "account"
LocalSaveCommon.IndexEnum.Password = "password"