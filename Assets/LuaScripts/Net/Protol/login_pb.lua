--Generated By protoc-gen-lua Do not Edit
local protobuf = require "Framework.Net.Protobuf.protobuf"
local common_pb = require("Net.Protol.common_pb")
local _M = {}

_M.LOGIN_C2S_MSG = protobuf.Descriptor();
_M.LOGIN_C2S_MSG_USERNAME_FIELD = protobuf.FieldDescriptor();
_M.LOGIN_C2S_MSG_PASSWORD_FIELD = protobuf.FieldDescriptor();
_M.LOGIN_S2C_MSG = protobuf.Descriptor();
_M.LOGIN_S2C_MSG_CODE_FIELD = protobuf.FieldDescriptor();
_M.REGIST_C2S_MSG = protobuf.Descriptor();
_M.REGIST_C2S_MSG_USERNAME_FIELD = protobuf.FieldDescriptor();
_M.REGIST_C2S_MSG_PASSWORD_FIELD = protobuf.FieldDescriptor();
_M.REGIST_S2C_MSG = protobuf.Descriptor();
_M.REGIST_S2C_MSG_CODE_FIELD = protobuf.FieldDescriptor();
_M.CREATENAME_S2C_MSG = protobuf.Descriptor();
_M.CREATENAME_S2C_MSG_CODE_FIELD = protobuf.FieldDescriptor();
_M.CREATENAME_S2C_MSG_NAME_FIELD = protobuf.FieldDescriptor();
_M.CREATENAME_C2S_MSG = protobuf.Descriptor();
_M.CREATENAME_C2S_MSG_NAME_FIELD = protobuf.FieldDescriptor();
_M.RANDOMNAME_C2S_MSG = protobuf.Descriptor();
_M.RANDOMNAME_S2C_MSG = protobuf.Descriptor();
_M.RANDOMNAME_S2C_MSG_NAME_FIELD = protobuf.FieldDescriptor();
_M.FORCEOFFLINE_S2C_MSG = protobuf.Descriptor();
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD = protobuf.FieldDescriptor();
_M.ENTERGAME_C2S_MSG = protobuf.Descriptor();
_M.ENTERGAME_S2C_MSG = protobuf.Descriptor();
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD = protobuf.FieldDescriptor();
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD = protobuf.FieldDescriptor();

_M.LOGIN_C2S_MSG_USERNAME_FIELD.name = "username"
_M.LOGIN_C2S_MSG_USERNAME_FIELD.full_name = ".Login_C2S_Msg.username"
_M.LOGIN_C2S_MSG_USERNAME_FIELD.number = 1
_M.LOGIN_C2S_MSG_USERNAME_FIELD.index = 0
_M.LOGIN_C2S_MSG_USERNAME_FIELD.label = 1
_M.LOGIN_C2S_MSG_USERNAME_FIELD.has_default_value = false
_M.LOGIN_C2S_MSG_USERNAME_FIELD.default_value = ""
_M.LOGIN_C2S_MSG_USERNAME_FIELD.type = 9
_M.LOGIN_C2S_MSG_USERNAME_FIELD.cpp_type = 9

_M.LOGIN_C2S_MSG_PASSWORD_FIELD.name = "password"
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.full_name = ".Login_C2S_Msg.password"
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.number = 2
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.index = 1
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.label = 1
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.has_default_value = false
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.default_value = ""
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.type = 9
_M.LOGIN_C2S_MSG_PASSWORD_FIELD.cpp_type = 9

_M.LOGIN_C2S_MSG.name = "Login_C2S_Msg"
_M.LOGIN_C2S_MSG.full_name = ".Login_C2S_Msg"
_M.LOGIN_C2S_MSG.nested_types = {}
_M.LOGIN_C2S_MSG.enum_types = {}
_M.LOGIN_C2S_MSG.fields = {_M.LOGIN_C2S_MSG_USERNAME_FIELD, _M.LOGIN_C2S_MSG_PASSWORD_FIELD}
_M.LOGIN_C2S_MSG.is_extendable = false
_M.LOGIN_C2S_MSG.extensions = {}
_M.LOGIN_S2C_MSG_CODE_FIELD.name = "code"
_M.LOGIN_S2C_MSG_CODE_FIELD.full_name = ".Login_S2C_Msg.code"
_M.LOGIN_S2C_MSG_CODE_FIELD.number = 1
_M.LOGIN_S2C_MSG_CODE_FIELD.index = 0
_M.LOGIN_S2C_MSG_CODE_FIELD.label = 1
_M.LOGIN_S2C_MSG_CODE_FIELD.has_default_value = false
_M.LOGIN_S2C_MSG_CODE_FIELD.default_value = nil
_M.LOGIN_S2C_MSG_CODE_FIELD.message_type = common_pb.CODE
_M.LOGIN_S2C_MSG_CODE_FIELD.type = 11
_M.LOGIN_S2C_MSG_CODE_FIELD.cpp_type = 10

