---------------------------///使用说明////----------------
-----------------yss.2015.11.11-----
--[[
	--替换结构/扩展使用
	local replaceTable = {}
	replaceTable.title = {} or a v;   --值为表或一个变量
	replaceTable.content = {} or a v; --此项为默认内容替换
	replaceTable.leftBtn = {} or a v;
	replaceTable.rightBtn = {} or a v;

	leftBtnCallBack ---左边按钮回调（或只有一个按钮时候，回调）
	rightBtnCallBack ---右侧按钮回调
	passdata =  ---按钮回调参数

	--接口
    CommMsgMgr:GetInstance():Show(warningID, replaceTable ,passdata, leftBtnCallBack, rightBtnCallBack);

]]

-------------------------------///code///-------------
--[[szc
require "UI.SystemAd.SystemAdManager"
require "UI.CommMsgTip.Data.CommMsgNetProtocols";
require "UI.CommMsgTip.Data.DoubleTipUnit";
require "UI.CommMsgTip.SkinCtrl.DoubleTipCtrl";
]]

require "UI.CommMsgTip.Data.MsgCommon";
require "UI.CommMsgTip.SkinCtrl.TextTipCtrl";
local Singleton = require "Framework.Singleton";
CommMsgMgr = Class("CommMsgMgr", Singleton);
local M = CommMsgMgr;

function M:Ctor()
	Singleton.Ctor(self);
end

function M:LogOut()
	UIPrefabCtrl.DestroyPool();
end

function M:Show(warningID, replaceTable, passdata, leftBtnCallBack, rightBtnCallBack)
	local TipType, warningMsg, warningCloseTime = M.ReadTipsTable(warningID)	--warningCloseTime（未使用）
	local commMsgType = tonumber(TipType);

	--文字提示框
	if commMsgType == CommMsgType.TextTip or commMsgType == CommMsgType.ShowInChatTip then
		TextTipCtrl:GetInstance():Show(warningMsg, replaceTable);
		if commMsgType == CommMsgType.ShowInChatTip then
			local data = {};
			data.infoType = commMsgType;
			data.content = self.Replace(replaceTable.content, warningMsg);
			ChatMsgHandler:GetInstance():HandleNoticeTip(data);
		end

		return;
	end

	--双向提示框(双项带关闭按钮)
	if commMsgType == CommMsgType.DoubleTip then
		DoubleTipCtrl:GetInstance():Show(warningMsg, replaceTable, passdata, leftBtnCallBack, rightBtnCallBack);
		return;
	end
	
	--公告提示
	if commMsgType == CommMsgType.BoardTip or commMsgType == CommMsgType.BoardTip1 then
		--TODO 修改
		local data = require "UI.SystemAd.Data.SystemAdData".New(warningID, passdata, replaceTable.content);
		SystemAdManager:GetInstance():AddInfo(data);
		return;
	end

	-- 显示在频道模块里的消息（帮派公告|队伍公告）
	if commMsgType == CommMsgType.TeamTip or commMsgType == CommMsgType.FactionTip then
		local data = {};
		data.infoType = commMsgType;
		data.content = self.Replace(replaceTable.content, warningMsg);
		ChatMsgHandler:GetInstance():HandleNoticeTip(data);
		return;
	end
end

--服务信息特殊处理
function M:DealInfoDateToNormalShow(infoDate)
	local replaceTable = {}
	replaceTable.content = infoDate.parameters;
	self:Show(infoDate.msgid, replaceTable, infoDate.npcbaseid);
end

--读表由ID确定对话框内容
function M.ReadTipsTable(warningID)
	local tipTable = JsonConfigManager:GetInstance():GetTableByName("game.message.CMessageTip")
	local tipCfg = tipTable:GetRecorder(warningID)
	--读不到配置，防御措施
	if not tipCfg then
		if dibug then dibug("CMessageTip表中未配置ID："..warningID); end
		tipCfg = tipTable:GetRecorder(160507)
	end
	return tipCfg.type, tipCfg.msg, tipCfg.closetime
end

--替换方法
function M.Replace(parameters, str)
	if not str then
		if info then info("There is no str to Replace In Tips ,Check!");end
		return nil;
	end
		
	if parameters then
		local sb = StringBuilder:New();
		if type(parameters) == "table" then 
			for k,v in pairs(parameters) do
				local x = "parameter"..k;
			 	sb:Set(x, v);
			end
			return sb:GetString(str);
		else
			sb:Set("parameter1", parameters);
			return sb:GetString(str);
		end
	end
	return str;
end

return M;
