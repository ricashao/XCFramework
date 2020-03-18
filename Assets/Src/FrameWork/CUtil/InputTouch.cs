using UnityEngine;
using UnityEngine.EventSystems;

/// <summary>
/// 简单通用的组件
/// 支持编辑器模式，网页模式和移动端模式（移动端不支持多触点判断）
/// </summary>
public class InputTouch : ITickable
{
    public static bool IsMobilePlatform = true;
    private static string touchType = string.Empty;

    private const string TOUCH_DOWN = "OnTouchDown";
    private const string TOUCH_UP = "OnTouchUp";
    private const string TOUCH_DRAG_BEGIN = "OnTouchDragBegin";
    private const string TOUCH_DRAG = "OnTouchDrag";
    private const string TOUCH_DRAG_END = "OnTouchDragEnd";
    private const string TOUCH_CLICK = "OnTouchClick";
    private const string TOUCH_PRESS = "OnTouchPress";
    private const string TOUCH_PRESS_END = "OnTouchPressEnd";

    public delegate void FingerEventHandler(Finger finger);

    #region Event

    public static event FingerEventHandler OnTouchDown;
    public static event FingerEventHandler OnTouchUp;
    public static event FingerEventHandler OnTouchDragBegin;
    public static event FingerEventHandler OnTouchDrag;
    public static event FingerEventHandler OnTouchDragEnd;
    public static event FingerEventHandler OnTouchClick;
    public static event FingerEventHandler OnTouchPress;
    public static event FingerEventHandler OnTouchPressEnd;

    #endregion

    #region Raise Event

    internal static void RaiseTouchDown(Finger finger)
    {
        touchType = TOUCH_DOWN;
        CallLuaEventMethod(finger);

        if (OnTouchDown != null)
        {
            OnTouchDown(finger);
        }
    }

    internal static void RaiseTouchUp(Finger finger)
    {
        touchType = TOUCH_UP;
        CallLuaEventMethod(finger);

        if (OnTouchUp != null)
        {
            OnTouchUp(finger);
        }
    }

    internal static void RaiseTouchDragBegin(Finger finger)
    {
        touchType = TOUCH_DRAG_BEGIN;
        CallLuaEventMethod(finger);

        if (OnTouchDragBegin != null)
        {
            OnTouchDragBegin(finger);
        }
    }

    internal static void RaiseTouchDrag(Finger finger)
    {
        touchType = TOUCH_DRAG;
        CallLuaEventMethod(finger);

        if (OnTouchDrag != null)
        {
            OnTouchDrag(finger);
        }
    }

    internal static void RaiseTouchDragEnd(Finger finger)
    {
        touchType = TOUCH_DRAG_END;
        CallLuaEventMethod(finger);

        if (OnTouchDragEnd != null)
        {
            OnTouchDragEnd(finger);
        }
    }

    internal static void RaiseTouchClick(Finger finger)
    {
        touchType = TOUCH_CLICK;
        CallLuaEventMethod(finger);

        if (OnTouchClick != null)
        {
            OnTouchClick(finger);
        }
    }

    internal static void RaiseTouchPress(Finger finger)
    {
        touchType = TOUCH_PRESS;
        CallLuaEventMethod(finger);

        if (OnTouchPress != null)
        {
            OnTouchPress(finger);
        }
    }

    internal static void RaiseTouchPressEnd(Finger finger)
    {
        touchType = TOUCH_PRESS_END;
        CallLuaEventMethod(finger);

        if (OnTouchPressEnd != null)
        {
            OnTouchPressEnd(finger);
        }
    }

    internal static void CallLuaEventMethod(Finger finger)
    {
        if (finger == null || touchType == string.Empty)
        {
            return;
        }

        LuaScriptMgr.Instance.CallLuaFunction("TouchProxy." + touchType, finger);
        touchType = string.Empty;
    }

    #endregion

    private Finger finger = null;
    private Camera mainCamera = Camera.main;
    private TouchScreen touchScreen;

    public InputTouch()
    {
        IsMobilePlatform = Application.isMobilePlatform;
        finger = new Finger(mainCamera);
        touchScreen = new TouchScreen();
        LuaScriptMgr.Instance.CallLuaFunction("TouchAgent.SetScreenTouch", touchScreen);
    }

    public void SetCamera(Camera camera)
    {
        mainCamera = camera;
        if (finger != null)
        {
            finger.SetCamera(camera);
        }
    }

    public void Tick(float deltaTime)
    {
        if (finger != null)
        {
            finger.Tick();
            if (finger.CurrentSelectedGameObject == null)
            {
                touchScreen.Tick(deltaTime);
            }
        }
        else
        {
            touchScreen.Tick(deltaTime);
        }
    }

    public void Dispose()
    {
        touchScreen.Dispose();
        touchScreen = null;
    }

    #region Finger Class

    /// <summary>
    /// 手指判断类
    /// </summary>
    public class Finger
    {
        #region Field

        private Camera camera;

        private FingerPhase phase;

        private GameObject pickedGameObject;

        private GameObject currentSelectedGameObject;

        private RectTransform currentSelectedGameObjectRT;

        private bool isOverUI;

        private float startTime;

        private float holdTime;

        private Vector2 startPos;

        private Vector2 pos;

        private Vector2 endPos;

        private Vector2 deltaPos;

        private Vector2 fingerPos;

        private Vector2 fingerDeltaPos;

        private bool isDrag;

        private bool triggerPress;

        #endregion

        #region Property

        public GameObject PickedGameObject
        {
            get { return pickedGameObject; }
        }

