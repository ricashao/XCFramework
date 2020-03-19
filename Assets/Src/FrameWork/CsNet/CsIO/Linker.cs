using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Timers;
using WebSocketSharp;

namespace XC.CsIO
{
    //Action, ConcurrentQueue for .net 2.0  
    internal delegate void Action();

    internal sealed class ConcurrentQueue<T>
    {
        private readonly Queue<T> _inner = new Queue<T>();
        private readonly object _obj = new object();

        public int Count
        {
            get
            {
                lock (_obj)
                {
                    return _inner.Count;
                }
            }
        }

        public bool TryDequeue(out T item)
        {
            lock (_obj)
            {
                if (_inner.Count == 0)
                {
                    item = default(T);
                    return false;
                }

                item = _inner.Dequeue();
                return true;
            }
        }

        public void Enqueue(T item)
        {
            lock (_obj)
            {
                _inner.Enqueue(item);
            }
        }

        public void Clear()
        {
            lock (_obj)
            {
                _inner.Clear();
            }
        }
    }

    public sealed class Linker
    {
        private const int InputSize = 65535;
        private const int ReserveInputBufSize = 8192;
        private const int ReserveOutputBufSize = 1024;
        private readonly ConcurrentQueue<Action> _actions = new ConcurrentQueue<Action>();
        private readonly Stopwatch _frameWatcher = new Stopwatch();
        private readonly byte[] _input = new byte[InputSize];

        private readonly Octets _inputBuf = new Octets(ReserveInputBufSize);
        private readonly Stopwatch _keepaliveWatcher = new Stopwatch();
        private readonly Octets _outputBuf = new Octets(ReserveOutputBufSize);
        private readonly Queue<IProtocol> _protocols = new Queue<IProtocol>();

        private readonly Stopwatch _reconnectWatcher = new Stopwatch();


        private bool _autoReconnect;
        private int _reconnectDelay;
        private int _reconnectDelayMax = 60000;
        private int _reconnectDelayMin = 1000;
        private static WebSocket _socket;
        private bool _startKeepalive;
        private bool _startReconnect;
        
        
        public string Token;
        public string Username;
        public string Deviceid;
        public string Os;
        public string Platform;


        private static Timer heartbeatTimer;
        public const double HEARTBEAT_INTERVAL_MSEC = 50000d;


        public Linker(Config config, ICallback callback)
        {
            Config = config;
            Callback = callback;
        }

        public Config Config { get; private set; }

        public ICallback Callback { get; private set; }

        public bool Connected
        {
            get { return null != _socket && _socket.IsConnected; }
        }


        public bool AutoReconnect
        {
            get { return _autoReconnect; }
            set
            {
                _autoReconnect = value;
                if (_autoReconnect)
                {
                    if (!Connected)
                    {
                        _reconnectDelay = 0;
                        _startReconnect = true;
                        _reconnectWatcher.Reset();
                        _reconnectWatcher.Start();
                    }
                }
                else
                {
                    _startReconnect = false;
                }
            }
        }

        public void Connect()
        {
            if (_socket != null)
                return;
            try
            {
                _socket = new WebSocket("ws://127.0.0.1:10002/websocket");
                _socket.OnMessage += (sender, e) =>
                {
                    if (e.IsBinary)
                    {
                        _inputBuf.Append(e.RawData);
                        var os = new OctetsStream(_inputBuf);
                        Config.Coder.Decode(_protocols, os);
                        if (os.Position != 0)
                        {
                            _inputBuf.EraseAndCompact(os.Position, ReserveInputBufSize);
                        }
                    }
                    else
                        UnityEngine.Debug.Log("收到非二进制数据");
                };
                _socket.OnOpen += (sender, e) =>
                {
                    UnityEngine.Debug.Log("连接成功");
                    // 开启定时心跳计时器，避免长时间空闲被服务器踢下线
                    if (heartbeatTimer != null)
                    {
                        heartbeatTimer.Close();
                        heartbeatTimer = null;
                    }

                    if (HEARTBEAT_INTERVAL_MSEC > 0)
                    {
                        heartbeatTimer = new Timer(HEARTBEAT_INTERVAL_MSEC);
                        heartbeatTimer.Elapsed += new ElapsedEventHandler(OnHeartbeatTimer);
                        heartbeatTimer.AutoReset = true;
                        heartbeatTimer.Enabled = true;
                    }

//                    foreach (var hander in connectionOpenHandlerSet)
//                        hander(e);
                };
                _socket.OnError += (sender, e) =>
                {
                    UnityEngine.Debug.Log("发生错误：" + e.Message);
//                    foreach (var hander in connectionErrorHandlerSet)
//                        hander(e);
                };
                _socket.OnClose += (sender, e) =>
                {
                    UnityEngine.Debug.Log("连接关闭");
                    if (heartbeatTimer != null)
                    {
                        heartbeatTimer.Close();
                        heartbeatTimer = null;
                    }

//                    foreach (var hander in connectionCloseHandlerSet)
//                        hander(e);
                };

                _socket.Connect();
            }
            catch (Exception e)
            {
                UnityEngine.Debug.Log(e);
//                Close(_socket, NetExceptionCode.Connect, e);
            }
        }

