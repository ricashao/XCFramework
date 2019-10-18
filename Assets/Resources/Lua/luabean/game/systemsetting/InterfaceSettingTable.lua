--/*-*begin $area1*-*/
--这里填写类上方的require内容
--/*-*end $area1*-*/
--创建时间2019/10/18 18:20:48
InterfaceSettingTable = {}
InterfaceSettingTable.__index = InterfaceSettingTable
function InterfaceSettingTable:new()
    local self = {}
    setmetatable(self, InterfaceSettingTable)
    self.m_cache = {}

    return self
end


function InterfaceSettingTable:LoadBeanFromJsonFile(filename)
    if not filename then
        return false
    end
    local data =  Resources.Load(filename):ToString()
    local json = require 'rapidjson'
    local root = json.decode(data);
    self:BeanFromJson(root)
    return true;
end

function InterfaceSettingTable:BeanFromJson(datas)
    if not datas then return end
    for i,v in pairs(datas) do
        self:Decode(v)
    end
end
--/*-*begin $area2*-*/
--这里填写类里面的手写内容
function InterfaceSettingTable:GetRecorder(id)
    if not self.m_cache[id] then
        if dibug then dibug('InterfaceSettingTable GetRecorder for' .. id .. 'is Nil') end
        return nil
    end
    return self.m_cache[id]
end
--/*-*end $area2*-*/
function InterfaceSettingTable:Decode(data)
	 local cachetable = {}
	--id
	cachetable.id = data[1];
	--值
	cachetable.value = data[2];

--/*-*begin $decode*-*/
--这里填写方法中的手写内容
--/*-*end $decode*-*/
	self.m_cache[cachetable.id] = cachetable
end
return InterfaceSettingTable
