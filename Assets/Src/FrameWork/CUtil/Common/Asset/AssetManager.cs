using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

public class AssetManager : MonoBehaviour
{
    /// <summary>
    /// 所有的依赖文件
    /// </summary>
    private static AssetBundleManifest mMainManifest;

    private static Dictionary<string, AsynLoadInfo> mAsynLoadInfos = new Dictionary<string, AsynLoadInfo>();

    private static float CheckGCTime = 60f; //每次gc时间,单位秒

    private static AssetManager mInstance;

    private static IEnumerator mGCAtor;

    /// <summary>
    /// 资源缓存管理器
    /// </summary>
    private static AssetCacheManager mCache = new AssetCacheManager();

    /// <summary>
    /// 异步加载完成回调队列
    /// </summary>
    private static AsynCallQueue mAsynCallQueue = new AsynCallQueue();
    
    /// <summary>
    /// 加载完成 需要移除的加载路径
    /// </summary>
    private static List<string> removePath  = new List<string>();


    /// <summary>
    /// 加载资源枚举
    /// </summary>
    private enum LOAD_RES_TYPE
    {
        COMMON,
        ATLAS_IMAGE
    };


    public static Vector3 DefaultPosition = new Vector3(9999f, 9999f, 9999f);
    public static Quaternion DefaultRotation = new Quaternion(9999f, 9999f, 9999f, 9999f);


    private static List<GroupLoadTask> groupTasks = new List<GroupLoadTask>();
    private static List<GroupLoadTask> rubbishGroupTasks = new List<GroupLoadTask>(8);

    void Awake()
    {
        mInstance = this;

        mCache.StartCheckGCEvent += StartCheckGC;
    }

    private void StartCheckGC()
    {
        if (mGCAtor == null)
        {
            mGCAtor = CheckGC();
            StartCoroutine(mGCAtor);
        }
    }


    IEnumerator CheckGC()
    {
        while (true)
        {
            yield return new WaitForSeconds(CheckGCTime);
            if (mCache.CheckCacheGC())
            {
                StopCheckGC();
                break;
            }
        }
    }

    private void StopCheckGC()
    {
        if (mGCAtor != null)
        {
            StopCoroutine(mGCAtor);

            mGCAtor = null;
        }
    }

    internal static bool TryInstantiateGameObject(Object source, out Object target, Vector3 position,
        Quaternion rotation)
    {
        bool flag = false;
        if (source is GameObject)
        {
            if (!position.Equals(DefaultPosition) || !rotation.Equals(DefaultRotation))
            {
                target = Instantiate(source, position, rotation);
            }
            else
            {
                target = Instantiate(source);
            }

            target.name = target.name.Substring(0, target.name.IndexOf("(Clone)"));

            flag = true;
        }
        else
        {
            target = null;
        }

        return flag;
    }

    /// <summary>
    /// 加载依赖manifest
    /// </summary>
    private static void InitMainManifest()
    {
        if (mMainManifest) return;

        AssetBundle ab = CreateFromFile(PathTools.AssetBunldeDirtory);

        if (ab)
        {
            mMainManifest = ab.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        }

        if (!mMainManifest)
        {
            Debugger.LogError("AssetManager Error: Can't find Main AssetBundleManifest! AssetBundleManifestPath:" +
                              PathTools.AssetbundleManifestSyncPath);
        }
    }


    private static AssetBundle CreateFromFile(string path)
    {
        //路径如果有空格，则不加载
        if (path.Contains(" ")) return null;

        AssetBundle ab = mCache.GetCacheAssetBundle(path);

        if (!ab)
        {
            ab = AssetBundle.LoadFromFile(PathTools.GetSyncLoadingPath(path));
            mCache.CacheAssetBundle(path, ab);
        }

        return ab;
    }

