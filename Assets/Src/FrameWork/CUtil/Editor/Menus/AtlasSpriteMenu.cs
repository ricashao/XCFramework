using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using UnityEditor;
using UnityEngine;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;

public class AtlasSpriteMenu
{
   [MenuItem("Assets/AtlasSprite/Create Single UISpriteAtlas")]
    public static void GenSingleUISpriteAtlas()
    {
        Object activeObject = Selection.activeObject;
        string assetPath = AssetDatabase.GetAssetPath(activeObject);
        DirectoryInfo dirInfo = new DirectoryInfo(assetPath);
        string name = dirInfo.Name;
        string exportFullPath = os.path.join(dirInfo.Parent.Parent.FullName, "GenAtlas", name);
        string sheetarg = "--sheet " + os.path.join(exportFullPath, name + "_tp{n}.png ");
        string dataargs = "--data " + os.path.join(exportFullPath, name + "_tp{n}_cfg.txt ");
        string genname = Application.dataPath + assetPath.TrimStart("Assets".ToCharArray());
        string args = sheetarg + dataargs +
                      "--texture-format png --disable-rotation --format unity --multipack  --max-size 1024 --trim-mode None --size-constraints POT "+genname;

        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = "TexturePacker";
        info.Arguments = args;
        info.UseShellExecute = false;
        info.WindowStyle = ProcessWindowStyle.Normal;
        info.CreateNoWindow = false;
        Process task = null;
        bool rt = true;
        try
        {
            Debug.Log("ExecuteProgram:" + args);

            task = Process.Start(info);
            if (task != null)
            {
                task.WaitForExit(10000);
            }
            else
            {
                return;
            }
        }
        catch (Exception e)
        {
            Debug.LogError("ExecuteProgram:" + e.ToString());
            return;
        }
        finally
        {
            if (task != null && task.HasExited)
            {
                rt = (task.ExitCode == 0);
            }
        }

        Debug.Log(name + "打图集" + (rt ? "成功" : "失败"));
        AssetDatabase.Refresh();
//        return rt;  
    }

    [MenuItem("Assets/AtlasSprite/Create Single UISpriteAtlas", true)]
    private static bool GenSingleUISpriteAtlasValidation()
    {
        Object activeObject = Selection.activeObject;
        string assetPath = AssetDatabase.GetAssetPath(activeObject);
        if (Directory.Exists(assetPath))
        {
            DirectoryInfo info = new DirectoryInfo(assetPath);
            if (info.Name.StartsWith("Atlas_") && assetPath.StartsWith("Assets/Resources/UI/Image"))
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
}
