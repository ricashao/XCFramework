using System;
using System.Collections.Generic;
using CustomDataStruct;
using WebSocketSharp;

namespace Networks
{
    public class WsNetwork
    {
        public Action<object, int, string> OnConnect = null;
        public Action<object, int, string> OnClosed = null;
        public Action<byte[]> ReceivePkgHandle = null;

        private List<HjNetworkEvt> mNetworkEvtList = null;
        private object mNetworkEvtLock = null;


        protected WebSocket mClientSocket = null;
        protected string mIp;
        protected int mPort;
        protected volatile SOCKSTAT mStatus = SOCKSTAT.CLOSED;


        protected IMessageQueue mReceiveMsgQueue = null;
        private List<byte[]> mTempMsgList = null;

        public WsNetwork()
        {
            mStatus = SOCKSTAT.CLOSED;

            mNetworkEvtList = new List<HjNetworkEvt>();
            mNetworkEvtLock = new object();
            mReceiveMsgQueue = new MessageQueue();
            mTempMsgList = new List<byte[]>();
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
                        mReceiveMsgQueue.Add(e.RawData);
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

                mStatus = SOCKSTAT.CONNECTING;
                mClientSocket.Connect();
            }
            catch (Exception e)
            {
                UnityEngine.Debug.Log(e);
            }
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
            StartAllThread();
            mStatus = SOCKSTAT.CONNECTED;
            ReportSocketConnected(ESocketError.NORMAL, "Connect successfully");
        }

        public virtual void StartAllThread()
        {
        }

        protected virtual void DoClose()
        {
            mClientSocket.Close();
            if (mClientSocket.IsConnected)
            {
                throw new InvalidOperationException("Should close socket first!");
            }

            mClientSocket = null;
            StopAllThread();
        }

        public virtual void StopAllThread()
        {
            //清除接受队列
            mReceiveMsgQueue.Dispose();
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
            UpdatePacket();
            UpdateEvt();
        }

        private void UpdatePacket()
        {
            if (!mReceiveMsgQueue.Empty())
            {
                mReceiveMsgQueue.MoveTo(mTempMsgList);

                try
                {
                    for (int i = 0; i < mTempMsgList.Count; ++i)
                    {
                        var objMsg = mTempMsgList[i];
                        if (ReceivePkgHandle != null)
                        {
                            ReceivePkgHandle(objMsg);
                        }
                    }
                }
                catch (Exception e)
                {
                    Logger.LogError("Got the fucking exception :" + e.Message);
                }
                finally
                {
                    for (int i = 0; i < mTempMsgList.Count; ++i)
                    {
                        StreamBufferPool.RecycleBuffer(mTempMsgList[i]);
                    }

                    mTempMsgList.Clear();
                }
            }
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
#if LOG_SEND_BYTES
            var sb = new System.Text.StringBuilder();
            for (int i = 0; i < msgObj.Length; i++)
            {
                sb.AppendFormat("{0}\t", msgObj[i]);
            }
            Logger.Log("HjTcpNetwork send bytes : " + sb.ToString());
#endif

            this.ClientSocket.Send(msgObj);
        }

        public bool IsConnect()
        {
            return mStatus == SOCKSTAT.CONNECTED;
        }
    }
}