using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.UI;

public class GameComponentClick : MonoBehaviour
{
    private LuaScriptMgr umgr = null;
    private Transform trans = null;
    private Hashtable children = new Hashtable();
    private Hashtable buttons = new Hashtable();
    private String cKey_ = "";

    protected LuaScriptMgr uluaMgr
    {
        get
        {
            if (umgr == null)
            {
                umgr = ioo.gameMain.xluaMgr;
            }
            return umgr;
        }
    }

    public String cKey
    {
        get { return cKey_;  }
        set { cKey_ = value;  }
    }

    protected void Start()
    {
        trans = transform;
        MapUIChildren();
        AddClick();
    }

    public void AddClick()
    {
        foreach (DictionaryEntry t in children)
        {
            var go = t.Value as GameObject;
            if (go == null) continue;
            var btn = go.GetComponent<Button>();
            if (null != btn)
            {
                if (buttons.ContainsKey(btn.name))
                {
                    Debugger.LogError(name + " add GameUIClickEvent Error");

                }
                else
                {
                    buttons.Add(btn.name, go);
                    btn.onClick.AddListener(() => OnClickEvent(go));
                }
            }
        }
    }

    public void MapUIChildren()
    {
        children.Clear();
        var srcchildren = trans.GetComponentsInChildren<Transform>();
        foreach (var child in srcchildren)
        {
            if (child.name.Contains("btn"))
            {
                if (children.ContainsKey(child.name))
                {
                    Debugger.LogError(name + " add GameUIClickEvent Error");
                }
                else
                {
                    children.Add(child.name, child.gameObject);
                }
               
            }
        }
    }

    protected void OnClickEvent(GameObject go)
    {
        CallMethod("OnClick", go);
    }
    /// <summary>
    /// 移除单击事件
    /// </summary>
    public void RemoveClick(string button)
    {
        object o = buttons[button];
        if (o == null) return;
        GameObject go = o as GameObject;
    }

    /// <summary>
    /// 清除单击事件
    /// </summary>
    public void ClearClick()
    {
        foreach (DictionaryEntry de in buttons)
        {
            RemoveClick(de.Key.ToString());
        }
    }
        /// <summary>
    /// 执行Lua方法
    /// </summary>
    protected object[] CallMethod(string func, GameObject go)
    {
        if (uluaMgr == null) return null;
        return umgr.CallLuaFunction("GameUIClickEvent.OnClickCallFromCS", name, cKey_, go);

    }

    //-----------------------------------------------------------------
    protected void OnDestroy()
    {
        if (ioo.gameMain != null && ioo.gameMain.xluaMgr != null)//此时umgr有可能是空值
        {
            ioo.gameMain.xluaMgr.CallLuaFunction("GameUIClickEvent.OnDestroyComponent", cKey_);
        }
        
        ClearClick();
        umgr = null;
    }
}