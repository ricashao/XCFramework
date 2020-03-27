using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEngine;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;

public class EditorSpriteAtlas  {
    
    
    
	[MenuItem("Assets/ui工具/创建单个ui图集")]
    public static void GenSingleUISpriteAtlas()
    {
        Object activeObject = Selection.activeObject;
        string assetPath = AssetDatabase.GetAssetPath(activeObject);
        DirectoryInfo dirInfo = new DirectoryInfo(assetPath);
        string name = dirInfo.Name;
        CreateOneUiSpriteAtlas(name);
        AssetDatabase.Refresh();
//        return rt;  
    }

    private static void CreateOneUiSpriteAtlas(string foldername)
    {
        string folderPath = Application.dataPath + "/AssetsPackage/UI/GenAtlas";
        string exportFullPath = os.path.join(folderPath, foldername);
        string sheetarg = "--sheet " + os.path.join(exportFullPath, foldername + "_tp{n}.png ");
        string dataargs = "--data " + os.path.join(exportFullPath, foldername + "_tp{n}_cfg.txt ");
        string args = sheetarg + dataargs +
                      "--texture-format png --disable-rotation --format unity --multipack " +
                      "--max-size 1024 --trim-mode None --size-constraints POT " +
                      Application.dataPath + "/AssetsPackage/UI/Atlas/" + foldername;
        os.startfile("TexturePacker", args);
    }

    [MenuItem("Assets/ui工具/创建单个ui图集", true)]
    private static bool GenSingleUiSpriteAtlasValidation()
    {
        Object activeObject = Selection.activeObject;
        string assetPath = AssetDatabase.GetAssetPath(activeObject);
        if (Directory.Exists(assetPath))
        {
            DirectoryInfo info = new DirectoryInfo(assetPath);
            if (info.Name.StartsWith("Atlas_") && assetPath.StartsWith("Assets/AssetsPackage/UI/Atlas"))
            {
                return true;
            }
        }
        else
        {
            return false;
        }

        return false;
    }

    [MenuItem("XCFramework/ui工具/所有sprite生成图集")]
    private static void GenAllUiSpriteAtlas()
    {
        string folderPath = Application.dataPath + "/AssetsPackage/UI/Atlas";
        string[] folders = Directory.GetDirectories(folderPath, "Atlas_*", SearchOption.TopDirectoryOnly);
        Debug.Log("start create all uispritesatlas");
        foreach (var folder in folders)
        {
            DirectoryInfo dirInfo = new DirectoryInfo(folder);
            string name = dirInfo.Name;
            CreateOneUiSpriteAtlas(name);
        }

        Debug.Log("end create all uispritesatlas");
        AssetDatabase.Refresh();
    }

    [MenuItem("Assets/ui工具/切割单张图集", true)]
    private static bool ProcessAtlasToSpriteValidation()
    {
        Object activeObject = Selection.activeObject;
        string assetPath = AssetDatabase.GetAssetPath(activeObject);
        if (Directory.Exists(assetPath))
        {
            DirectoryInfo info = new DirectoryInfo(assetPath);
            if (assetPath.StartsWith("Assets/AssetsPackage/UI/GenAtlas"))
            {
                return true;
            }
        }
        else
        {
            return false;
        }

        return false;
    }
    [MenuItem("Assets/ui工具/切割单张图集")]
    public static void ProcessAtlasToSprite()
    {
        Object activeObject = Selection.activeObject;
        string assetPath = AssetDatabase.GetAssetPath(activeObject);
        DirectoryInfo dirInfo = new DirectoryInfo(assetPath);
        FileInfo[] cfgs = dirInfo.GetFiles("*_cfg.txt", SearchOption.TopDirectoryOnly);
        if (cfgs.Length == 1)
        {
            ProcessOneFile(cfgs[0].FullName);
        }
        else
        {
            Debug.LogError("current folder should have one config");
        }
    }

    [MenuItem("XCFramework/ui工具/所有图集生成sprite")]
    public static void ProcessAllAtlasToSprite()
    {
        string folderPath = Application.dataPath + "/AssetsPackage/UI/GenAtlas";

        string[] extList = {"*.txt"};
        foreach (string extension in extList)
        {
            string[] files = os.walk(folderPath, extension);
            foreach (string file in files)
            {
                if (file.IndexOf("_cfg.txt") != -1)
                {
                    ProcessOneFile(file);
                }
            }
        }
    }

    //处理一个文件
    private static void ProcessOneFile(string txtPath)
    {
        txtPath = txtPath.Replace("\\", "/");
        Debug.Log("开始处理图集" + txtPath.Substring(0, txtPath.LastIndexOf("_cfg")) + ".png");

        string rootPath = txtPath;

        rootPath = rootPath.Substring(rootPath.IndexOf("Assets"));
        TextAsset txt = AssetDatabase.LoadAssetAtPath<TextAsset>(rootPath);
        string[] p = rootPath.Split(new string[] {"/"}, StringSplitOptions.None);
        string folder = p[p.Length - 2];
        TexturePacker.MetaData meta = TexturePacker.GetMetaData(txt.text);

        List<SpriteMetaData> sprites = TexturePacker.ProcessToSprites(txt.text, folder);

        rootPath = rootPath.Substring(0, rootPath.LastIndexOf("/"));

        string path = rootPath + "/" + meta.image;
        TextureImporter texImp = AssetImporter.GetAtPath(path) as TextureImporter;
        texImp.spritesheet = sprites.ToArray();
        texImp.textureType = TextureImporterType.Sprite;
        texImp.spriteImportMode = SpriteImportMode.Multiple;

        AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
    }
}
