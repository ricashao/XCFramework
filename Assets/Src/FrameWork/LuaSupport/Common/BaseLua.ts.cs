using System.Collections;
using UnityEngine;

public class BaseLua : MonoBehaviour
{
    private string data = null;
    private bool initialize = false;
    private Transform trans = null;
    private LuaScriptMgr _umgr = null;
    private Hashtable buttons = new Hashtable();
    private Hashtable children = new Hashtable();
    
    protected LuaScriptMgr uluaScriptMgr {
        get {
            if (_umgr == null)
            {
                _umgr = ioo.gameMain.uluaMgr;
            }
            return _umgr;
        }
    }
    
    
    protected void Awake()
    {
        CallMethod("Awake");
    }
    
    //-----------------------------------------------
    /// <summary>
    /// 执行Lua方法-无参数
    /// </summary>
    protected object[] CallMethod(string func) {
        if (uluaScriptMgr == null) return null;
        string funcName = name + "." + func;
        funcName = funcName.Replace("(Clone)", "");
        return _umgr.CallLuaFunction(funcName);
    }
}