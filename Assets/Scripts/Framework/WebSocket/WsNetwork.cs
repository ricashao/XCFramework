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


        private StreamBuffer receiveStreamBuffer;
        protected IMessageQueue mReceiveMsgQueue = null;
        private int bufferCurLen = 0;
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
                        int bufferLeftLen = receiveStreamBuffer.size - bufferCurLen;
                        receiveStreamBuffer.CopyFrom(e.RawData, 0, 0, e.RawData.Length);
                        bufferCurLen += e.RawData.Length;
                        DoReceive(receiveStreamBuffer, ref bufferCurLen);
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

        protected void DoReceive(StreamBuffer streamBuffer, ref int bufferCurLen)
        {
            try
            {
                // 组包、拆包
                byte[] data = streamBuffer.GetBuffer();
                int start = 0;
                streamBuffer.ResetStream();
                while (true)
                {
                    if (bufferCurLen - start < sizeof(int) * 3)
                    {
                        break;
                    }

                    int msgLen = BitConverter.ToInt32(data, start);
                    if (bufferCurLen < msgLen + sizeof(int))
                    {
                        break;
                    }

                    // 提取字节流，去掉开头表示长度的4字节
                    start += sizeof(int);
                    //协议号+code+数据
                    var bytes = streamBuffer.ToArray(start, msgLen - sizeof(int));
                    mReceiveMsgQueue.Add(bytes);
                    // 下一次组包
                    start += msgLen - sizeof(int);
                }

                if (start > 0)
                {
                    bufferCurLen -= start;
                    streamBuffer.CopyFrom(data, start, 0, bufferCurLen);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(string.Format("Tcp receive package err : {0}\n {1}", ex.Message, ex.StackTrace));
            }
        }

       

        public void Connect()
        {
            Close();

            int result = ESocketError.NORMAL;
            string msg = null;
            try
            {
                receiveStreamBuffer = StreamBufferPool.GetStream(1024 * 1024 * 2, false, true);
                bufferCurLen = 0;
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
        }

        public bool IsConnect()
        {
            return mStatus == SOCKSTAT.CONNECTED;
        }
    }
}