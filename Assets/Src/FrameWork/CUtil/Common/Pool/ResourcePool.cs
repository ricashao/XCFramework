using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

public class ResourcePool : IPool
{
    private Type mType;

    private int mSourceCount = 0;

    //池子大小
    private int mSize = 1;

    //最新使用时间
    private float mTime = 0;

    private float mLifeTime = DefaultLifeTime; //生命周期

    private const float DefaultLifeTime = 1800; //默认生命周期，单位：秒

    private uint mLevel = 0; //池子等级

    private int mLayer = 0;

    private string mId;

    private List<Object> mAsynTargets = new List<Object>();

    private List<Action<object>> mCallBacks = new List<Action<object>>();

    public event Action<ResourcePool, object> AsynLoadCompleted;


    private List<Object> stack = new List<Object>();

    public ResourcePool(string pathValue, string assetNameValue, int sizeValue, uint levelValue)
    {
        path = pathValue;
        assetName = assetNameValue;

        SetSize(sizeValue);
        SetLevel(levelValue);
    }

    public void Update()
    {
        if (mAsynTargets.Count > 0)
        {
            OnLoadComplete(mAsynTargets[0]);
            mAsynTargets.RemoveAt(0);
        }
    }

    private void OnLoadComplete(Object result)
    {
        mSourceCount++;
        // Debugger.Log("资源引用计数增加为：" + mSourceCount+ " " + path);
        SaveState(result);

        if (!(result is GameObject))
            source = result;

        if (AsynLoadCompleted != null)
        {
            AsynLoadCompleted(this, result);
        }

        if (mCallBacks.Count > 0)
        {
            mCallBacks[0](result);

            mCallBacks.RemoveAt(0);
        }
    }

    private void SaveState(Object target)
    {
        if (target != null)
        {
            if (target is GameObject)
                mLayer = (target as GameObject).layer;

            mType = target.GetType();
        }
    }

    public object GetObject(string key, Vector3 position, Quaternion rotation)
    {
        Action<object> callBack = null;
        if (!string.IsNullOrEmpty(key))
        {
            try
            {
                callBack = (s) => LuaScriptMgr.Instance.CallLuaFunction("AsynPrefabLoader.CallFromCS", key, path, s);
            }
            catch
            {
                Debugger.LogError("ResourcePool Error: Not Find LuaFunction,path=" + path + ",key=" + key);
            }
        }

        return GetObject(callBack, position, rotation);
    }

    public object GetObject(Action<object> callback, Vector3 position, Quaternion rotation)
    {
        Object target = null;

        if (source == null)
        {
            while (stack.Count > 0)
            {
                target = stack[0];

                stack.RemoveAt(0);

                if (target) break;
            }

            if (target == null) //池子里没有资源
            {
                if (callback != null)
                {
                    mCallBacks.Add(callback);
                    AssetManager.LoadAsset(path, assetName, OnLoadComplete, position, rotation);
                }
                else
                {
                    target = AssetManager.LoadAsset(path, assetName);
                }
                // Debugger.Log("开始加载资源 " + path);

                SaveState(target);
            }
            else if (callback != null)
            {
                mCallBacks.Add(callback);
                mAsynTargets.Add(target);
            }

            Reset(target as GameObject, false);
        }
        else
        {
            target = source;
            if (callback != null)
            {
                mCallBacks.Add(callback);
                mAsynTargets.Add(target);
            }
            else
            {
                Debugger.LogError("ResourcePool Error: Sync load's Asset Must is GameObject! Path:" + path +
                                  ",AssetName:" + assetName);
            }
        }

        return target;
    }

    private void Reset(GameObject target, bool isDestroy)
    {
        if (target == null) return;

        Transform transform = target.transform;
        Vector3 position = transform.localPosition;
        target.layer = mLayer;

        if (isDestroy)
        {
            transform.SetParent(PoolManager.poolContainer.transform);
            transform.gameObject.SetActive(false);
        }
        else
        {
            transform.SetParent(null);
            transform.gameObject.SetActive(true);
        }

        transform.localPosition = position;
    }


    public void Recycle(object target)
    {
        if (target == null || !(target is Object)) return;

        if (isGameObject)
        {
            //回收
            if (stack.Count < mSize)
            {
                mTime = Time.time;

                stack.Add(target as Object);

                Reset(target as GameObject, true);
            }
            else
            {
                //超过池子大小直接destroy
                GameObject.Destroy(target as Object);
            }
        }
    }

    public void Clear()
    {
        Object target;
        while (stack.Count > 0)
        {
            target = stack[0];
            if (target)
                MonoBehaviour.Destroy(target);
            stack.RemoveAt(0);
        }
    }

    public void Dispose()
    {
        Object target;
        while (stack.Count > 0)
        {
            target = stack[0];
            if (target)
                MonoBehaviour.Destroy(target);
            stack.RemoveAt(0);
        }

        if (source)
        {
            MonoBehaviour.Destroy(source);
            source = null;
            mSourceCount = 0;
        }

        mCallBacks.Clear();

        AsynLoadCompleted = null;
    }

    /// <summary>
    /// 设置生命周期
    /// </summary>
    /// <param name="value"></param>
    public void SetLifeTime(float value)
    {
        mLifeTime = value;
    }

    /// <summary>
    /// 设置级别
    /// </summary>
    /// <param name="value"></param>
    public void SetLevel(uint value)
    {
        mLevel = value;

        SetLifeTime(DefaultLifeTime * (value + 1));
    }

    /// <summary>
    /// 初始化对象池大小
    /// </summary>
    /// <param name="value"></param>
    public void SetSize(int value)
    {
        mSize = value;
    }

    public float time
    {
        get { return mTime; }
    }

    public uint level
    {
        get { return mLevel; }
    }

    /// <summary>
    /// 池子容量
    /// </summary>
    public int size
    {
        get { return mSize; }
    }


    public bool IsClearable
    {
        get
        {
            if (isGameObject)
            {
                return Time.time - mTime >= mLifeTime && stack.Count > 0;
            }

            return false;
        }
    }

    public bool IsDisposeable
    {
        get
        {
            if (isGameObject)
            {
                return Time.time - mTime >= mLifeTime && stack.Count >= mSize && mCallBacks.Count == 0;
            }

            return source == null || (Time.time - mTime >= mLifeTime && mSourceCount == 0);
        }
    }

    public bool isUnused
    {
        get
        {
            if (isGameObject)
            {
                return stack.Count >= mSize;
            }

            return source == null || mSourceCount == 0;
        }
    }

    public bool isGameObject
    {
        get { return mType == typeof(GameObject); }
    }


    public string id
    {
        get { return mId ?? (mId = GetID(path, assetName)); }
    }


    public string path { get; private set; }

    public string assetName { get; private set; }

    private Object source; //缓存非GameObject的源资源

    public static string GetID(string path, string assetName)
    {
        return Util.GetResourceID(path, assetName);
    }
}