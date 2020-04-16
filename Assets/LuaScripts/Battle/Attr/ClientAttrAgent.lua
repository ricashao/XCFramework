---
--- 战斗单位属性代理
--- Created by ricashao.
--- DateTime: 2020/4/16 15:50
---
local ClientAttrAgent = BaseClass("ClientAttrAgent")

local function __init(self, battler)
    self.battler = battler
    self.hp = 0
    self.attrs = {}
end

local function GetHp(self)
    return self.hp
end

local function AddHp(self, addhp)
    local oldhp = self.hp
    local newhp = oldhp + addhp
    local maxhp = self:GetMaxHp()
    if newhp > maxhp then
        newhp = maxhp
    elseif newhp < 0 then
        newhp = 0
    end
    self.hp = newhp
    return newhp
end

local function GetMaxHp(self)
    return self:GetAttr(AttrType.MAX_HP)
end

local function GetAttr(self, attrType)
    if (attrType == AttrType.HP) then
        return self.hp
    end
    return self.attrs[attrType] or 0
end

local function SetAttr(self, attrType, value)
    if (attrType == AttrType.HP) then
        self.hp = value
    end
    self.attrs[attrType] = value
end

local function UpdateAttrs(self, attrValues)
    for attrType, value in pairs(attrValues) do
        if (attrType == AttrType.HP) then
            self:AddHp(value)
        else
            self:SetAttr(attrType, value)
        end
    end
end

ClientAttrAgent.__init = __init
ClientAttrAgent.GetHp = GetHp
ClientAttrAgent.GetMaxHp = GetMaxHp
ClientAttrAgent.AddHp = AddHp
ClientAttrAgent.GetAttr = GetAttr
ClientAttrAgent.SetAttr = SetAttr
ClientAttrAgent.UpdateAttrs = UpdateAttrs
return ClientAttrAgent