_M.LOGIN_S2C_MSG.name = "Login_S2C_Msg"
_M.LOGIN_S2C_MSG.full_name = ".Login_S2C_Msg"
_M.LOGIN_S2C_MSG.nested_types = {}
_M.LOGIN_S2C_MSG.enum_types = {}
_M.LOGIN_S2C_MSG.fields = {_M.LOGIN_S2C_MSG_CODE_FIELD}
_M.LOGIN_S2C_MSG.is_extendable = false
_M.LOGIN_S2C_MSG.extensions = {}
_M.REGIST_C2S_MSG_USERNAME_FIELD.name = "username"
_M.REGIST_C2S_MSG_USERNAME_FIELD.full_name = ".Regist_C2S_Msg.username"
_M.REGIST_C2S_MSG_USERNAME_FIELD.number = 1
_M.REGIST_C2S_MSG_USERNAME_FIELD.index = 0
_M.REGIST_C2S_MSG_USERNAME_FIELD.label = 1
_M.REGIST_C2S_MSG_USERNAME_FIELD.has_default_value = false
_M.REGIST_C2S_MSG_USERNAME_FIELD.default_value = ""
_M.REGIST_C2S_MSG_USERNAME_FIELD.type = 9
_M.REGIST_C2S_MSG_USERNAME_FIELD.cpp_type = 9

_M.REGIST_C2S_MSG_PASSWORD_FIELD.name = "password"
_M.REGIST_C2S_MSG_PASSWORD_FIELD.full_name = ".Regist_C2S_Msg.password"
_M.REGIST_C2S_MSG_PASSWORD_FIELD.number = 2
_M.REGIST_C2S_MSG_PASSWORD_FIELD.index = 1
_M.REGIST_C2S_MSG_PASSWORD_FIELD.label = 1
_M.REGIST_C2S_MSG_PASSWORD_FIELD.has_default_value = false
_M.REGIST_C2S_MSG_PASSWORD_FIELD.default_value = ""
_M.REGIST_C2S_MSG_PASSWORD_FIELD.type = 9
_M.REGIST_C2S_MSG_PASSWORD_FIELD.cpp_type = 9

_M.REGIST_C2S_MSG.name = "Regist_C2S_Msg"
_M.REGIST_C2S_MSG.full_name = ".Regist_C2S_Msg"
_M.REGIST_C2S_MSG.nested_types = {}
_M.REGIST_C2S_MSG.enum_types = {}
_M.REGIST_C2S_MSG.fields = {_M.REGIST_C2S_MSG_USERNAME_FIELD, _M.REGIST_C2S_MSG_PASSWORD_FIELD}
_M.REGIST_C2S_MSG.is_extendable = false
_M.REGIST_C2S_MSG.extensions = {}
_M.REGIST_S2C_MSG_CODE_FIELD.name = "code"
_M.REGIST_S2C_MSG_CODE_FIELD.full_name = ".Regist_S2C_Msg.code"
_M.REGIST_S2C_MSG_CODE_FIELD.number = 1
_M.REGIST_S2C_MSG_CODE_FIELD.index = 0
_M.REGIST_S2C_MSG_CODE_FIELD.label = 1
_M.REGIST_S2C_MSG_CODE_FIELD.has_default_value = false
_M.REGIST_S2C_MSG_CODE_FIELD.default_value = nil
_M.REGIST_S2C_MSG_CODE_FIELD.message_type = common_pb.CODE
_M.REGIST_S2C_MSG_CODE_FIELD.type = 11
_M.REGIST_S2C_MSG_CODE_FIELD.cpp_type = 10

