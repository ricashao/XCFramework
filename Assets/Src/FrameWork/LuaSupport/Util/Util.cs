using UnityEngine;

public class Util : MonoBehaviour
{
    /// <summary>
    /// 生成唯一id
    /// </summary>
    /// <param name="path">资源路径</param>
    /// <param name="assetName">资源名</param>
    /// <returns></returns>
    public static string GetResourceID(string path, string assetName)
    {
        if (string.IsNullOrEmpty(assetName))
        {
            return path;
        }
        return path + "::" + assetName;
    }
    
    /// <summary>
    /// 获取路径扩展名
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static string GetPathExtension(string path)
    {
        var ext = "";
        var chars = path.Split('.');
        if (chars.Length > 1)
        {
            ext = chars[chars.Length - 1];
        }
        return ext;
    }
    
    /// <summary>
    /// 获取路径文件名
    /// </summary>
    /// <param name="path"></param>
    /// <returns></returns>
    public static string GetPathName(string path)
    {
        var name = path;
        var chars = path.Split('/');
        if (chars.Length > 0)
        {
            name = chars[chars.Length - 1];

            var arr = name.Split('.');

            if(arr.Length>0) name = arr[0];
        }

        return name;
    }
    
    public static string GenResourcePath(string path)
    {
        var chars = path.Split('.');
        if(chars.Length > 1)
        {
            var count = chars[chars.Length - 1].Length;
            path = path.Substring(0, path.Length - 1 - count);
        }       
        return path;
    }
    
    /// <summary>
    /// 添加组件
    /// </summary>
    public static T Add<T>(GameObject go) where T : Component {
        if (go != null) {
            T[] ts = go.GetComponents<T>();
            for (int i = 0; i < ts.Length; i++ ) {
                if (ts[i] != null) Destroy(ts[i]);
            }
            return go.gameObject.AddComponent<T>();
        }
        return null;
    }
}