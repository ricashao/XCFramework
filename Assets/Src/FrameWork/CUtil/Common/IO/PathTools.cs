using System;
using System.IO;
using UnityEditor;
using UnityEngine;

public static class PathTools
{
    public static string FileProtocolHead
    {
        get
        {
            switch (Application.platform)
            {
                case RuntimePlatform.WindowsEditor:
                case RuntimePlatform.WindowsPlayer:
                    return "file:///";
                case RuntimePlatform.Android:
                    return "jar:file://";
                default:
                    return "file://";
            }
        }
    }

    public static string AssetBundleManifestPath
    {
        get { return StreamingAssetsPath + AssetBunldeDirtory + "/" + AssetBunldeDirtory; }
    }

    public static string StreamingAssetsPath
    {
        get
        {
#if UNITY_ANDROID
               return   Application.dataPath + "!/assets/";
#elif UNITY_IPHONE
                return  Application.dataPath + "/Raw/";
#else
            return Application.streamingAssetsPath + "/";
#endif
        }
    }

    public static string AssetbundleManifestSyncPath
    {
        get
        {
#if UNITY_ANDROID
                return Application.dataPath + "!assets/" + AssetBunldeDirtory + "/" + AssetBunldeDirtory; ;
#elif UNITY_IPHONE
                return  Application.dataPath + "/Raw/"  + AssetBunldeDirtory + "/" + AssetBunldeDirtory;;
#else
            return Application.streamingAssetsPath + "/" + AssetBunldeDirtory + "/" + AssetBunldeDirtory;
            ;
#endif
        }
    }

    public static string AssetBunldeDirtory
    {
        get
        {
            //上面代码，会使在编辑模式下使用安卓平台时，返回Android，而我们想使用Windows下面的资源，所以改成这个
            if (Application.platform == RuntimePlatform.Android)
            {
                return "Android";
            }
            else if (Application.platform == RuntimePlatform.IPhonePlayer)
            {
                return "iOS";
            }
            else if (System.Environment.OSVersion.Platform == PlatformID.MacOSX ||
                     System.Environment.OSVersion.Platform == PlatformID.Unix)
            {
                return "Mac";
            }

            return "Windows";
        }
    }

    public static string GetLoadingPath(string path) // 传过来的是一个相对路径
    {
        string fullPath = string.Empty;
        if (string.IsNullOrEmpty(path))
        {
            return fullPath;
        }

        //临时这里对特殊路径做判断
        if (path != AssetBunldeDirtory)
        {
            path = path.ToLower();
        }

        if (Application.isEditor)
        {
            fullPath = Application.streamingAssetsPath + "/Windows/" + path;
            System.OperatingSystem osInfo = System.Environment.OSVersion;
            if (osInfo.Platform == PlatformID.MacOSX || osInfo.Platform == PlatformID.Unix)
                fullPath = Application.streamingAssetsPath + "/Mac/" + path;
            else
                fullPath = Application.streamingAssetsPath + "/Windows/" + path;
        }
        else
        {
            fullPath = Application.temporaryCachePath + "/" + path;
            if (!System.IO.File.Exists(fullPath))
            {
#if UNITY_ANDROID
                    fullPath = StreamingAssetsPath + "Android/" + path;
#elif UNITY_IPHONE
                    fullPath = StreamingAssetsPath + "iOS/" + path;
#else
                fullPath = StreamingAssetsPath + path;
#endif
            }
        }

        return fullPath;
    }

    public static string GetSyncLoadingPath(string path)
    {
        string fullPath = GetLoadingPath(path);
        if (Application.platform == RuntimePlatform.Android)
        {
            if (path != AssetBunldeDirtory)
            {
                path = path.ToLower();
            }

            fullPath = Application.dataPath + "!assets/Android/" + path;
        }

        return fullPath;
    }

    //============================分隔线======================================


