using UnityEngine;

public class GameMain : BaseLua
{
    
    public LuaScriptMgr xluaMgr;

//    private InputTouch inputTouch; 
    protected new void Awake()
    {
        Init();
        base.Awake();
    }


    void Init()
    {
        DontDestroyOnLoad(gameObject);
        Util.Add<PanelManager>(gameObject);
//        Util.Add<TimerManager>(gameObject);
//        Util.Add<FileLogger>(gameObject);
//        // Util.Add<ResManager>(gameObject);
        Util.Add<AssetManager>(gameObject);
        Util.Add<PoolManager>(gameObject);
        Util.Add<ImageSetManager>(gameObject);
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        Application.targetFrameRate = Const.GameFrameRate;


        xluaMgr = new LuaScriptMgr();
        xluaMgr.Start();
        xluaMgr.DoFile("GameMain"); //GameMain.lua
//        checkLuaDebug();
        CallMethod("LoginGame");

//        inputTouch = new InputTouch ();

//        LuaScriptMgr.Instance.CallLuaFunction("TouchProxy.SetTouch", inputTouch);
    }
}