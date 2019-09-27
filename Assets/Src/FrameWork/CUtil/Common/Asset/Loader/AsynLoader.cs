using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Object = UnityEngine.Object;

public class AsynLoader
{
    /// <summary>
    /// WWW
    /// </summary>
    private WWW mLoader;
    /// <summary>
    /// 加载路径
    /// </summary>
    private string mPath;
    /// <summary>
    /// 加载标志位
    /// </summary>
    private bool mLoading = false;
    /// <summary>
    /// 回调列表
    /// </summary>
    private List<Action<Object>> mCallbacks = new List<Action<Object>>();
    
    public static readonly string[] ABExts = { "ga", "unity3d", "assetbundle" };
    
    /// <summary>
    /// 资源加载
    /// </summary>
    /// <param name="path">资源路径</param>
    /// <param name="callback">回调</param>
    public void Load(string path, Action<Object> callback)
    {
        if (mLoader != null)
        {
            if (path != mPath) return;
        }
        else
        {
            mPath = path;
            mLoader = new WWW(path);
            mLoading = true;
        }
        mCallbacks.Add(callback);
    }
    
    /// <summary>
    /// 定时检查加载进度
    /// </summary>
    public void Tick()
    {
        if (mLoading)
        {
            if (mLoader.error != null)
            {
                OnError();
            }
            else if (mLoader.isDone)
            {
                OnComplete();
            }
        }
    }
    
    private void OnError()
    {
        mLoading = false;
        Debugger.LogError("AsynLoader Error:" + mLoader.error + " :" +mPath);
        for (int i = 0; i < mCallbacks.Count; i++)
        {
            mCallbacks[i](null);
        }

        Dispose();
    }
    
    private void OnComplete()
    {
        mLoading = false;
        Object result = null;
        //获取结果 触发回调
        if (isAssetBundle(mPath))
        {
            result = mLoader.assetBundle;
        }
        else
        {
            result = mLoader.texture;
        }
        for (int i = 0; i < mCallbacks.Count; i++)
        {
            mCallbacks[i](result);
        }

        Dispose();
    }
    
    public void Dispose()
    {
        mLoading = false;
        if (mLoader != null)
        {
            mLoader.Dispose();
            mLoader = null;
        }

        mCallbacks.Clear();
    }
    
    public static bool isAssetBundle(string path)
    {
        string ext = Util.GetPathExtension(path);
        return ABExts.Contains(ext);
    }

}