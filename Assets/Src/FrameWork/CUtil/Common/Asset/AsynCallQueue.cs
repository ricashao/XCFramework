using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

/// <summary>
/// 异步加载完成回调队列
/// </summary>
public class AsynCallQueue
{
    private List<AsynCallItem> mItems = new List<AsynCallItem>();
    private Dictionary<string, AsynCallItem> mItemMap = new Dictionary<string, AsynCallItem>();
    
    public void AddAsynCall(string path, Object source, Action<Object> callback,Vector3 position,Quaternion rotation)
    {
        if (!source || callback == null) return;
        AsynCallItem item;
        if (!mItemMap.TryGetValue(path, out item))
        {
            item = new AsynCallItem(path, source);
            mItems.Add(item);
            mItemMap.Add(path, item);
        }
        item.AddCallBack(callback, position,rotation);
    }
    
    
    public void CheckAsynCall()
    {
        if (mItems.Count > 0)
        {
            AsynCallItem item;
            while(mItems.Count>0)
            {
                item = mItems[0];
                item.DoCall();
                item.Dispose();
                RemoveAsynCall(item);
            }
        }
    }
    
    private void RemoveAsynCall(AsynCallItem item)
    {
        mItems.Remove(item);
        mItemMap.Remove(item.path);
    }
}



class AsynCallItem
{
    public string path { private set; get; }

    private Object source;
    private List<Vector3> mPositionList = new List<Vector3>();
    private List<Quaternion> mRotationList = new List<Quaternion>();
    private List<Action<Object>> mCallList = new List<Action<Object>>();

    public AsynCallItem(string pathValue,Object sourceValue)
    {
        path = pathValue;
        source = sourceValue;
    }

    public void AddCallBack(Action<Object> callback, Vector3 position, Quaternion rotation)
    {
        if (callback == null) return;

        mPositionList.Add(position);
        mRotationList.Add(rotation);
        mCallList.Add(callback);
    }

    public void DoCall()
    {
        Object asset = null;
        Vector3 position;
        Quaternion rotation;
        Action<Object> callback;
        mCallList.Reverse();
        mPositionList.Reverse();
        mRotationList.Reverse();
        for (int i = mCallList.Count - 1; i >= 0 ; --i)
        {
            callback = mCallList[i];
            position = mPositionList[i];
            rotation = mRotationList[i];
            mCallList.RemoveAt(i);

            try
            {
                if (!AssetManager.TryInstantiateGameObject(source, out asset, position, rotation))
                {
                    asset = source;
                }
                    
            }catch(Exception e)
            {
                Debugger.LogError("Asyn Call Back Asset is error! Asset path :" + path+",Error Message:"+e.StackTrace);
            }
            if(asset != null)callback(asset);
        }
        mPositionList.Clear();
        mRotationList.Clear();
        mCallList.Clear();
    }

    public void Dispose()
    {
        source = null;
    }
}