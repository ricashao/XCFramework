--[[

	事件定义统一写在这个文件
]]
require "Framework.BroadcastEvent"

HappyBird = {}

--------------------//添加区域
---示例：
HappyBird.ExampleEvent = BroadcastEvent.New()

--清理
function HappyBird.Clean()

	for k, v in pairs(HappyBird) do
		if v.Clean then
			v:Clean()
		end
	end
end

return HappyBird