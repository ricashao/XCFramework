--[[
	延迟回调
	用法：
	local timer = require "Framework.Timer".New(0.5, self.func, self)
	timer:Start()
]]
require "Framework.TickerManager"

local Object = require "Framework.Object"
local Timer = Class("Timer", Object)

--[[
	@param delay     延迟时间或者延迟帧数
	@param func      回调函数
	@param data      回传参数
	@param loop      是否循环
	@param useframe  是否使用帧数
]]
function Timer:Ctor(delay, func, data, loop, useframe)
	self.delay = delay
	self.call = func
	self.started = false
	self.data = data
	self.loop = loop
	self.useframe = useframe

	self.count = 0
end

function Timer:Start()
	self.started = true
	TickerManager:GetInstanceNotCreate():AddTicker(self)
end

function Timer:Reset(delay, func, data)
	self:Stop()

	self.count = 0
	self.delay = delay
	self.call = func
	self.started = false
	self.data = data
end

function Timer:Tick(delta)
	if self.started then

		if self.useframe then
			self.count = self.count + 1
		else
			self.count = self.count + delta
		end

		if self.delay < self.count then
			self:RunEnd()
		end
	end
end

---private
function Timer:RunEnd()
	if self.loop then
		self.call(self.data)
		self.count = 0
	else
		self:Stop()
		self.call(self.data)
	end
end

function Timer:Stop()
	self.started = false
	TickerManager:GetInstanceNotCreate():RemoveTicker(self)
end

function Timer:Destroy()
	self:Stop()
end

return Timer