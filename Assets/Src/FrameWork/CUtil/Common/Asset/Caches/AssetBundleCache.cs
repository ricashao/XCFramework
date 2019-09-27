using UnityEngine;

public class AssetBundleCache:AssetCache
{
    protected override float CacheDisposeTime
    {
        get { return 180f; }
    }
    public override void Dispose()
    {
        if (source is AssetBundle)
        {
            AssetBundle ab = source as AssetBundle;

            ab.Unload(false);

            source = null;
        }
    }
}