    void Update()
    {
        //1.检查是否有加载好的资源 进行回调
        mAsynCallQueue.CheckAsynCall();

        //2.资源加载检测
        if (mAsynLoadInfos.Count > 0)
        {
            var infos = mAsynLoadInfos.GetEnumerator();
            while (infos.MoveNext())
            {
                infos.Current.Value.Tick();
            }

            infos.Dispose();
        }

        if (removePath.Count > 0)
        {
            foreach (var path in removePath)
            {
                mAsynLoadInfos.Remove(path);
            }
            removePath.Clear();
        }

        //任务组加载检测
        if (groupTasks.Count > 0)
        {
            for (int i = 0; i < groupTasks.Count; i++)
            {
                var groupLoadTask = groupTasks[i];
                if (groupLoadTask.IsDone())
                {
                    rubbishGroupTasks.Add(groupLoadTask);
                }
            }

            for (int i = 0; i < rubbishGroupTasks.Count; i++)
            {
                var rubbishGroupTask = rubbishGroupTasks[i];
                groupTasks.Remove(rubbishGroupTask);
                rubbishGroupTasks[i] = null;
            }

            rubbishGroupTasks.Clear();
        }
    }

    #region 动态加载场景

    /// <summary>
    /// 加载场景的资源
    /// </summary>
    /// <param name="path"></param>
    public static bool LoadScene(string path)
    {
        string sceneName = Util.GetPathName(path);

        if (Application.CanStreamedLevelBeLoaded(sceneName))
        {
            //当前可以加载，不用再加载ga
            return true;
        }

        //需要通过加载场景ga
        AssetBundle ab = CreateFromFile(path);
        if (ab)
        {
            return true;
        }

        return false;
    }

    #endregion

    #region C#异步请求

    public static Object LoadAsset(string path, Action<Object> callback)
    {
        return LoadAsset(path, Util.GetPathName(path), callback, DefaultPosition, DefaultRotation);
    }

    public static Object LoadAsset(string path, Action<Object> callback, Vector3 position, Quaternion rotation)
    {
        return LoadAsset(path, Util.GetPathName(path), callback, position, rotation);
    }

    #endregion

    public static Object LoadAsset(string path)
    {
        return LoadAsset(path, DefaultPosition, DefaultRotation);
    }

    public static Object LoadAsset(string path, string assetName)
    {
        return LoadAsset(path, assetName, DefaultPosition, DefaultRotation);
    }

    public static Object LoadAsset(string path, string assetName, string key)
    {
        return LoadAsset(path, assetName, key, DefaultPosition, DefaultRotation);
    }

    public static Object LoadAsset(string path, Vector3 position, Quaternion rotation)
    {
        return LoadAsset(path, Util.GetPathName(path), position, rotation);
    }

    public static Object LoadAsset(string path, string assetName, Vector3 position, Quaternion rotation)
    {
        return LoadAsset(path, assetName, "", position, rotation);
    }

    /// <summary>
    /// 请求资源，assetName会通过path中获取
    /// 如果传了key参数，则会走异步加载逻辑，通过回调函数返回资源 
    /// </summary>
    /// <param name="path">资源地址，包含扩展名，通过扩展名来实现是加载ab还是其他资源</param>
    /// <param name="assetName">资源名称</param>
    /// <param name="key">lua请求时，通过这个key来获取回调函数，会走异步处理</param>
    /// <param name="position">初始化坐标</param>
    /// <param name="rotation">初始化旋转</param>
    /// <returns></returns>
    public static Object LoadAsset(string path, string assetName, string key, Vector3 position, Quaternion rotation)
    {
        Action<Object> callBack = null;
        if (!string.IsNullOrEmpty(key))
        {
            try
            {
                callBack = (s) => LuaScriptMgr.Instance.CallLuaFunction("AsynPrefabLoader.CallFromCS", key, path, s);
            }
            catch
            {
                Debugger.LogError("AssetManager Error: Not Find LuaFunction,path=" + path + ",key=" + key);
            }
        }

        return LoadAsset(path, assetName, callBack, position, rotation);
    }

