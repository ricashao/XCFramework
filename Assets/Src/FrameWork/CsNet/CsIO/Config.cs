namespace XC.CsIO
{
    public class Config
    {
        public string Host { get; private set; }

        public int Port { get; private set; }

        public int KeepaliveTimeout { get; private set; }

        public Coder Coder { get; private set; }

        public int OutputBufferSize { get; private set; }

        public int ReceiveBufferSize { get; private set; }

        public int SendBufferSize { get; private set; }


        public Config( string host, int port, int keepaliveTimeout, Coder coder, int receiveBufferSize, int sendBufferSize, int outputBufferSize)
        {
            Host = host;
            Port = port;
            KeepaliveTimeout = keepaliveTimeout;
            Coder = coder;
            ReceiveBufferSize = receiveBufferSize;
            SendBufferSize = sendBufferSize;
            OutputBufferSize = outputBufferSize;
        }
    }
}
