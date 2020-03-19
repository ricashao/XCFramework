using System;

namespace XC.CsIO
{
    public class LuaProtocol : IProtocol
    {
        public int type;
        public Octets data;
        public int code;

        public OctetsStream Marshal(OctetsStream os)
        {
            return null;
        }

        public OctetsStream Unmarshal(OctetsStream os)
        {
            return null;
        }

        public int ProtocolType { get; private set; }
        public void Process(Linker linker)
        {
            Coder.CurLuaType = ProtocolType;
            LuaScriptMgr.Instance.CallLuaFunction("LuaProtocolManager.Dispatch", this);                  
        }
    }
}