    public static Object LoadAsset(string path, string assetName, Action<Object> callBack, Vector3 position,
        Quaternion rotation)
    {
        Object target = null;
        Object source = mCache.GetCacheSourceAsset(path, assetName);

        if (!source)
        {
#if UNITY_EDITOR
            string localPath = Util.GenResourcePath(path);
            if (Util.GetPathName(path) != assetName)
            {
                localPath = Util.GenResourcePath(assetName.Replace("Assets/Resources/", ""));
            }
       
            source = Resources.Load(localPath);
#endif
        }
        if (!source)
        {
            if (callBack == null)
            {
                //进行同步加载ab
                if (AsynLoader.isAssetBundle(path))
                {
                    source = LoadAssetByAssetBundle(path, assetName);
                }
                else
                {
                    Debugger.LogError("AssetManager Error: Sync Load Path isn't AssetBoundle!!!! Path:" + path);
                }
            }
            else
            {
                //进行异步加载
                AsyncLoadAsset(path, assetName, callBack, position, rotation, LOAD_RES_TYPE.COMMON);
            }
        }

        if (source)
        {
            //缓存
            mCache.CacheSourceAsset(path, assetName, source);

            if (callBack != null)
            {
                //添加到回调列表
                mAsynCallQueue.AddAsynCall(path, source, callBack, position, rotation);
            }
            else if (!TryInstantiateGameObject(source, out target, position, rotation))
            {
                target = source;
            }
        }
        else if (callBack == null)
        {
            //如果不是异步，则找不到资源
            Debugger.LogError("AssetManager Error: Can't find Asset By Sync Load!!! Path:" + path);
        }

        return target;
    }

    private static Object LoadAssetByAssetBundle(string path, string assetName)
    {
        AssetBundle ab = CreateFromFile(path);
        if (!ab)
        {
            return null;
        }

        Object source = GetAssetByAB(ab, path, assetName);

        return source;
    }


    private static Object GetAssetByAB(AssetBundle ab, string path, string assetName)
    {
        if (!ab) return null;

        InitMainManifest();

        AssetBundle[] abs = null;
        int i = 0;
        if (mMainManifest)
        {
            //获取资源依赖
            string[] dps = mMainManifest.GetAllDependencies(path);

            abs = new AssetBundle[dps.Length];

            AssetBundle tempAb;
            for (i = 0; i < dps.Length; i++)
            {
                tempAb = CreateFromFile(dps[i]);

                if (tempAb)
                {
                    abs[i] = tempAb;
                }
                else
                {
                    Debugger.LogError("AssetManager Error: Can't find AssetBundle Dependencies! AssetBundle Path:" +
                                      path +
                                      ",Dependescie Path:" + dps[i]);
                }
            }
        }

        Object source = ab.LoadAsset(assetName);

        if (!source)
        {
            Debugger.LogWarning("AssetManager Warning:Can't find Asset from AssetBundle! AssetName:" + assetName);
        }

        return source;
    }

    /// <summary>
    /// 异步加载
    /// </summary>
    /// <param name="path"></param>
    /// <param name="assetName"></param>
    /// <param name="callback"></param>
    /// <param name="position"></param>
    /// <param name="rotation"></param>
    /// <param name="type"></param>
    private static void AsyncLoadAsset(string path, string assetName, Action<Object> callback, Vector3 position,
        Quaternion rotation, LOAD_RES_TYPE type)
    {
        string fullpath = PathTools.FileProtocolHead + PathTools.GetLoadingPath(path);

        AsynLoadInfo info;
        if (!mAsynLoadInfos.TryGetValue(fullpath, out info))
        {
            if (type == LOAD_RES_TYPE.ATLAS_IMAGE)
            {
                info = new AsynLoadInfo(path, fullpath, OnAsynAtlasLoadComplete);
            }
            else
            {
                info = new AsynLoadInfo(path, fullpath, OnAsynLoadComplete);
            }

            AssetBundle ab = mCache.GetCacheAssetBundle(path);
            if (ab)
            {
                info.OnLoadComplete(ab);
            }
            else
            {
                info.Load();
            }

            mAsynLoadInfos.Add(fullpath, info);
        }

        info.AddAssetNameCallBack(assetName, callback, position, rotation);
    }

