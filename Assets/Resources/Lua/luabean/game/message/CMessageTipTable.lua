CMessageTipTable = {}
CMessageTipTable.__index = CMessageTipTable
function CMessageTipTable:new()
    local self = {}
    setmetatable(self, CMessageTipTable)
    self.m_cache = {}

    return self
end


function CMessageTipTable:LoadBeanFromJsonFile(filename)
    if not filename then
        return false
    end
    local data =  Resources.Load(filename):ToString()
    local json = require "rapidjson"
    local root = json.decode(data);
    self:BeanFromJson(root)
    return true;
end

function CMessageTipTable:BeanFromJson(datas)
    if not datas then return end
    for i,v in pairs(datas) do
        self:Decode(v)
    end
end

function CMessageTipTable:Decode(data)
    local cachetable = {}
    cachetable.id = data[1]
    cachetable.type = data[2]
    cachetable.msg = data[3]
    cachetable.closetime = data[4]
    
    self.m_cache[cachetable.id] = cachetable
end




return CMessageTipTable