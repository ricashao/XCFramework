using System;
using System.Collections.Generic;


namespace XC.CsIO
{
    public sealed partial class Coder
    {
        private class Stub
        {
            private readonly int _size;
            private readonly Type _type;

            internal Stub(int size, Type type)
            {
                _size = size;
                _type = type;
            }

            internal bool Check(int sz)
            {
                return _size <= 0 || sz <= _size;
            }

            internal IProtocol CreateProtocol()
            {
                return (IProtocol) Activator.CreateInstance(_type);
            }
        }

        private readonly Dictionary<int, Stub> _stubmap = new Dictionary<int, Stub>();

        public void Register(int type, int size, Type clazz)
        {
            _stubmap.Add(type, new Stub(size, clazz));
        }

        internal enum Code
        {
            Ok,
            TypeUnknown,
            SizeExceed,
        }

        internal Code EncodeRaw(OctetsStream os, IProtocol proto)
        {
            var type = proto.ProtocolType;

            Stub stub;
            if (!_stubmap.TryGetValue(type, out stub))
                return Code.TypeUnknown;

            proto.Marshal(os);

            if (!stub.Check(os.Data.Count))
                return Code.SizeExceed;

            return Code.Ok;
        }


        internal Code Encode(OctetsStream os, IProtocol proto)
        {
            var type = proto.ProtocolType;

            Stub stub;
            if (!_stubmap.TryGetValue(type, out stub))
                return Code.TypeUnknown;

            var tmp = new OctetsStream();
            proto.Marshal(tmp);
            int size = tmp.Data.Count;

            if (!stub.Check(size))
                return Code.SizeExceed;

            os.MarshalSize(type).Marshal(tmp.Data);
            return Code.Ok;
        }


        internal void Decode(Queue<IProtocol> protocols, OctetsStream os)
        {
            while (os.Remaining > 0)
            {
                int tranpos = os.Begin();
                try
                {
                    int size = os.UnmarshalSize();
                    int type = os.UnmarshalSize();
                    int code = os.UnmarshalSize();

                    if (size > os.Remaining)
                    {
                        os.RollBack(tranpos);
                        break; // not enough
                    }

                    Stub stub;
                    if (_stubmap.TryGetValue(type, out stub))
                    {
                        int startpos = os.Position;
                        IProtocol p = stub.CreateProtocol();
                        try
                        {
                            p.Unmarshal(os);
                        }
                        catch (MarshalException e)
                        {
                            throw new CodecException("State.decode (" + type + ", " + size + ")", e);
                        }

                        protocols.Enqueue(p);

                        if ((os.Position - startpos) != size)
                            throw new CodecException("State.decode(" + type + ", " + size + ")=" +
                                                     (os.Position - startpos));
                    }
                    else
                    {
                        protocols.Enqueue(new LuaProtocol
                            {type = type, code = code, data = new Octets(os.Data, os.Position, size)});
                        os.RollTo(os.Position + size);
                    }
                }
                catch (MarshalException)
                {
                    os.RollBack(tranpos);
                    break;
                }
            }
        }
    }
}