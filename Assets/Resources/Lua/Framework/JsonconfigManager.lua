local Singleton = require "Framework.Singleton";
JsonConfigManager = Class("BeanConfigManager", Singleton);

function JsonConfigManager:Ctor(...)
    Singleton.Ctor(self, ...);
    self.jsonpath = "";
    self.binPath = "";
    self.tableInstance = {};
end

function JsonConfigManager:Initialize(jsonpath, binpath)
    self.jsonpath = jsonpath;
    self.binPath = binpath;
end

function JsonConfigManager:MakeTableValue(tablename)
    local jsonname = string.gsub(tablename, "%.", "/")
    local jsonfilename = self.jsonpath .. jsonname .. "";
    local binfilename = self.binPath .. tablename .. "";--todo
    local mod = require("luabean." .. tablename .. "Table");
    local key = string.lower(tablename)
    self.tableInstance[key] = mod:new();
    if not self.tableInstance[key]:LoadBeanFromJsonFile(jsonfilename) then
        error(tablename + "json文件不存在");
    end
end

function JsonConfigManager:GetTableByName(tablename)
    local key = string.lower(tablename)
    if not self.tableInstance[key] then
        self:MakeTableValue(tablename);
    end
    return self.tableInstance[key];
end

return JsonConfigManager;
