namespace XC.CsIO
{
    public interface IProtocol : IMarshal
    {
        int ProtocolType { get; }

        void Process(Linker linker);
    }
}
