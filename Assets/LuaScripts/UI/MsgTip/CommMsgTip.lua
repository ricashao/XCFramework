---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2020/3/31 14:40
---
local CommMsgTip = BaseClass("CommMsgTip", Singleton)
local infoItem = require "UI.MsgTip.Item.TextTipItem"

local function __init(self)
    self.maxItemNum = 3 --可显示的最大提示框个数 
    self.moveSpeed = 110 / 1000 --移动速度
    self.destroyTime = 1820 / 1000 --秒为单位，提示框销毁时间
    self.startPosY = 40 --item创建位置
    self.movePosY = 140 -- 移动到指定位置

    self.itemList = {} --存放itemlist
    self.infoDataList = {} --存放数据
end

local function Show(self, warningMsg)
    local msg = LangUtil.GetMsg(warningMsg)
    table.insert(self.infoDataList, msg)
    if (self.timer == nil) then
        self.timer = TimerManager:GetInstance():GetTimer(1, self.Tick, self, false, true)
        self.timer:Start()
    end
end

local function Tick(self)
    --创建
    self:ShowInItem()

    local delta_time = Time.deltaTime
    --移动
    self:MoveItem(delta_time)
end

--item移动效果
local function MoveItem(self, delta)
    local num = table.length(self.itemList)

    if num > 0 then
        item = self.itemList[num];
        if (not item.isReady) then
            return
        end
        if item.rectTransform.anchoredPosition.y >= self.movePosY then
            self.timer:Stop()
            self.timer = nil
        end
    end

    for _, v in pairs(self.itemList) do
        if (v.isReady) then
            local mvy = self.moveSpeed * 1000 * delta
            v:SetPosition(mvy)
        end
    end
end


--显示在item
local function ShowInItem(self)

    local num = table.length(self.itemList)

    --如果item个数超过规定，则返回
    if num >= self.maxItemNum then
        return
    end
    --无数据，返回
    if next(self.infoDataList) == nil then
        return
    end

    local y = 0
    local lastItemPos = nil
    if num > 0 then
        if not self.itemList[num].isReady then
            return
        end
        lastItemPos = self.itemList[num].rectTransform.anchoredPosition;
        --最后一个没有移动到指定位置，返回
        if lastItemPos.y < self.movePosY then
            return
        else
            if self.infoDataList[1] then
                y = lastItemPos.y - self.itemList[num]:GetHeight()
                self:NewItem(self.infoDataList[1], self.startPosY, y)
            end
        end
    else
        self:NewItem(self.infoDataList[1], self.startPosY)
    end
end

--移除队首数据
local function RemoveFirstData(self)
    for k, v in pairs(self.infoDataList) do
        table.remove(self.infoDataList, k)
        return
    end
end

--创建item
local function NewItem(self, data, startPos, addPos)
    local item = infoItem.New(data, startPos, function(item)
    end)
    self:RemoveFirstData();
    table.insert(self.itemList, item);
    item:StartCountdown(self.destroyTime);
    if addPos then
        item.rectTransform.anchoredPosition = Vector2.New(item.rectTransform.anchoredPosition.x, addPos);
    end

end

--列表中删除数据
local function RemoveItem(self)
    --移除队首item
    for k, v in pairs(self.itemList) do
        table.remove(self.itemList, k)
        break
    end
end

CommMsgTip.__init = __init
CommMsgTip.Show = Show
CommMsgTip.Tick = Tick
CommMsgTip.ShowInItem = ShowInItem
CommMsgTip.MoveItem = MoveItem
CommMsgTip.NewItem = NewItem
CommMsgTip.RemoveItem = RemoveItem
CommMsgTip.RemoveFirstData = RemoveFirstData

return CommMsgTip