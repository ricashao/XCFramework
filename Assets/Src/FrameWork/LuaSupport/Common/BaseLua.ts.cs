using System.Collections;
using UnityEngine;
using UnityEngine.UI;

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
                _umgr = ioo.gameMain.xluaMgr;
            }
            return _umgr;
        }
    }
    
    
    protected void Awake()
    {
        CallMethod("Awake");
    }
    
    
    protected void Start() {
        trans = transform;
//        if(trans.CompareTag("UI"))
//            MapUIChildren();
        CallMethod("Start");
    }

//    protected void OnClick() {
//        CallMethod("OnClick");
//    }
//
//    protected void OnClickEvent(GameObject go) {
//        CallMethod("OnClick", go);
//    }

    /// <summary>
    /// 添加单击事件
    /// </summary>
//    public void AddClick(string button) {
//        var go = children[button] as GameObject;
//        if (null == go)
//        {
//            var to = trans.Find(button);
//            if (to == null)
//                return;
//            go = to.gameObject;     
//        }
//        buttons.Add(button, go);
//        var btn = go.GetComponent<Button>();
//        if (null != btn)
//        {
//            btn.onClick.AddListener(
//                () => OnClickEvent(go));
//        }
//    }

    /// <summary>
    /// 移除单击事件
    /// </summary>
//    public void RemoveClick(string button) {
//        object o = buttons[button];
//        if (o == null) return;
//        GameObject go = o as GameObject;
//    }

    /// <summary>
    /// 清除单击事件
    /// </summary>
//    public void ClearClick() {
//        foreach (DictionaryEntry de in buttons) {
//            RemoveClick(de.Key.ToString());
//        }
//    }

    /// <summary>
    ///缓存UI子物体
    /// </summary>
//    public void MapUIChildren()
//    {
//        children.Clear();
//        var srcchildren = trans.GetComponentsInChildren<Transform>();
//        foreach (var child in srcchildren)
//        {         
//            if(!child.CompareTag("UIEvent")||children.ContainsKey(child.name))
//                continue;
//            children.Add(child.name,child.gameObject);
//        }
//    }

    
    
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
    
    

    /// <summary>
    /// 执行Lua方法
    /// </summary>
    protected object[] CallMethod(string func, GameObject go) {
        if (uluaScriptMgr == null) return null;
        string funcName = name + "." + func;
        funcName = funcName.Replace("(Clone)", "");
        return _umgr.CallLuaFunction(funcName, go);
    }

    /// <summary>
    /// 执行Lua方法-Socket消息
    /// </summary>
//    protected object[] CallMethod(string func, int key, ByteBuffer buffer) {
//        if (uluaScriptMgr == null) return null;
//        string funcName = "Network." + func;
//        funcName = funcName.Replace("(Clone)", "");
//        return _umgr.CallLuaFunction(funcName, key, buffer);
//    }

    //-----------------------------------------------------------------
    protected void OnDestroy() {
//        ClearClick();
        _umgr = null; 
        Debug.Log("~" + name + " was destroy!");
    }
}