    private static void OnAsynLoadComplete(AsynLoadInfo info)
    {
        Object result = info.data;
        string path = info.fullPath;
        if (result is AssetBundle)
        {
            mCache.CacheAssetBundle(info.path, result as AssetBundle);
        }

//        List<string> assetNames = new List<string>(info.assetNames.Keys);

        var assetNames = info.assetNames.GetEnumerator();

        string assetName;
        List<AsynLoadInfoItem> items;
        AsynLoadInfoItem item;
        Object source;
        Object target;
        //        for (int i = 0; i < assetNames.Count; i++)
        //            assetName = assetNames[i];
        //            items = info.assetNames[assetName];
        while (assetNames.MoveNext())
        {
            assetName = assetNames.Current.Key;
            items = assetNames.Current.Value;

            if (result is AssetBundle)
            {
                source = GetAssetByAB(result as AssetBundle, info.path, assetName);
            }
            else
            {
                source = result;
            }

            for (int j = 0; j < items.Count; j++)
            {
                item = items[j];
                if (!TryInstantiateGameObject(source, out target, item.Position, item.Rotation))
                {
                    target = source;
                }

                try
                {
                    item.CallBack(target);
                }
                catch (Exception e)
                {
                    Debugger.LogError("AssetManager Error: AsynLoadComplete's callback is Error! path:" + path +
                                      ",Error Message:" + e.StackTrace);
                }

                item.Dispose();
            }

            mCache.CacheSourceAsset(info.path, assetName, source);
        }

        assetNames.Dispose();

        info.Dispose();

        removePath.Add(path);
//        mAsynLoadInfos.Remove(path);
    }

    //异步加载的图集加载完毕
    private static void OnAsynAtlasLoadComplete(AsynLoadInfo info)
    {
        Object result = info.data;
        string path = info.fullPath;
        if (!(result is AssetBundle))
        {
            Debug.LogError("Atlas Loaded is Not AsssetBundle");
            return;
        }

        mCache.CacheAssetBundle(info.path, result as AssetBundle);

        var assetNames = info.assetNames.GetEnumerator();

        string assetName;
        List<AsynLoadInfoItem> items;
        AsynLoadInfoItem item;

        SpritesObject spriteObj = new SpritesObject();
        Sprite[] sp = (result as AssetBundle).LoadAllAssets<Sprite>();
        while (assetNames.MoveNext())
        {
            assetName = assetNames.Current.Key;
            items = assetNames.Current.Value;

            for (int j = 0; j < items.Count; j++)
            {
                item = items[j];
                try
                {
                    spriteObj.sprites = sp;
                    item.CallBack(spriteObj);
                }
                catch (Exception e)
                {
                    Debugger.LogError("AssetManager Error: AsynLoadComplete's callback is Error! path:" + path +
                                      ",Error Message:" + e.StackTrace);
                }

                item.Dispose();
            }
        }

        assetNames.Dispose();

        info.Dispose();
        removePath.Add(path);

//        mAsynLoadInfos.Remove(path);
    }

    public static void LoadAltasAsset(string path, Action<Object> callBack)
    {
#if UNITY_EDITOR

        string localPath = Util.GenResourcePath(path);
        Sprite[] sprites = Resources.LoadAll<Sprite>(localPath);
        if (sprites != null)
        {
            SpritesObject obj = new SpritesObject();
            obj.sprites = sprites;
            callBack(obj);
        }
        else
        {
            Debugger.LogError("没有找到图集资源:" + path);
        }
#else
        AsyncLoadAsset(path, "", callBack, DefaultPosition, DefaultRotation, LOAD_RES_TYPE.ATLAS_IMAGE);
#endif
    }