_M.REGIST_S2C_MSG.name = "Regist_S2C_Msg"
_M.REGIST_S2C_MSG.full_name = ".Regist_S2C_Msg"
_M.REGIST_S2C_MSG.nested_types = {}
_M.REGIST_S2C_MSG.enum_types = {}
_M.REGIST_S2C_MSG.fields = {_M.REGIST_S2C_MSG_CODE_FIELD}
_M.REGIST_S2C_MSG.is_extendable = false
_M.REGIST_S2C_MSG.extensions = {}
_M.CREATENAME_S2C_MSG_CODE_FIELD.name = "code"
_M.CREATENAME_S2C_MSG_CODE_FIELD.full_name = ".CreateName_S2C_Msg.code"
_M.CREATENAME_S2C_MSG_CODE_FIELD.number = 1
_M.CREATENAME_S2C_MSG_CODE_FIELD.index = 0
_M.CREATENAME_S2C_MSG_CODE_FIELD.label = 1
_M.CREATENAME_S2C_MSG_CODE_FIELD.has_default_value = false
_M.CREATENAME_S2C_MSG_CODE_FIELD.default_value = nil
_M.CREATENAME_S2C_MSG_CODE_FIELD.message_type = common_pb.CODE
_M.CREATENAME_S2C_MSG_CODE_FIELD.type = 11
_M.CREATENAME_S2C_MSG_CODE_FIELD.cpp_type = 10

_M.CREATENAME_S2C_MSG_NAME_FIELD.name = "name"
_M.CREATENAME_S2C_MSG_NAME_FIELD.full_name = ".CreateName_S2C_Msg.name"
_M.CREATENAME_S2C_MSG_NAME_FIELD.number = 2
_M.CREATENAME_S2C_MSG_NAME_FIELD.index = 1
_M.CREATENAME_S2C_MSG_NAME_FIELD.label = 1
_M.CREATENAME_S2C_MSG_NAME_FIELD.has_default_value = false
_M.CREATENAME_S2C_MSG_NAME_FIELD.default_value = ""
_M.CREATENAME_S2C_MSG_NAME_FIELD.type = 9
_M.CREATENAME_S2C_MSG_NAME_FIELD.cpp_type = 9

_M.CREATENAME_S2C_MSG.name = "CreateName_S2C_Msg"
_M.CREATENAME_S2C_MSG.full_name = ".CreateName_S2C_Msg"
_M.CREATENAME_S2C_MSG.nested_types = {}
_M.CREATENAME_S2C_MSG.enum_types = {}
_M.CREATENAME_S2C_MSG.fields = {_M.CREATENAME_S2C_MSG_CODE_FIELD, _M.CREATENAME_S2C_MSG_NAME_FIELD}
_M.CREATENAME_S2C_MSG.is_extendable = false
_M.CREATENAME_S2C_MSG.extensions = {}
_M.CREATENAME_C2S_MSG_NAME_FIELD.name = "name"
_M.CREATENAME_C2S_MSG_NAME_FIELD.full_name = ".CreateName_C2S_Msg.name"
_M.CREATENAME_C2S_MSG_NAME_FIELD.number = 1
_M.CREATENAME_C2S_MSG_NAME_FIELD.index = 0
_M.CREATENAME_C2S_MSG_NAME_FIELD.label = 2
_M.CREATENAME_C2S_MSG_NAME_FIELD.has_default_value = false
_M.CREATENAME_C2S_MSG_NAME_FIELD.default_value = ""
_M.CREATENAME_C2S_MSG_NAME_FIELD.type = 9
_M.CREATENAME_C2S_MSG_NAME_FIELD.cpp_type = 9

_M.CREATENAME_C2S_MSG.name = "CreateName_C2S_Msg"
_M.CREATENAME_C2S_MSG.full_name = ".CreateName_C2S_Msg"
_M.CREATENAME_C2S_MSG.nested_types = {}
_M.CREATENAME_C2S_MSG.enum_types = {}
_M.CREATENAME_C2S_MSG.fields = {_M.CREATENAME_C2S_MSG_NAME_FIELD}
_M.CREATENAME_C2S_MSG.is_extendable = false
_M.CREATENAME_C2S_MSG.extensions = {}
_M.RANDOMNAME_C2S_MSG.name = "RandomName_C2S_Msg"
_M.RANDOMNAME_C2S_MSG.full_name = ".RandomName_C2S_Msg"
_M.RANDOMNAME_C2S_MSG.nested_types = {}
_M.RANDOMNAME_C2S_MSG.enum_types = {}
_M.RANDOMNAME_C2S_MSG.fields = {}
_M.RANDOMNAME_C2S_MSG.is_extendable = false
_M.RANDOMNAME_C2S_MSG.extensions = {}
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.name = "name"
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.full_name = ".RandomName_S2C_Msg.name"
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.number = 1
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.index = 0
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.label = 2
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.has_default_value = false
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.default_value = ""
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.type = 9
_M.RANDOMNAME_S2C_MSG_NAME_FIELD.cpp_type = 9

