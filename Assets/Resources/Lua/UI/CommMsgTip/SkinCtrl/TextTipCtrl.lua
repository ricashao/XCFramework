local Singleton = require "Framework.Singleton"
TextTipCtrl = Class("TextTipCtrl", Singleton)
local M = TextTipCtrl;

local infoItem = require "UI.CommMsgTip.Skin.TextTipItem";

--在此初始化一些全局变量
function M:Ctor()
	Singleton.Ctor(self);

	--可配置参数
	self.maxItemNum = self:InitValue(10006); --可显示的最大提示框个数 3
	self.moveSpeed = self:InitValue(10007)/1000; --移动速度 7.3
	self.destroyTime = self:InitValue(10008)/1000; --秒为单位，提示框销毁时间 1.82
	self.startPosY = self:InitValue(10009); --item创建位置 20
	self.movePosY = self:InitValue(10010); -- 移动到指定位置 70

	self.itemList = {};--存放itemlist
	self.infoDataList = {}; --存放数据

end

function M:InitValue(id)
	local cfg = JsonConfigManager:GetInstance():GetTableByName("game.systemsetting.InterfaceSetting");
	return cfg:GetRecorder(id).value;
end

-- 销毁
function M:Destroy()
	Singleton.Destroy(self);
end

--show
function M:Show(warningMsg, ReplaceTable)
	if ReplaceTable then
		warningMsg = CommMsgMgr.Replace(ReplaceTable.content, warningMsg);
	end
	table.insert(self.infoDataList, warningMsg);
	TickerManager:GetInstance():AddTicker(self);
end

function M:Tick(delta)
	--创建
	self:ShowInItem();

	--移动
	self:MoveItem(delta);
end

--item移动效果
function M:MoveItem(delta)
	local num = TableUtil.TableLength(self.itemList);
	
	if num > 0 then
		item = self.itemList[num];
		if item.rectTransform.anchoredPosition.y >= self.movePosY then
			TickerManager:GetInstance():RemoveTicker(self);
		end
	end

	for _, v in pairs(self.itemList) do
		local mvy = self.moveSpeed * 1000 * delta
		v:SetPosition(mvy)
	end
end

--显示在item
function M:ShowInItem()
	
	local num = TableUtil.TableLength(self.itemList);

	--如果item个数超过规定，则返回
	if num >= self.maxItemNum then
		return
	end
	--无数据，返回
	if next(self.infoDataList) == nil then
		return
	end

	local lastItemRT = nil;
	local y = nil;
	if num > 0 then
		lastItemPos = self.itemList[num].rectTransform.anchoredPosition;
		--最后一个没有移动到指定位置，返回
		if lastItemPos.y < self.movePosY then 
			return;
		else
			if self.infoDataList[1] then
				y = lastItemPos.y - self.itemList[num]:GetHeight();
				self:NewItem(self.infoDataList[1], self.startPosY, y);
			end
		end
	else
        --界面上没有item
		self:NewItem(self.infoDataList[1], self.startPosY)
	end
end

--移除队首数据
function M:RemoveFirstData()
	for k,v in pairs(self.infoDataList) do
		table.remove(self.infoDataList, k);
		return;
	end
end

--创建item
function M:NewItem(data, startPos, addPos)
	local item = infoItem.New(data, startPos);
	self:RemoveFirstData();
	table.insert(self.itemList, item);
	item:StartCountdown(self.destroyTime);
	if addPos then
		item.rectTransform.anchoredPosition = Vector2.New(item.rectTransform.anchoredPosition.x, addPos);
	end
end

--列表中删除数据
function M:RemoveItem()

	--移除队首item
	for k,v in pairs(self.itemList) do
		table.remove(self.itemList, k)
		break;
	end

	--如果移除最后一个item 且 数据表为空，停止计时
	-- if next(self.itemList) == nil and next(self.infoDataList) == nil then
	-- 	TickerManager:GetInstance():RemoveTicker(self);
	-- 	return
	-- end
end

return M