using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

namespace XC.CsIO
{
    public class Connector : ICallback
    {
        public void OnConnected()
        {
            Debug.Log("OnConnected");
            LuaScriptMgr.Instance.CallLuaFunction("LoginUICtrl.OnConnnected");
        }

        public void OnChallenage(Linker linker)
        {
            linker.Response();
        }

        public void OnAuthOk(long userid)
        {
            LuaScriptMgr.Instance.CallLuaFunction("LuaProtocolManager.OnAuthOK", userid);
        }

        public void OnAuthError(AuthError error, int code, Exception detail)
        {
            Debug.LogWarning(string.Format("AuthError error = {0}, code = {1},detail = {2}", error,
                (NetExceptionCode) code, detail.Message));
            NetManager.GetInstance().needNewLinker = true;
            LuaScriptMgr.Instance.CallLuaFunction("LuaProtocolManager.OnAuthError", error.ToString(), code);
        }

        public void DiscardSendProtocol(DiscardError error, IProtocol proto)
        {
        }

        public void DiscardSendProtocol(DiscardError error, OctetsStream proto)
        {
        }

        public void BeforeSendProtocol(IProtocol proto)
        {
        }

        public void BeforeProcessProtocol(IProtocol proto)
        {
        }
    }
}