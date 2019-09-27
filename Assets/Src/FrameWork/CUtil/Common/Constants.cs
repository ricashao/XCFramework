using UnityEngine;

public static class Constants
{
    public static readonly string LogFileName       = Application.persistentDataPath + "/WANCHAO.log";
    public const string ExportedConfigDataFileName    = "ConfigData" + AssetBundleExtension;
    public const string ExportedShadersFileName     = "shaders" + AssetBundleExtension;
    public const string GlobalShaderDirectory       = "Assets/Resources/Shaders";

    public const string AssetBundleExtension        = ".ga";    // file extension for AssetBundle files

    public static class WebPrefab
    {
        public const string MetaInfo    = "metaInfo";
        public const string partPaths   = "partPaths";
        public const string PartHead	= "1\n";        // version
    }

    public const string PrefabExtension = ".prefab";
}