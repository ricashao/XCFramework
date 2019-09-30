using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

/// <summary>
/// 对象池生成，管理类
/// </summary>
public class PoolManager: MonoBehaviour
{
    /// <summary>
    /// 管理所有的对象池
    /// </summary>
    private static Dictionary<string, IPool> mPools = new Dictionary<string, IPool>();
    
    /// <summary>
    /// 按照级别管理对象池
    /// </summary>
    private static Dictionary<uint, List<IPool>> mPoolLevels = new Dictionary<uint, List<IPool>>();
    
    
    private static Dictionary<object, ActivePoolInfo> mActivePools = new Dictionary<object, ActivePoolInfo>();
    
    private static PoolManager mInstance;

    private static GameObject mPoolContainer;

    private static IEnumerator mGCAtor;
    
    void Awake()
    {
        mInstance = this;
    }
    
    void Update()
    {
        if (mPools.Count > 0)
        {
            var pools = mPools.GetEnumerator();
            while (pools.MoveNext())
            {
                pools.Current.Value.Update();
            }
            pools.Dispose();
        }
    }
    
    private static PoolManager instance
    {
        get
        {
            if (mInstance == null)
            {
                mInstance = poolContainer.AddComponent<PoolManager>();
            }
            return mInstance;
        }
    }
    
    /// <summary>
    /// 初始化容器节点
    /// </summary>
    internal static GameObject poolContainer
    {
        get
        {
            if (mPoolContainer == null)
            {
                mPoolContainer = new GameObject("PoolContainer");
                mPoolContainer.transform.position = new Vector3(9999, 9999, 9999);
                DontDestroyOnLoad(mPoolContainer);//暂时写在这里，如果有统一管理的地方再统一添加
            }
            return mPoolContainer;
        }
    }

