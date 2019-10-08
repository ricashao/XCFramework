UICommonManager = {};
local M = UICommonManager;
 

 
-- 得到零散字符串
function M.GetResString(id)
	local cfg = BeanConfigManager:GetInstance():GetTableByName("ares.logic.message.cstringres");
	return cfg:GetRecorder(id);
end

function M.GetMessageTip(id)
	local cfg = BeanConfigManager:GetInstance():GetTableByName("ares.logic.message.cmessagetip");
	return cfg:GetRecorder(id);
end

function M.GetSchoolMessageTip(id)
	return BeanConfigManager:GetInstance():GetTableByName("ares.logic.specialquest.cschoolmessagetip"):GetRecorder(id);
end

