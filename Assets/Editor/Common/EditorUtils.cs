using UnityEngine;
using System.Collections;
using System.IO;
using UnityEditor;

public class EditorUtils
{
    public static void ExplorerFolder(string folder)
    {
        folder = string.Format("\"{0}\"", folder);
        switch (Application.platform)
        {
            case RuntimePlatform.WindowsEditor:
                System.Diagnostics.Process.Start("Explorer.exe", folder.Replace('/', '\\'));
                break;
            case RuntimePlatform.OSXEditor:
                System.Diagnostics.Process.Start("open", folder);
                break;
            default:
                Debug.LogError(string.Format("Not support open folder on '{0}' platform.", Application.platform.ToString()));
                break;
        }
    }
    
    /// <summary>
    /// 
    /// </summary>
    /// <param name="dirName"></param>
    /// <returns>filename</returns>
    public static string SelectObjectPathInfo(ref string dirName)
    {
        if (UnityEditor.Selection.activeInstanceID < 0)
        {
            return "";
        }

        string path = UnityEditor.AssetDatabase.GetAssetPath(UnityEditor.Selection.activeInstanceID);

        dirName = Path.GetDirectoryName(path) + "/";
        return Path.GetFileName(path);
    }

}
