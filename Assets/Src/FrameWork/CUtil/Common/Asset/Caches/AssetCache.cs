using UnityEngine;

public class AssetCache:IAssetCache
{
    public string id { get; private set; }

    protected Object source;

    private float mLastUseTime;

    public void SetId(string idValue)
    {
        id = idValue;
    }

    public void SetAsset(Object asset)
    {
        source = asset;
    }

    public void SetLastUseTime(float time)
    {
        mLastUseTime = time;
    }

    public Object asset
    {
        get { return source; }
    }

    public bool isDisposeable
    {
        get { return source == null || Time.time - mLastUseTime >= CacheDisposeTime; }
    }

    protected virtual float CacheDisposeTime
    {
        get { return 300f; }
    }

    public virtual void Dispose()
    {
        if (source)
        {
            source = null;
        }
    }
}