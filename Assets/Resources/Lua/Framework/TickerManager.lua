local Singleton = require "Framework.Singleton"
TickerManager = Class("TickerManager", Singleton)

function TickerManager:Ctor()
	self.tList = {}
	self.delList = nil
end

function TickerManager:Destroy()
	self.tList = {}
	self.delList = nil
end

function TickerManager:AddTicker(ticker)
	local key = tostring(ticker)
	self.tList[key] = ticker
	if self.delList and self.delList[key] then
		self.delList[key] = nil
	end
end

function TickerManager:RemoveTicker(ticker)
	if not self.delList then
		self.delList = {}
	end
	local key = tostring(ticker)
	if self.tList[key] then
		-- table.insert(self.delList, key)
		self.delList[key] = 1
	end
end

function TickerManager:Tick(delta)
	for _, v in pairs(self.tList) do
		v:Tick(delta)
	end

	if self.delList then
		for k, _ in pairs(self.delList) do
			self.tList[k] = nil
		end
		self.delList = nil
	end
end

return TickerManager