using XC.CsIO;

namespace XC
{
    public class NetParam
    {
        public bool AutoReconnect = false;

        public string Deviceid = "aio.Test";
        //系统
        public string Os = "win";
        //平台
        public string Platform = "gaea";
        public int blockTick = 50;
        public string Host = "192.168.2.234";
        public int Port = 23000;
        public string token = "Token";
        public string userName = "username";

        public override bool Equals(object obj)
        {
            var param = obj as NetParam;
            return Host == param.Host && Port == param.Port && token == param.token && userName == param.userName;
        }
    }

    public sealed class NetManager : ITickable
    {
        private static NetManager _instance;

        public static NetManager Instance
        {
            get
            {
                if (null == _instance)
                {
                    _instance = new NetManager();
                }

                return _instance;
            }
        }
        
        private Linker linker;
        private NetParam param;
        private bool startConnected = false;
        private Coder coder;
        public bool needNewLinker;
        
        
        public bool Initialed { get; private set; }
        
        public static NetManager GetInstance()
        {
            return Instance;
        }
        
        public void SetParam(string host, int port, string userName, string password)
        {
            if (null == param ||
                !param.Equals(new NetParam {Host = host, Port = port, userName = userName, token = password}))
            {
                param = new NetParam {Host = host, Port = port, userName = userName, token = password};
                needNewLinker = linker != null;
            }

            if (null == coder)
            {
                coder = new Coder();
//                Coderaio.RegisterAll(coder);
            }

            if (needNewLinker)
            {
                linker.Close();
                linker = null;
            }

            if (null == linker)
            {
                var config = new Config(host, port, 15000, coder, 16384, 16384, 1024 * 128);
                linker = new Linker(config, new Connector())
                {
                    Username = param.userName,
                    Token = param.token,
                    AutoReconnect = param.AutoReconnect,
                    Deviceid = param.Deviceid,
                    Os = param.Os,
                    Platform = param.Platform,
                };
                Initialed = true;
            }
        }
        
        public void Connect()
        {
            startConnected = true;
            linker.Close();
            linker.Connect();   
        }
        
        public void Close()
        {
            if(linker != null)
                linker.Close();
        }


        public void Dispose()
        {
            
            Close();
            linker = null;
            param = null;
        }

        public void Tick(float deltaTime)
        {
            if (null != linker && startConnected)
                linker.Process(param.blockTick);
        }
    }
}