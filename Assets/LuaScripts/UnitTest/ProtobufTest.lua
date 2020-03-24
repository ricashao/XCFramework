local person_pb = require "Net.Protol.test_person_pb"

function Decoder(pb_data)
	local msg = person_pb.Person()
	msg:ParseFromString(pb_data)
	-- TODO：后续测试int64的支持
	--assert(tonumber(msg.header.cmd) == 10010, 'msg.header.cmd')
	assert(msg.header.cmd == 10010)
	assert(msg.header.seq == 1)
	-- TODO：后续测试int64的支持
	--assert(tonumber(msg.id) == 1223372036854775807, 'msg.id')
	assert(msg.id == "1223372036854775807")
	assert(msg.name == "foo")
	assert(msg.array[1] == 1)
	assert(msg.array[2] == 2)
	assert(msg.age == 18)
	assert(msg.email == "703016035@qq.com")
	assert(msg.Extensions[person_pb.Phone.phones][1].num == "13788888888")
	assert(msg.Extensions[person_pb.Phone.phones][1].type == person_pb.Phone.MOBILE)	
end

function Encoder()
	local msg = person_pb.Person()                                 
	msg.header.cmd = 10010                                
	msg.header.seq = 1
	msg.id = "1223372036854775807"            
	msg.name = "foo"
	--数组添加                              
	msg.array:append(1)                              
	msg.array:append(2)            
	--extensions 添加
	local phone = msg.Extensions[person_pb.Phone.phones]:add()
	phone.num = '13788888888'      
	phone.type = person_pb.Phone.MOBILE 
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