using UnityEngine;

public interface IAssetCache
{
    string id { get; }

    Object asset { get; }

    bool isDisposeable { get; }

    void SetId(string id);

    void SetAsset(Object asset);

    void SetLastUseTime(float time);

    void Dispose();
}