        private void Close(WebSocket sock, NetExceptionCode code, Exception e)
        {
            if (sock != _socket) //socket.close后仍然有可能会有系统回调向_actions里塞。这时我们要Close的时候对比一下。
            {
                return;
            }


            Callback.OnAuthError(AuthError.NetException, (int) code, e);

            Close();

            if (_autoReconnect)
            {
                if (_reconnectDelay == 0)
                {
                    _reconnectDelay = _reconnectDelayMin;
                }
                else
                {
                    _reconnectDelay *= 2;
                    if (_reconnectDelay > _reconnectDelayMax)
                        _reconnectDelay = _reconnectDelayMax;
                }

                _startReconnect = true;
                _reconnectWatcher.Reset();
                _reconnectWatcher.Start();
            }
        }

        public void Close()
        {
            foreach (IProtocol p in _protocols)
            {
                p.Process(this);
            }

            _protocols.Clear();

            if (_socket != null)
            {
                _socket.Close();
                _socket = null;
            }

            _actions.Clear();

            _startReconnect = false;
            _startKeepalive = false;

            _inputBuf.Clear();
            _outputBuf.Clear();
//            _inputSecurity = NullSecurity.Instance;
//            _outputSecurity = NullSecurity.Instance;
        }

        public void Process(long maxMilliseconds) // throws CodecException
        {
            _frameWatcher.Reset();
            _frameWatcher.Start();
            if (_startReconnect && _reconnectWatcher.ElapsedMilliseconds >= _reconnectDelay)
            {
                Connect();
            }
//            if (_startKeepalive && _keepaliveWatcher.ElapsedMilliseconds >= Config.KeepaliveTimeout)
//            {
//                SendProtocol(new KeepAlive((int)Utils.CurrentTimeMillis()));
//            }

            while (_frameWatcher.ElapsedMilliseconds < maxMilliseconds)
            {
                if (_protocols.Count > 0)
                {
                    IProtocol p = _protocols.Dequeue();
                    Callback.BeforeProcessProtocol(p);
                    p.Process(this);
                }
                else
                {
                    break;
                }
            }

            while (_frameWatcher.ElapsedMilliseconds < maxMilliseconds)
            {
                Action action;
                if (_actions.TryDequeue(out action))
                {
                    action();
                }
                else
                {
                    break;
                }
            }
        }
        
        public void Response()
        {
//            var res = new Response();
//            res.identity.Replace(Encoding.UTF8.GetBytes(Username));
//            res.response.Replace(Encoding.UTF8.GetBytes(Token));
//            res.logintype = 1;
//            res.mid.Replace(Encoding.UTF8.GetBytes(Deviceid));
//            res.reserved1 = 0;
//            res.reserved2 = new Octets();
////             res.os.Replace(Encoding.UTF8.GetBytes(Os));
////             res.platform.Replace(Encoding.UTF8.GetBytes(Platform));
//            SendProtocol(res);
        }


        private void OnHeartbeatTimer(object sender, ElapsedEventArgs e)
        {
            // ws.IsAlive的源码实现就是向服务器发Ping
            if (_socket.IsAlive == false)
            {
                Debug.WriteLine("发心跳时检测到与服务器连接中断");
                if (heartbeatTimer != null)
                {
                    heartbeatTimer.Close();
                    heartbeatTimer = null;
                }

                _socket.Close();
            }
        }
    }
}