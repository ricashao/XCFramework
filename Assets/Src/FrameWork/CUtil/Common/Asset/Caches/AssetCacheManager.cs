using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 资源缓存管理器
/// 工作：1.加载资源
///      2.加载资源包
///      3.更新资源使用时间
///      4.执行检测gc
/// </summary>
public class AssetCacheManager
{
    /// <summary>
    /// 缓存资源管理
    /// </summary>
    private Dictionary<string, IAssetCache> mCaches = new Dictionary<string, IAssetCache>();
    
    public delegate void EventHandler();
    
    public event EventHandler StartCheckGCEvent;
    
    /// <summary>
    /// 检测缓存
    /// </summary>
    /// <returns></returns>
    public bool CheckCacheGC()
    {
        bool flag = true;
        //记录需要移除的缓存
        List<IAssetCache> caches = new List<IAssetCache>(mCaches.Values);
        IAssetCache cache;
        if (caches.Count > 0)
        {
            flag = false;

            bool disposed = false;
            for (int i = 0; i < caches.Count; i++)
            {
                cache = caches[i];

                if (cache.isDisposeable)
                {
                    disposed = true;

                    cache.Dispose();

                    mCaches.Remove(cache.id.ToLower());
                }
            }
            if (disposed)
            {
                Resources.UnloadUnusedAssets();
            }
        }

        return flag;
    }
    
    /// <summary>
    /// 缓存资源
    /// </summary>
    /// <param name="path"></param>
    /// <param name="assetName"></param>
    /// <param name="source"></param>
    public void CacheSourceAsset(string path, string assetName, Object source)
    {
        if (!source || !(source is GameObject)) return;

        string id = Util.GetResourceID(path, assetName);

        AssetCache cache = GetCache(id) as AssetCache;

        if (cache == null)
        {
            cache = new AssetCache();
            CacheAsset(id, cache,source);
        }

        cache.SetLastUseTime(Time.time);
    }
    
    /// <summary>
    /// 获取缓存
    /// </summary>
    /// <param name="path"></param>
    /// <param name="assetName"></param>
    /// <returns></returns>
    public Object GetCacheSourceAsset(string path, string assetName)
    {
        IAssetCache cache = GetCache(Util.GetResourceID(path, assetName));

        if (cache != null)
        {
            //刷新使用时间
            cache.SetLastUseTime(Time.time);

            return cache.asset;
        }

        return null;
    }
    
    /// <summary>
    /// 缓存资源包
    /// </summary>
    /// <param name="path"></param>
    /// <param name="asset"></param>
    public void CacheAssetBundle(string path, AssetBundle asset)
    {
        if (!asset) return;

        AssetBundleCache cache = GetCache(path) as AssetBundleCache;

        if (cache == null)
        {
            cache = new AssetBundleCache();
            CacheAsset(path, cache, asset);
        }

        cache.SetLastUseTime(Time.time);
    }
    
    public AssetBundle GetCacheAssetBundle(string path)
    {
        IAssetCache cache = GetCache(path);

        if (cache != null)
        {
            cache.SetLastUseTime(Time.time);

            return cache.asset as AssetBundle;
        }

        return null;
    }

    
    private void CacheAsset(string id, IAssetCache cache,Object asset)
    {
        cache.SetId(id);
        cache.SetAsset(asset);

        if (!mCaches.ContainsKey(id))
        {
            id = id.ToLower();

            mCaches.Add(id, cache);

            DispatchStartCheckGCEvent();
        }
        else
        {
            cache.Dispose();
        }
    }
    
    
    public IAssetCache GetCache(string id)
    {
        IAssetCache cache;

        id = id.ToLower();

        mCaches.TryGetValue(id, out cache);

        return cache;
    }
    
    /// <summary>
    /// 开始检测gc
    /// </summary>
    private void DispatchStartCheckGCEvent()
    {
        if (StartCheckGCEvent != null)
        {
            StartCheckGCEvent();
        }
    }
    
    public void Clear()
    {
//            List<IAssetCache> list = new List<IAssetCache>(mCaches.Values);
//
//            for (int i = 0; i < list.Count; i++)
//            {
//                list[i].Dispose();
//            }
        var list = mCaches.GetEnumerator();
        while (list.MoveNext())
        {
            list.Current.Value.Dispose();
        }
        list.Dispose();
        mCaches.Clear();

        Resources.UnloadUnusedAssets();
    }
    
}