using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class TouchScreen
{
    private const float MIN_TIME = 0.5f;
    private float _currentTouchTime = 0.0f;

    Camera rayCamera = Camera.main;

    public void SetRayCamera(Camera rayCamera)
    {
        this.rayCamera = rayCamera;
    }

    public void Dispose()
    {
        //throw new System.NotImplementedException();
    }

    //在InputTouch中触发
    public void Tick(float deltaTime)
    {
        if (Input.GetMouseButtonDown(0))
        {
            CallLuaFunction();
            _currentTouchTime = 0.0f;
        }
        else if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Moved)
        {
            _currentTouchTime += deltaTime;
            if (_currentTouchTime > MIN_TIME)
            {
                _currentTouchTime = 0.0f;
                CallLuaFunction();
            }
        }
        else
        {
            _currentTouchTime = 0.0f;
        }

        if (Input.GetMouseButtonUp(0))
        {
            LuaScriptMgr.Instance.CallLuaFunction("TouchAgent.SetTouchButtonState", true);
        }
        else if (Input.GetMouseButtonDown(0))
        {
            LuaScriptMgr.Instance.CallLuaFunction("TouchAgent.SetTouchButtonState", false);
        }
    }

    private bool HitUI(Vector3 mousePos)
    {
        var eventDataCurrentPosition = new PointerEventData(EventSystem.current)
        {
            position = new Vector2(mousePos.x, mousePos.y)
        };

        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);
        return results.Count > 0;
    }

    private void CallLuaFunction()
    {
        var ray = rayCamera.ScreenPointToRay(Input.mousePosition);
        RaycastHit[] hitInfo = UnityEngine.Physics.RaycastAll(ray);
        if (hitInfo != null && hitInfo.Length > 0)
        {
            LuaScriptMgr.Instance.CallLuaFunction("TouchAgent.OnTouchScreen", Input.mousePosition);

            if (!HitUI(Input.mousePosition))
            {
                LuaScriptMgr.Instance.CallLuaFunction("TouchAgent.OnTouch", hitInfo);
            }
        }
    }
}