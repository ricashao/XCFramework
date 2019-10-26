-- 创建角色模块
--require "UI.CreateRole.Data.CreateRoleNetProtocols";
local Singleton = require "Framework.Singleton"
CreateRoleManager = Class("CreateRoleManager", Singleton);

local M = CreateRoleManager;
local DEFAULT_ROLE = 1;

function M:Ctor()
	self.roleConfigs = {};
	self.roleName = "";
	self.recommendName = "";
end

function M:CreateRole(school, shape)
	local CCreateRole = require "Net.Protocols.protolua.ares.logic.ccreaterole";
	 local  p = CCreateRole.Create();
	 if p ~= nil then
	  	p.name = self.roleName;
      	p.school = school;
      	p.shape = shape;
      	LuaProtocolManager:getInstance():send(p);
	 end	
end

function M:RequestRoleName(id)
	if id == nil then
		id = DEFAULT_ROLE;
	end
	self:LoadCreateRoleConfigTable();
	local firstRecord = self.roleConfigs[id];

	if firstRecord == nil then
		return;
	end

	local CRequestName = require "Net.Protocols.protolua.ares.logic.crequestnamebyqiantong";
	 local  p = CRequestName.Create();
	 if p ~= nil then
	  	p.sex = firstRecord.sex;
      	LuaProtocolManager:getInstance():send(p);
	 end	

end

function M:SetRoleName(roleName)
	self.roleName = roleName;
	if CreateRoleDialogCtrl:GetInstanceNotCreate() then
		CreateRoleDialogCtrl:GetInstance():UpdateRoleName(self.roleName);
	end
end

function M:GetRoleName()
	return self.roleName;
end

function M:SetRecommendName(recommendName)
	self.recommendName = recommendName;
	if CreateRoleDialogCtrl:GetInstanceNotCreate() then
		CreateRoleDialogCtrl:GetInstance():UpdateRoleName(self.recommendName);
	end
end

function M:GetRecommendName()
	return self.recommendName;
end

function M:LoadCreateRoleConfigTable()
	local  len = TableUtil.TableLength(self.roleConfigs);
    if len <= 0 then
    	local  orderedIds = JsonConfigManager:GetInstance():GetTableByName("game.createrole.CreateRole"):GetDisorderAllID(); 
    	table.sort(orderedIds);
    	for _,id in ipairs(orderedIds) do
    		local record = JsonConfigManager:GetInstance():GetTableByName("game.createrole.CreateRole"):GetRecorder(id);
    		table.insert(self.roleConfigs, record);  	
    	end   
    end
end

function M:GetModelInfo(id)
	if id == nil then
		return;
	end

	local len = TableUtil.TableLength(self.roleConfigs);
	if len <= 0 then
		self:LoadCreateRoleConfigTable();
	end

	local  shapeRecord = self.roleConfigs[id];
	if shapeRecord == nil or shapeRecord.rolemodel1 == nil then
		return;
	end

	local shpapeID = tonumber(shapeRecord.rolemodel1);

	local table = BeanConfigManager:GetInstance():GetTableByName("ares.logic.npc.cnpcshapelua");
	if table == nil then
		print("CreateRoleManager GetModelInfo table ares.logic.npc.cnpcshapelua is can not read !!!");
		return;
	end

	local record = table:GetRecorder(shpapeID);
	if record == nil then
		print("CreateRoleManager GetModelInfo get table record is nil, the record id is : " .. shpapeID);
		return;
	end

	return shapeRecord.id, record;

end

function M:GetRoleRecord(id)
	if id == nil then
		return;
	end

	local len = TableUtil.TableLength(self.roleConfigs);
	if len <= 0 then
		self:LoadCreateRoleConfigTable();
	end

	local  shapeRecord = self.roleConfigs[id];
	return shapeRecord;
end

function M:GetRoleModelRecord(shapeID)
	if shapeID == nil then
		return;
	end

	local table = BeanConfigManager:GetInstance():GetTableByName("ares.logic.npc.cnpcshapelua");
	if table == nil then
		print("CreateRoleManager GetModelInfo table ares.logic.npc.cnpcshapelua is can not read !!!");
		return;
	end

	local record = table:GetRecorder(shapeID);
	if record == nil then
		print("CreateRoleManager GetModelInfo get table record is nil, the record id is : " .. shapeID);
		return;
	end

	return record;
end


function M:GetShoolRecords(id)
	--if id == nil then
	--	return;
	--end
	--
	--local len = TableUtil.TableLength(self.roleConfigs);
	--if len <= 0 then
	--	self:LoadCreateRoleConfigTable();
	--end
	--
	--local  shapeRecord = self.roleConfigs[id];
	--if shapeRecord == nil then
	--	return;
	--end
	--
	--local schools = shapeRecord.schools;	
	--if schools == nil then
	--	return;
	--end
	--
	--local tableRecords = BeanConfigManager:GetInstance():GetTableByName("ares.logic.role.schoolinfo");
	--if tableRecords == nil then
	--	print("CreateRoleManager table ares.logic.role.schoolinfo can not read !!!");
	--	return;
	--end
	--
	--local recordList = {};
	--for k,v in pairs(schools) do
	--	local record = tableRecords:GetRecorder(tonumber(v));
	--	if record ~= nil then
	--		table.insert(recordList, record);
	--	else
	--		
	--	end
	--end
	--
	--return recordList;
	return;
end

return M;
