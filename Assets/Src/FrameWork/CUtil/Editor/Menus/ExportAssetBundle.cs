using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public static class ExportAssetBundle
{
    private static bool stoped = false;
    private static bool isAtlas = false;
    private static string altasName = "";
    private static string atlasTag = "";

    private static string[] _extList =
    {
        "*.prefab.meta", "*.png.meta", "*.jpg.meta", "*.tga.meta",
        "*.mat.meta", "*.TTF.meta", "*.shader.meta", "*.exr.meta", "*.unity.meta",
        "*.mp3.meta", "*.fnt.meta"
    };
    
    public static string WindowsOutputPath = Application.streamingAssetsPath + "/Windows";
    
    [MenuItem("*Resource/Gen Asset bundles/StandaloneWindows")]
    public static void OnCreateAssetBundleWin()
    {
        if (!Directory.Exists(WindowsOutputPath))
        {
            Directory.CreateDirectory(WindowsOutputPath);
        }
        EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTarget.StandaloneWindows);

        Caching.ClearCache();
        BuildPipeline.BuildAssetBundles(WindowsOutputPath,BuildAssetBundleOptions.UncompressedAssetBundle,
            BuildTarget.StandaloneWindows);
          

        //刷新编辑器
        AssetDatabase.Refresh();
        Debug.Log("AssetBundle Packaged finish !!!");
    }
    

    [MenuItem("*Resource/Gen AssetNames %#e", false, 201)]
    private static void OnSetAssetBundleName()
    {
        stoped = false;
        //Object obj = Selection.activeObject;
        string path = AssetDatabase.GetAssetPath(Selection.activeObject);
        string[] extList = _extList;
        foreach (string extension in extList)
        {
            string[] files = os.walk(path, extension);
            foreach (string file in files)
            {
                if (stoped) return;
                DoSetAssetBundleName(file, path.Length);
            }
        }


        //刷新编辑器
        AssetDatabase.Refresh();
        Debug.Log("AssetBundleName Modify finished");
    }
    
    [MenuItem("*Resource/Gen All AssetName", false, 202)]
    public static bool OnSetAllAssetBundleName()
    {
        stoped = false;
        List<String> paths = new List<string>();

        paths.Add(Application.dataPath + "/Atlas");   // 图集
        paths.Add(Application.dataPath + "/Resources"); //Resource
        paths.Add(Application.dataPath + "/Scenes");

        string[] extList = _extList;
        foreach (String path in paths){

            foreach (string extension in extList)
            {
                string[] files = os.walk(path, extension);
                foreach (string file in files)
                {
                    if (stoped) return false;
                    DoSetAssetBundleName(file, path.Length);
                }
            }
        }

        //刷新编辑器
        AssetDatabase.Refresh();
        Debug.Log("AssetBundleName Modify finished");
        return true;
    }

    private static void DoSetAssetBundleName(string path, int index)
    {
        path = path.Replace("\\", "/");

        if (path.IndexOf("Assets/Atlas") != -1)
        {
            string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
            atlasTag = p[p.Length - 2];
            isAtlas = true;
            DoAtlasBundleName(path, index);
            return;
        }

        if (path.IndexOf("Resources/UI/Image") != -1)
        {
            string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
            atlasTag = p[p.Length - 2];
            isAtlas = true;
            DOUITexture(path, index);
            return;
        }

        if (path.IndexOf("Resources/UI/Icon") != -1)
        {
            return;
        }

        if (path.IndexOf("Resources/Shaders") != -1)
        {
            string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
            atlasTag = p[p.Length - 2];
            isAtlas = true;
            DOShaderPackage(path, index);
            return;
        }

        if (path.IndexOf("Resources/Scene") != -1) //场景
        {
            string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
            //atlasTag = p[p.Length - 2];
            //isAtlas = true;
            DOScenePackage(path, index);
            return;
        }

        //打包场景文件
        if (path.IndexOf("Assets/Scenes") != -1)
        {
            DOScenesPackage(path, index);
            return;
        }

        string relativePath = path.Substring(index); // 得到相对路径如：/Prefab/a.prefab.meta
        string prefabName = relativePath.Substring(1, relativePath.IndexOf(".") - 1) + Constants.AssetBundleExtension;
        var fs = new StreamReader(path);
        var ret = new List<string>();
        string line;
        while ((line = fs.ReadLine()) != null)
        {
            line = line.Replace("\n", "");
            if (line.IndexOf("assetBundleName:") != -1)
            {
                line = "  assetBundleName: " + prefabName.ToLower();
            }

            ret.Add(line);
        }

        fs.Close();

        File.Delete(path);

        WirteMetaFile(path, ret);
    }

    private static void DOScenesPackage(string path, int index)
    {
        string relativePath = "Scene/Output/Scenes/" + path.Substring(index);
        string sceneName = relativePath.Substring(0, relativePath.IndexOf(".")) + Constants.AssetBundleExtension;
        var fs = new StreamReader(path);
        var ret = new List<string>();
        string line;
        while ((line = fs.ReadLine()) != null)
        {
            line = line.Replace("\n", "");
            if (line.IndexOf("assetBundleName:") != -1)
            {
                line = "  assetBundleName: " + sceneName.ToLower();
            }

            ret.Add(line);
        }

        fs.Close();

        File.Delete(path);

        WirteMetaFile(path, ret);
    }

    private static void DOScenePackage(string path, int index)
    {
        string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
        atlasTag = p[p.Length - 2];

        string relativePath = path.Substring(index); // 得到相对路径如：/Prefab/a.prefab.meta
        string prefabName;
        if (path.IndexOf("Scene/Output/Prefab") != -1)
        {
            prefabName = relativePath.Substring(1, relativePath.IndexOf(".") - 1) + Constants.AssetBundleExtension;
        }
        else
        {
            //整个目录是一个assetbundle
            prefabName = relativePath.Substring(1, relativePath.LastIndexOf("/") - 1);
            prefabName = prefabName + "/" + atlasTag + Constants.AssetBundleExtension;
        }

        var fs = new StreamReader(path);
        var ret = new List<string>();
        string line;
        while ((line = fs.ReadLine()) != null)
        {
            line = line.Replace("\n", "");
            if (line.IndexOf("assetBundleName:") != -1)
            {
                line = "  assetBundleName: " + prefabName.ToLower();
            }

            ret.Add(line);
        }

        fs.Close();

        File.Delete(path);
        WirteMetaFile(path, ret);
    }

    private static void DOShaderPackage(string path, int index)
    {
        string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
        atlasTag = p[p.Length - 2];

        string relativePath = path.Substring(index); // 得到相对路径如：/Prefab/a.prefab.meta
        string prefabName;
        prefabName = relativePath.Substring(1, relativePath.LastIndexOf("/") - 1);
        prefabName = prefabName + "/" + atlasTag + Constants.AssetBundleExtension;
        var fs = new StreamReader(path);
        var ret = new List<string>();
        string line;
        bool add = false;
        while ((line = fs.ReadLine()) != null)
        {
            line = line.Replace("\n", "");
            if (line.IndexOf("assetBundleName:") != -1)
            {
                line = "  assetBundleName: " + prefabName.ToLower();
                add = true;
            }

            ret.Add(line);
        }

        if (!add)
        {
            //将未加标记的shader 统一添加到一个AssetBundle
            line = "  assetBundleName: " + "shaders/pal_shader" + Constants.AssetBundleExtension;
            ret.Add(line);
        }

        fs.Close();

        File.Delete(path);
        WirteMetaFile(path, ret);
    }

    private static void DOUITexture(string path, int index)
    {
        string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
        atlasTag = p[p.Length - 2];

        string relativePath = path.Substring(index); // 得到相对路径如：/Prefab/a.prefab.meta
        string prefabName;
        prefabName = relativePath.Substring(1, relativePath.LastIndexOf("/") - 1);
        prefabName = prefabName + "/" + atlasTag + Constants.AssetBundleExtension;
        var fs = new StreamReader(path);
        var ret = new List<string>();
        string line;
        bool findBuildTarget = false;
        while ((line = fs.ReadLine()) != null)
        {
            line = line.Replace("\n", "");
            if (line.IndexOf("assetBundleName:") != -1)
            {
                line = "  assetBundleName: " + prefabName.ToLower();
            }
            else if (line.IndexOf("spritePackingTag") != -1)
            {
                line = "  spritePackingTag: " + atlasTag.ToLower();
            }
            else if (line.IndexOf("buildTarget:") != -1)
            {
                findBuildTarget = true;
            }
            else if (line.IndexOf("maxTextureSize") != -1)
            {
                if (findBuildTarget)
                {
                    line = "    maxTextureSize: " + 1024;
                }
                else
                {
                    line = "  maxTextureSize: " + 1024;
                }
            }

            ret.Add(line);
        }

        fs.Close();

        File.Delete(path);
        WirteMetaFile(path, ret);
    }


    private static void DoAtlasBundleName(string path, int index)
    {
        string[] p = path.Split(new string[] {"/"}, StringSplitOptions.None);
        atlasTag = p[p.Length - 2];

        string relativePath = path.Substring(index); // 得到相对路径如：/Prefab/a.prefab.meta
        string prefabName;
        prefabName = relativePath.Substring(1, relativePath.LastIndexOf("/") - 1);
        prefabName = prefabName + "/" + atlasTag + Constants.AssetBundleExtension;
        var fs = new StreamReader(path);
        var ret = new List<string>();
        string line;
        bool findBuildTarget = false;
        while ((line = fs.ReadLine()) != null)
        {
            line = line.Replace("\n", "");
            if (line.IndexOf("assetBundleName:") != -1)
            {
                line = "  assetBundleName: " + prefabName.ToLower();
            }
            else if (line.IndexOf("spritePackingTag") != -1)
            {
                line = "  spritePackingTag: " + atlasTag.ToLower();
            }
            else if (line.IndexOf("buildTarget:") != -1)
            {
                findBuildTarget = true;
            }
            else if (line.IndexOf("maxTextureSize") != -1)
            {
                if (findBuildTarget)
                {
                    line = "    maxTextureSize: " + 1024;
                }
                else
                {
                    line = "  maxTextureSize: " + 1024;
                }
            }

#if UNITY_5_2
                else if (line.IndexOf("textureType") != -1)
                {
                    line = "  textureType: " + 0;
                }
#endif
            ret.Add(line);
        }

        fs.Close();

        File.Delete(path);
        WirteMetaFile(path, ret);
    }


    private static void WirteMetaFile(String path, List<string> ret)
    {
        var writer = new StreamWriter(path + ".tmp");
        foreach (string each in ret)
        {
            writer.WriteLine(each);
        }

        writer.Close();

        File.Copy(path + ".tmp", path);
        File.Delete(path + ".tmp");
    }
}