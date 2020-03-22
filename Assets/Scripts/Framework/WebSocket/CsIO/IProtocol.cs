namespace Networks
{
    public interface IProtocol : IMarshal
    {
        int ProtocolType { get; }

    }
}