    //========================================================================
    // Used by System.IO codes, so will not startswith "file:///"
    public static string GameResourceRoot
    {
        get
        {
            switch (Application.platform)
            {
#if UNITY_EDITOR
                case RuntimePlatform.WindowsEditor:
                case RuntimePlatform.OSXEditor:
                {
                    var useFileMappings = CheapUtilMain.Instance.Settings.useFileMapping;

                    if (useFileMappings)
                    {
                        return Application.temporaryCachePath;
                    }
                    else
                    {
                        return ExportResourceRoot;
                    }
                }

#endif
                case RuntimePlatform.IPhonePlayer:
                    return Application.temporaryCachePath;

                case RuntimePlatform.Android:
                    return Application.persistentDataPath;

                default:
                    throw new NotImplementedException("Invalid platform type");
            }
        }
    }

    // Used by Editors, it means file in local system, so not StartsWith("file:///")
    private static string _editorResourceRoot;

    #if UNITY_EDITOR
    public static string EditorResourceRoot
    {
        get
        {
            if (null == _editorResourceRoot)
            {
                var dataPath = Application.dataPath;
                var configFileName = dataPath + "/editor_resource_root.txt";


                if (File.Exists(configFileName))
                {
                    var relativePath = File.ReadAllText(configFileName, System.Text.Encoding.UTF8);
                    _editorResourceRoot = os.path.join(ProjectPath, relativePath);
                }
                else
                {
                    var title = "Please choose the editor resource root for exporting or downloading assetBundles";
                    _editorResourceRoot = EditorUtility.OpenFolderPanel(title, dataPath, string.Empty);

                    Uri uri1 = new Uri(dataPath);
                    Uri uri2 = new Uri(_editorResourceRoot);
                    var relativePath = uri1.MakeRelativeUri(uri2).ToString();
                    File.WriteAllText(configFileName, relativePath, System.Text.Encoding.UTF8);
                }


                // remove path segments specified by dots to denote current or parent directory
                _editorResourceRoot = Path.GetFullPath(_editorResourceRoot);
            }

            _editorResourceRoot = _editorResourceRoot.Replace("\\", "/");
            return _editorResourceRoot;
        }
    }

    // Used by Editors, for exporting purpose, platform depended, under EditorResourceRoot, so not StartsWith("file:///")
    public static string ExportResourceRoot
    {
        get
        {
            var activeBuildTarget = EditorUserBuildSettings.activeBuildTarget;
            switch (activeBuildTarget)
            {
                case BuildTarget.iOS:
                    return EditorResourceRoot + "/ios";

                case BuildTarget.Android:
                    return EditorResourceRoot + "/android";

                default:
                {
                    var message = "Unsupported buildTarget found: " + activeBuildTarget.ToString()
                                                                    + ", please change the 'Platform' in 'Build Settings'";
                    return EditorResourceRoot + "/Demo";
                    //                            throw new NotImplementedException(message);
                }
            }
        }
    }
    
    private static string _exportPrefabsRoot;

    public static string ExportPrefabsRoot
    {
        get
        {
            if (null == _exportPrefabsRoot)
            {
                _exportPrefabsRoot = ExportResourceRoot + "/prefabs";
            }

            return _exportPrefabsRoot;
        }
    }

    private static string _exportAnimationRoot;

    public static string ExportAnimationRoot
    {
        get
        {
            if (null == _exportAnimationRoot)
            {
                _exportAnimationRoot = ExportResourceRoot + "/animation";
            }

            return _exportAnimationRoot;
        }
    }

#endif
    
    public static string DefaultUrlRoot
    {
        get { return FileProtocolHead + GameResourceRoot; }
    }

    private static string _projectPath;

    public static string ProjectPath
    {
        get
        {
            if (null == _projectPath)
            {
                var dataPath = Application.dataPath;
                _projectPath = dataPath.Substring(0, dataPath.Length - 7);
            }

            return _projectPath;
        }
    }

    public static string GetBundlePath(string fileNameWithoutSuffix, string path)
    {
        return os.path.join(path, string.Concat(fileNameWithoutSuffix, Constants.AssetBundleExtension));
    }

    public static bool FileExist(string directory, string fileName)
    {
        return false;
    }
}