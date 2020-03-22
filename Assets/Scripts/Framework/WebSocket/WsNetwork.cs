using System;
using System.Collections.Generic;
using WebSocketSharp;

namespace Networks
{
    public class WsNetwork
    {
        public Action<object, int, string> OnConnect = null;
        public Action<object, int, string> OnClosed = null;
        public Action<IProtocol> ReceivePkgHandle = null;

        private List<HjNetworkEvt> mNetworkEvtList = null;
        private object mNetworkEvtLock = null;


        protected WebSocket mClientSocket = null;
        protected string mIp;
        protected int mPort;
        protected volatile SOCKSTAT mStatus = SOCKSTAT.CLOSED;


        private const int ReserveInputBufSize = 8192;
        private readonly Octets _inputBuf = new Octets(ReserveInputBufSize);
        private readonly Queue<IProtocol> _protocols = new Queue<IProtocol>();

        public WsNetwork()
        {
            mStatus = SOCKSTAT.CLOSED;

            mNetworkEvtList = new List<HjNetworkEvt>();
            mNetworkEvtLock = new object();
        }

        public virtual void Dispose()
        {
            Close();
        }

        public WebSocket ClientSocket
        {
            get { return mClientSocket; }
        }

        public void SetHostPort(string ip, int port)
        {
            mIp = ip;
            mPort = port;
        }

        protected void DoConnect()
        {
            if (mClientSocket != null)
                return;

            try
            {
                String newServer = string.Format("ws://{0}:{1}/websocket", mIp, mPort);
                mClientSocket = new WebSocket(newServer);
                mClientSocket.OnMessage += (sender, e) =>
                {
                    if (e.IsBinary)
                    {
                        _inputBuf.Append(e.RawData);
                        var os = new OctetsStream(_inputBuf);
                        var protocol = Decode(_protocols, os);
                        if (protocol != null)
                        {
                            ReceivePkgHandle(protocol);
                        }

                        if (os.Position != 0)
                        {
                            _inputBuf.EraseAndCompact(os.Position, ReserveInputBufSize);
                        }
                    }
                    else
                        UnityEngine.Debug.Log("收到非二进制数据");
                };
                mClientSocket.OnOpen += (sender, e) =>
                {
                    UnityEngine.Debug.Log("连接成功");
                    OnConnected();
                };
                mClientSocket.OnError += (sender, e) =>
                {
                    mStatus = SOCKSTAT.CLOSED;
                    UnityEngine.Debug.Log("发生错误：" + e.Message);
                };
                mClientSocket.OnClose += (sender, e) =>
                {
                    mStatus = SOCKSTAT.CLOSED;
                    UnityEngine.Debug.Log("连接关闭");
                };

                mClientSocket.Connect();
                mStatus = SOCKSTAT.CONNECTING;
            }
            catch (Exception e)
            {
                UnityEngine.Debug.Log(e);
            }
        }

        internal IProtocol Decode(Queue<IProtocol> protocols, OctetsStream os)
        {
            while (os.Remaining > 0)
            {
                int tranpos = os.Begin();
                try
                {
                    int size = os.UnmarshalSize();
                    int type = os.UnmarshalSize();
                    int code = os.UnmarshalSize();

                    if (size - 12 > os.Remaining)
                    {
                        os.RollBack(tranpos);
                        break; // not enough
                    }

                    var protocol = new LuaProtocol
                        {type = type, code = code, data = new Octets(os.Data, os.Position, size)};
                    os.RollTo(os.Position + size - 12);
                    return protocol;
                }
                catch (MarshalException)
                {
                    os.RollBack(tranpos);
                    break;
                }
            }

            return null;
        }

        public void Connect()
        {
            Close();

            int result = ESocketError.NORMAL;
            string msg = null;
            try
            {
                DoConnect();
            }
            catch (ObjectDisposedException ex)
            {
                result = ESocketError.ERROR_3;
                msg = ex.Message;
                mStatus = SOCKSTAT.CLOSED;
            }
            catch (Exception ex)
            {
                result = ESocketError.ERROR_4;
                msg = ex.Message;
                mStatus = SOCKSTAT.CLOSED;
            }
            finally
            {
                if (result != ESocketError.NORMAL && OnConnect != null)
                {
                    ReportSocketConnected(result, msg);
                }
            }
        }

        protected virtual void OnConnected()
        {
            mStatus = SOCKSTAT.CONNECTED;
            ReportSocketConnected(ESocketError.NORMAL, "Connect successfully");
        }

        protected virtual void DoClose()
        {
            mClientSocket.Close();
            if (mClientSocket.IsConnected)
            {
                throw new InvalidOperationException("Should close socket first!");
            }

            mClientSocket = null;
        }

        public virtual void Close()
        {
            if (mClientSocket == null) return;

            mStatus = SOCKSTAT.CLOSED;
            try
            {
                DoClose();
                ReportSocketClosed(ESocketError.ERROR_5, "Disconnected!");
            }
            catch (Exception e)
            {
                ReportSocketClosed(ESocketError.ERROR_4, e.Message);
            }
        }

        protected void ReportSocketConnected(int result, string msg)
        {
            if (OnConnect != null)
            {
                AddNetworkEvt(new HjNetworkEvt(this, result, msg, OnConnect));
            }
        }

        protected void ReportSocketClosed(int result, string msg)
        {
            if (OnClosed != null)
            {
                AddNetworkEvt(new HjNetworkEvt(this, result, msg, OnClosed));
            }
        }


        protected void AddNetworkEvt(HjNetworkEvt evt)
        {
            lock (mNetworkEvtLock)
            {
                mNetworkEvtList.Add(evt);
            }
        }


        public void UpdateNetwork()
        {
            UpdateEvt();
        }


        private void UpdateEvt()
        {
            lock (mNetworkEvtLock)
            {
                try
                {
                    for (int i = 0; i < mNetworkEvtList.Count; ++i)
                    {
                        HjNetworkEvt evt = mNetworkEvtList[i];
                        evt.evtHandle(evt.sender, evt.result, evt.msg);
                    }
                }
                catch (Exception e)
                {
                    Logger.LogError("Got the fucking exception :" + e.Message);
                }
                finally
                {
                    mNetworkEvtList.Clear();
                }
            }
        }


        // 发送消息的时候要注意对buffer进行拷贝，网络层发送完毕以后会对buffer执行回收
        public virtual void SendMessage(byte[] msgObj)
        {
        }

        public bool IsConnect()
        {
            return mStatus == SOCKSTAT.CONNECTED;
        }
    }
}