    public static void LoadAssetGroup(GroupLoadReqItem[] reqs, Action<Object[]> callback)
    {
        var results = new Object[reqs.Length];
        for (int i = 0; i < reqs.Length; i++)
        {
            var groupLoadReqItem = reqs[i];
            int k = i;
            AsyncLoadAsset(groupLoadReqItem.path, groupLoadReqItem.assetName, (o) => results[k] = o, DefaultPosition,
                DefaultRotation, LOAD_RES_TYPE.COMMON);
        }

        groupTasks.Add(new GroupLoadTask {taskCount = reqs.Length, results = results, callback = callback});
    }

    /// <summary>
    /// 清除缓存源资源，会导致所有资源需要重新加载，如果不到内存临界点不建议清除，因为加载资源的IO成本还是很高的
    /// 
    /// AssetManager本身会定期清理长期不用的资源
    /// </summary>
    public static void Clear()
    {
        mCache.Clear();
    }
}


class AsynLoadInfo
{
    public string path { private set; get; }
    public string fullPath { private set; get; }
    public Dictionary<string, List<AsynLoadInfoItem>> assetNames { private set; get; }
    public Object data { private set; get; }
    private AsynLoader mloader;
    private Action<AsynLoadInfo> OnCompleted;
    private bool needCallBack = false;

    public AsynLoadInfo(string pathValue, string fullPathValue, Action<AsynLoadInfo> completeCallback)
    {
        path = pathValue;
        fullPath = fullPathValue;
        OnCompleted = completeCallback;

        assetNames = new Dictionary<string, List<AsynLoadInfoItem>>();
        mloader = new AsynLoader();
    }

    public void AddAssetNameCallBack(string assetName, Action<Object> callback, Vector3 position, Quaternion rotation)
    {
        List<AsynLoadInfoItem> List;
        if (!assetNames.TryGetValue(assetName, out List))
        {
            List = new List<AsynLoadInfoItem>();

            assetNames.Add(assetName, List);
        }

        List.Add(new AsynLoadInfoItem(callback, position, rotation));
    }

    public void Load()
    {
        if (data)
        {
            needCallBack = true;
        }
        else if (mloader != null)
        {
            mloader.Load(fullPath, OnLoadComplete);
        }
    }

    public void OnLoadComplete(Object result)
    {
        needCallBack = true;
        data = result;
    }

    public void Tick()
    {
        if (data)
        {
            if (needCallBack)
            {
                needCallBack = false;
                OnCompleted(this);
            }
        }
        else if (mloader != null)
        {
            mloader.Tick();
        }
    }

    public void Dispose()
    {
        needCallBack = false;
        assetNames.Clear();
        if (mloader != null)
        {
            mloader.Dispose();
            mloader = null;
        }

        data = null;
        OnCompleted = null;
    }
}

class AsynLoadInfoItem
{
    public Action<Object> CallBack { private set; get; }
    public Vector3 Position { private set; get; }
    public Quaternion Rotation { private set; get; }

    public AsynLoadInfoItem(Action<Object> callback, Vector3 position, Quaternion rotation)
    {
        CallBack = callback;
        Position = position;
        Rotation = rotation;
    }

    public void Dispose()
    {
        CallBack = null;
    }
}

public class GroupLoadReqItem
{
    public string path;
    public string assetName;
}

public class GroupLoadTask
{
    public int taskCount;
    public Object[] results;
    public Action<Object[]> callback;

    public bool IsDone()
    {
        if (null != callback)
        {
            foreach (var result in results)
            {
                if (null == result)
                    return false;
            }

            callback(results);
            results = null;
            callback = null;
            return true;
        }

        return false;
    }
}