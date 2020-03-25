local common_pb = require "Net.Protol.common_pb"

function Decoder(pb_data)
	local msg = common_pb.UserInfo()
	msg:ParseFromString(pb_data)
	assert(msg.userId == 10010)
	assert(msg.username == "test")
	assert(msg.userState.onlineState == 123123)
	
end

function Encoder()
	local msg = common_pb.UserInfo()
	msg.userId = 10010
	msg.username = "test"
	msg.userState.onlineState = 123123
	return msg:SerializeToString()
end

local function Run()
	local pb_data = Encoder()
	Decoder(pb_data)
	print("ProtobufTest Pass!")
end

return {
	Run = Run
}