_M.RANDOMNAME_S2C_MSG.name = "RandomName_S2C_Msg"
_M.RANDOMNAME_S2C_MSG.full_name = ".RandomName_S2C_Msg"
_M.RANDOMNAME_S2C_MSG.nested_types = {}
_M.RANDOMNAME_S2C_MSG.enum_types = {}
_M.RANDOMNAME_S2C_MSG.fields = {_M.RANDOMNAME_S2C_MSG_NAME_FIELD}
_M.RANDOMNAME_S2C_MSG.is_extendable = false
_M.RANDOMNAME_S2C_MSG.extensions = {}
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.name = "forceOfflineReason"
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.full_name = ".ForceOffline_S2C_Msg.forceOfflineReason"
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.number = 1
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.index = 0
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.label = 1
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.has_default_value = false
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.default_value = 0
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.type = 5
_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD.cpp_type = 1

_M.FORCEOFFLINE_S2C_MSG.name = "ForceOffline_S2C_Msg"
_M.FORCEOFFLINE_S2C_MSG.full_name = ".ForceOffline_S2C_Msg"
_M.FORCEOFFLINE_S2C_MSG.nested_types = {}
_M.FORCEOFFLINE_S2C_MSG.enum_types = {}
_M.FORCEOFFLINE_S2C_MSG.fields = {_M.FORCEOFFLINE_S2C_MSG_FORCEOFFLINEREASON_FIELD}
_M.FORCEOFFLINE_S2C_MSG.is_extendable = false
_M.FORCEOFFLINE_S2C_MSG.extensions = {}
_M.ENTERGAME_C2S_MSG.name = "EnterGame_C2S_Msg"
_M.ENTERGAME_C2S_MSG.full_name = ".EnterGame_C2S_Msg"
_M.ENTERGAME_C2S_MSG.nested_types = {}
_M.ENTERGAME_C2S_MSG.enum_types = {}
_M.ENTERGAME_C2S_MSG.fields = {}
_M.ENTERGAME_C2S_MSG.is_extendable = false
_M.ENTERGAME_C2S_MSG.extensions = {}
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.name = "player"
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.full_name = ".EnterGame_S2C_Msg.player"
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.number = 1
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.index = 0
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.label = 1
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.has_default_value = false
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.default_value = nil
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.message_type = common_pb.USERINFO
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.type = 11
_M.ENTERGAME_S2C_MSG_PLAYER_FIELD.cpp_type = 10

_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.name = "serverInfoDTO"
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.full_name = ".EnterGame_S2C_Msg.serverInfoDTO"
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.number = 2
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.index = 1
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.label = 1
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.has_default_value = false
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.default_value = nil
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.message_type = common_pb.SERVERINFODTO
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.type = 11
_M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD.cpp_type = 10

_M.ENTERGAME_S2C_MSG.name = "EnterGame_S2C_Msg"
_M.ENTERGAME_S2C_MSG.full_name = ".EnterGame_S2C_Msg"
_M.ENTERGAME_S2C_MSG.nested_types = {}
_M.ENTERGAME_S2C_MSG.enum_types = {}
_M.ENTERGAME_S2C_MSG.fields = {_M.ENTERGAME_S2C_MSG_PLAYER_FIELD, _M.ENTERGAME_S2C_MSG_SERVERINFODTO_FIELD}
_M.ENTERGAME_S2C_MSG.is_extendable = false
_M.ENTERGAME_S2C_MSG.extensions = {}

_M.CreateName_C2S_Msg = protobuf.Message(_M.CREATENAME_C2S_MSG)
_M.CreateName_S2C_Msg = protobuf.Message(_M.CREATENAME_S2C_MSG)
_M.EnterGame_C2S_Msg = protobuf.Message(_M.ENTERGAME_C2S_MSG)
_M.EnterGame_S2C_Msg = protobuf.Message(_M.ENTERGAME_S2C_MSG)
_M.ForceOffline_S2C_Msg = protobuf.Message(_M.FORCEOFFLINE_S2C_MSG)
_M.Login_C2S_Msg = protobuf.Message(_M.LOGIN_C2S_MSG)
_M.Login_S2C_Msg = protobuf.Message(_M.LOGIN_S2C_MSG)
_M.RandomName_C2S_Msg = protobuf.Message(_M.RANDOMNAME_C2S_MSG)
_M.RandomName_S2C_Msg = protobuf.Message(_M.RANDOMNAME_S2C_MSG)
_M.Regist_C2S_Msg = protobuf.Message(_M.REGIST_C2S_MSG)
_M.Regist_S2C_Msg = protobuf.Message(_M.REGIST_S2C_MSG)

return _M