    private void StartCheckGC()
    {
        if (mGCAtor == null)
        {
            mGCAtor = CheckGC();
            StartCoroutine(mGCAtor);
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

    IEnumerator CheckGC()
    {
        while (true)
        {
            yield return new WaitForSeconds(60f);

            //清理对象池
            List<IPool> poolList = new List<IPool>(mPools.Values);
            for (int i = 0; i < poolList.Count; i++)
            {
                if (!TryRmovePool(poolList[i]))
                {
                    TryClearPool(poolList[i]);
                }
            }
            //清理激活池
            var actives = new List<object>(mActivePools.Keys);
            Object activeObject;
            for (int i = 0; i < actives.Count; i++)
            {
                activeObject = actives[i] as Object;
                if (!activeObject)
                {
                    mActivePools.Remove(activeObject);
                }
            }

            if (actives.Count == 0 && poolList.Count == 0)
            {
                StopCheckGC();
                break;
            }
        }
    }
    
    private static bool TryClearPool(IPool pool)
    {
        if (pool.IsClearable)
        {
            pool.Clear();
            return true;
        }
        return false;
    }
    
    private static bool TryRmovePool(IPool pool)
    {
        if (pool.IsDisposeable)
        {
            RemovePool(pool);
            return true;
        }
        return false;
    }
    
    private static void RemovePool(IPool pool)
    {
//        if (pool is ResourcePool)
//        {
//            (pool as ResourcePool).AsynLoadCompleted -= OnResourceAsynLoad;
//        }
        pool.Dispose();
        mPools.Remove(pool.id);
        mPoolLevels[pool.level].Remove(pool);
    }
    
    
    public static object GetResourceObject(string path, int size)
    {
        return GetResourceObject(path, Util.GetPathName(path), size);
    }
    
    
    public static object GetResourceObject(string path, string assetName)
    {
        return GetResourceObject(path, assetName, 1);
    }

    public static object GetResourceObject(string path, string assetName, int size)
    {
        return GetResourceObject(path, assetName, size,0);
    }

    public static object GetResourceObject(string path, string assetName, int size, uint level)
    {
        return GetResourceObject(path, assetName, size, level,"");
    }

    public static object GetResourceObject(string path, string assetName, int size, uint level,string key)
    {
        return GetResourceObject(path, assetName, size, level, key,AssetManager.DefaultPosition,AssetManager.DefaultRotation);
    }

    public static object GetResourceObject(string path, string assetName, int size, uint level, string key, Vector3 position, Quaternion rotation)
    {
        return GetResourceObject(path, assetName, size, level, key, null, position, rotation);
    }
    
    #region C#异步请求
    public static object GetResourceObject(string path, int size, uint level, Action<object> callback)
    {
        return GetResourceObject(path, size, level, callback, AssetManager.DefaultPosition, AssetManager.DefaultRotation);
    }

    public static object GetResourceObject(string path, int size, uint level, Action<object> callback, Vector3 position, Quaternion rotation)
    {
        return GetResourceObject(path, Util.GetPathName(path), size, level, "", callback, position, rotation);
    }
    #endregion
    
    
    /// <summary>
    /// 获取资源对象
    /// </summary>
    /// <param name="path">资源路径</param>
    /// <param name="assetName">资源名称</param>
    /// <param name="size">池子大小，同一个资源大小先后赋值不同，则替换池子大小</param>
    /// <param name="level">对象池等级</param>
    /// <param name="key">lua回调函数key</param>
    /// <param name="callback">回调函数</param>
    /// <param name="position">初始化坐标</param>
    /// <param name="rotation">初始化旋转</param>
    /// <returns></returns>
    public static object GetResourceObject(string path, string assetName, int size, uint level, string key, Action<object> callback, Vector3 position, Quaternion rotation)
    {
        object target;
        IPool pool;

        string id = ResourcePool.GetID(path, assetName);
        if (!mPools.TryGetValue(id, out pool))
        {
            pool = new ResourcePool(path, assetName, size, level);
            AddPool(pool);
        }
        else
        {
            pool.SetSize(size);
            if (level != pool.level)
            {
                //需要重构
                List<IPool> list = mPoolLevels[pool.level];
                mPoolLevels.Remove(pool.level);
                pool.SetLevel(level);
                mPoolLevels.Add(pool.level, list);
            }
        }

        target = callback != null ? pool.GetObject(callback,position,rotation) : pool.GetObject(key, position, rotation);

        if (target != null)
            AddActivePoolInfo(target, pool.id);

        instance.StartCheckGC();

        return target;
    }
    
    
    private static void AddPool(IPool pool)
    {
        if (pool is ResourcePool)
        {
            (pool as ResourcePool).AsynLoadCompleted += OnResourceAsynLoad;
        }
        mPools.Add(pool.id, pool);

        List<IPool> list;
        if (!mPoolLevels.TryGetValue(pool.level, out list))
        {
            list = new List<IPool>();
            mPoolLevels.Add(pool.level, list);
        }
        list.Add(pool);
    }
    
    private static void OnResourceAsynLoad(ResourcePool pool, object target)
    {
        AddActivePoolInfo(target,pool.id);
    }
    
    private static void AddActivePoolInfo(object target,string id)
    {
        if (target == null) return;

        ActivePoolInfo info;
        if (!mActivePools.TryGetValue(target, out info))
        {
            info = new ActivePoolInfo(target,id);
            mActivePools.Add(target, info);
        }
        info.AddCount();
    }

    
}


class ActivePoolInfo
{
    public object target { private set; get; }

    public string id { private set; get; }

    public int count { private set; get; }

    public ActivePoolInfo(object targetValue,string idValue)
    {
        target = targetValue;
        id = idValue;
    }

    public void AddCount()
    {
        count ++;
    }

    public void ReduceCount()
    {
        count = count > 0 ? --count : 0;
    }

    public bool IsEmpty
    {
        get { return count <= 0; }
    }

    public void Dispose()
    {
        target = null;
    }
}