        public GameObject CurrentSelectedGameObject
        {
            get { return currentSelectedGameObject; }
        }

        public bool IsOverUI
        {
            get { return isOverUI; }
        }

        public Vector2 Position
        {
            get { return pos; }
        }

        public Vector2 StartPosition
        {
            get { return startPos; }
        }

        public Vector2 EndPosition
        {
            get { return endPos; }
        }

        public Vector2 DeltaPosition
        {
            get { return deltaPos; }
        }

        public float HoldTime
        {
            get { return holdTime; }
        }

        #endregion

        #region Enum

        enum FingerPhase
        {
            None,

            Begin,

            Move,

            End
        }

        #endregion

        public Finger(Camera camera)
        {
            this.camera = camera;
            InitFinger();
        }

        public void SetCamera(Camera camera)
        {
            this.camera = camera;
        }

        public void Tick()
        {
            // 移动平台判断
            if (IsMobilePlatform)
            {
                if (Input.touchCount <= 0)
                {
                    phase = FingerPhase.None;
                }
                else
                {
                    Touch touch = Input.GetTouch(0);

                    fingerPos = touch.position;
                    fingerDeltaPos = touch.deltaPosition;

                    if (touch.phase == TouchPhase.Began)
                    {
                        phase = FingerPhase.Begin;
                    }
                    else if (touch.phase == TouchPhase.Moved)
                    {
                        phase = FingerPhase.Move;
                    }
                    else if (touch.phase == TouchPhase.Ended)
                    {
                        phase = FingerPhase.End;
                    }
                }
            }
            // 非移动平台判断
            else
            {
                fingerPos = Input.mousePosition;
                fingerDeltaPos = new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));

                phase = FingerPhase.None;
                if (Input.GetMouseButtonDown(0))
                {
                    phase = FingerPhase.Begin;
                }
                else if (Input.GetMouseButton(0))
                {
                    phase = FingerPhase.Move;
                }
                else if (Input.GetMouseButtonUp(0))
                {
                    phase = FingerPhase.End;
                }
            }

            if (phase == FingerPhase.None)
            {
                return;
            }

            if (phase == FingerPhase.Begin)
            {
                isDrag = false;
                startPos = endPos = pos = fingerPos;
                startTime = Time.realtimeSinceStartup;

                GetPickedInfo();

                RaiseTouchDown(this);
            }
            else if (phase == FingerPhase.Move)
            {
                pos = fingerPos;
                deltaPos = fingerDeltaPos;

                if (!isDrag)
                {
                    if (deltaPos != Vector2.zero)
                    {
                        isDrag = true;
                        startPos = pos;
                        RaiseTouchDragBegin(this);
                    }

                    //触发按住事件，时间阀值为0.500000011920929秒
                    if (!triggerPress)
                    {
                        holdTime = Time.realtimeSinceStartup - startTime;
                        if ((double) holdTime > 0.500000011920929)
                        {
                            triggerPress = true;
                            RaiseTouchPress(this);
                        }
                    }
                }
                else
                {
                    RaiseTouchDrag(this);

                    // 拖动后，如果获取的UI跟按住时的不一样，长按结束
                    if (triggerPress
                        && currentSelectedGameObjectRT
                        && camera
                        && !RectTransformUtility.RectangleContainsScreenPoint(currentSelectedGameObjectRT, fingerPos,
                            camera))
                    {
                        triggerPress = false;
                        RaiseTouchPressEnd(this);
                    }
                }
            }
            else if (phase == FingerPhase.End)
            {
                endPos = fingerPos;
                RaiseTouchUp(this);

                holdTime = Time.realtimeSinceStartup - startTime;

                if (!isDrag)
                {
                    // 按住事件结束
                    if (triggerPress)
                    {
                        triggerPress = false;
                        RaiseTouchPressEnd(this);
                    }
                    else if ((double) holdTime < 0.300000011920929)
                    {
                        //触发点击事件，时间阀值为0.300000011920929秒，和UGUI的点击事件判断时间相同
                        RaiseTouchClick(this);
                    }
                }
                else
                {
                    isDrag = false;
                    RaiseTouchDragEnd(this);
                }

                InitFinger();
            }
        }

        private void InitFinger()
        {
            phase = FingerPhase.None;

            pickedGameObject = null;
            currentSelectedGameObject = null;
            currentSelectedGameObjectRT = null;
            isOverUI = false;

            startTime = holdTime = 0f;

            startPos = Vector2.zero;
            pos = Vector2.zero;
            endPos = Vector2.zero;
            deltaPos = Vector2.zero;
            fingerPos = Vector2.zero;
            fingerDeltaPos = Vector2.zero;

            isDrag = false;
            triggerPress = false;
        }

        private void GetPickedInfo()
        {
            pickedGameObject = RayCaster();

            isOverUI = !(IsMobilePlatform
                ? EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId)
                : EventSystem.current.IsPointerOverGameObject());

            currentSelectedGameObject = EventSystem.current.currentSelectedGameObject;
            if (currentSelectedGameObject)
            {
                currentSelectedGameObjectRT = currentSelectedGameObject.GetComponent<RectTransform>();
            }
        }

        private GameObject RayCaster()
        {
            GameObject go = null;
            RaycastHit hit;

            if (Application.isPlaying && camera)
            {
                Ray ray = camera.ScreenPointToRay(Input.mousePosition);
                if (Physics.Raycast(ray, out hit))
                {
                    go = hit.collider.gameObject;
                }
            }

            return go;
        }
    }

    #endregion
}