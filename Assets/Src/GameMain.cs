using UnityEngine;
using XC;

public class GameMain : BaseLua
{
    public LuaScriptMgr xluaMgr;

    private InputTouch inputTouch;

    protected new void Awake()
    {
        Init();
        base.Awake();
    }


    /// <summary>
    /// 程序入口 初始化
    /// </summary>
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
        CallMethod("LoginGame");

        inputTouch = new InputTouch();
        LuaScriptMgr.Instance.CallLuaFunction("TouchProxy.SetTouch", inputTouch);
        NetManager.GetInstance().SetParam("1", 2, "1", "1");
        NetManager.GetInstance().Connect();
    }


    /// <summary>
    /// 所有的update都走这边
    /// </summary>
    public void Update()
    {
        var delta = Time.deltaTime;
        CoroutineManager.Instance.Tick(delta);
        AudioManager.Instance.Tick(delta);
        LuaScriptMgr.Instance.CallLuaFunction("GameMain.Tick", delta);
        if (null != inputTouch)
            inputTouch.Tick(delta);
    }

    void LateUpdate()
    {
        LuaScriptMgr.Instance.CallLuaFunction("GameMain.LateTick", Time.deltaTime);
    }

    void OnApplicationQuit()
    {
        if (null != NetManager.Instance)
            NetManager.Instance.Close();
        Caching.ClearCache();
    }
}