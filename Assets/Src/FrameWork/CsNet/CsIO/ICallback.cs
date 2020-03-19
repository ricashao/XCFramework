namespace XC.CsIO
{
    public enum AuthError
    {
        NetException,
        Server,
    }

    public enum NetExceptionCode
    {
        Connect,
        Receive,
        Send,
    }

    public enum DiscardError
    {
        TypeUnregister,
        ProtocolSizeExceed,
        NetUnconnected,
        OutputBufferExceed,
    }


    public interface ICallback
    {
        void OnConnected();

        void OnChallenage(Linker linker); //1,call Linker.Response(); 2,set config, call Linker.Response(); 3,get info, Linker.close(); 

        void OnAuthOk(long userid);

        void OnAuthError(AuthError error, int code, System.Exception detail); //调用完这个，会自动close连接的。如果error是NetException会触发自动重练，如果是Server则不会触发自动重练。


        void BeforeSendProtocol(IProtocol proto);

        void BeforeProcessProtocol(IProtocol proto);

        void DiscardSendProtocol(DiscardError error, IProtocol proto);
        void DiscardSendProtocol(DiscardError error, OctetsStream proto);
    }
}
