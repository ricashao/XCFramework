using System;

namespace Networks
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
    }
}