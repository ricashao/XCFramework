--/*-*begin $area1*-*/
--这里填写类上方的require内容
--/*-*end $area1*-*/
--创建时间2019/10/26 19:25:43
CreateRoleTable = {}
CreateRoleTable.__index = CreateRoleTable
function CreateRoleTable:new()
    local self = {}
    setmetatable(self, CreateRoleTable)
    self.m_cache = {}

    return self
end


function CreateRoleTable:LoadBeanFromJsonFile(filename)
    if not filename then
        return false
    end
    local data =  Resources.Load(filename):ToString()
    local json = require 'rapidjson'
    local root = json.decode(data);
    self:BeanFromJson(root)
    return true;
end

function CreateRoleTable:BeanFromJson(datas)
    if not datas then return end
    for i,v in pairs(datas) do
        self:Decode(v)
    end
end
--/*-*begin $area2*-*/
--这里填写类里面的手写内容
function CreateRoleTable:GetRecorder(id)
	if not self.m_cache[id] then
		if dibug then dibug('CreateRoleConfigTable GetRecorder for' .. id .. 'is Nil') end
		return nil
	end
	return self.m_cache[id]
end
function CreateRoleTable:GetDisorderAllID()
	local idvec = {}
	local cnt = 0
	for k,v in pairs(self.m_cache) do
		cnt = cnt + 1
		idvec[cnt] = k
	end
	return idvec
end
--/*-*end $area2*-*/
function CreateRoleTable:Decode(data)
	 local cachetable = {}
	--id
	cachetable.id = data[1];
	--性别
	cachetable.sex = data[2];
	--描述
	cachetable.name = data[3];
	--数值型效果id
	cachetable.card = data[4];
	--property
	cachetable.property = data[5];
	--描述
	cachetable.describe = data[6];
	--武器
	cachetable.weapon = data[7];
	--武器1
	cachetable.weapon1 = data[8];
	--创建模型
	cachetable.createmodelid1 = data[9];
	--rolemodel1
	cachetable.rolemodel1 = data[10];
	--weapon1attack
	cachetable.weapon1attack = data[11];
	--weapon1magic
	cachetable.weapon1magic = data[12];
	--weapon2
	cachetable.weapon2 = data[13];
	--createmodelid2
	cachetable.createmodelid2 = data[14];
	--rolemodel2
	cachetable.rolemodel2 = data[15];
	--weapon2attack
	cachetable.weapon2attack = data[16];
	--weapon2magic
	cachetable.weapon2magic = data[17];
	--showweapon
	cachetable.showweapon = data[18];
	--effectpath
	cachetable.effectpath = data[19];
	--roleimage
	cachetable.roleimage = data[20];
	--weaponcolorpurple1
	cachetable.weaponcolorpurple1 = data[21];
	--weaponcolororange1
	cachetable.weaponcolororange1 = data[22];
	--weaponcolorgold1
	cachetable.weaponcolorgold1 = data[23];
	--weaponcolorpurple2
	cachetable.weaponcolorpurple2 = data[24];
	--weaponcolororange2
	cachetable.weaponcolororange2 = data[25];
	--weaponcolorgold2
	cachetable.weaponcolorgold2 = data[26];
	--color1
	cachetable.color1 = data[27];
	--color2
	cachetable.color2 = data[28];
	--color3
	cachetable.color3 = data[29];
	--schools
	cachetable.schools = data[30];
	--weapon1point
	cachetable.weapon1point = data[31];
	--weapon2point
	cachetable.weapon2point = data[32];
	--voices
	cachetable.voices = data[33];

--/*-*begin $decode*-*/
--这里填写方法中的手写内容
--/*-*end $decode*-*/
	self.m_cache[cachetable.id] = cachetable
end
return CreateRoleTable
