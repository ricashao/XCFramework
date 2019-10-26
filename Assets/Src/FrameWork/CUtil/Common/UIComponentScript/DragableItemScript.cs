using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class DragableItemScript : MonoBehaviour, IDragHandler
{
    private float _angle = 0.0f;
    private float _ratio = 1.0f;
    
    public void OnDrag(PointerEventData eventData)
    {
        _angle = -eventData.delta.x * _ratio;
        CallMethod(_angle);
    }
    
    private void CallMethod(float angle)
    {
        string funName = name + ".OnRotationChanged";
        LuaScriptMgr.Instance.CallLuaFunction(funName, _angle);
    }
}
