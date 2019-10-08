/**
    图集资源管理器
*/

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

public class ImageSetManager : MonoBehaviour
{
    //图集资源
    private static Dictionary<string, ImageSet> _imagesets = new Dictionary<string, ImageSet>();
    //保持索引
    private static Dictionary<object, string> _objectRef = new Dictionary<object, string>();
   
    //检测资源释放的时间
    private static float CHECK_GC_TIME = 15f;

    /**从图集中获取一个sprite
       @param path 图集资源的路径
       @param name sprite的名字
       @param key  lua传过来的key值
    */
    public static void GetImageSprite(string path, string name, string key)
    {
        if (!_imagesets.ContainsKey(path))
        {
            ImageSet imgeSet = new ImageSet(path);
            imgeSet.Load(path);
            _imagesets[path] = imgeSet;
        }
        _imagesets[path].GetImage(name, key);
        instance.StartCheckGC();
    }

    public static void ReturnImageSprite(Object image)
    {
        string path = null;
        _objectRef.TryGetValue(image, out path);

        if (path != null)
        {
            ImageSet imageSet = null;
            _imagesets.TryGetValue(path, out imageSet);
            if (imageSet != null)
            {
                imageSet.ReturnImage(image);
            }
        }
    }

    public static bool CheckImageSetGc()
    {
        var imageSets = _imagesets.GetEnumerator();
        List<String> list = null;
        while (imageSets.MoveNext())
        {
            string path = imageSets.Current.Key;
            ImageSet imageSet = imageSets.Current.Value;
            if (imageSet.CanDestroy())
            {
                if(list == null)
                {
                    list = new List<string>();
                }
                imageSet.Destroy();
                list.Add(path);
            }
        }
        if (list != null)
        {
            for (int i = 0; i < list.Count; i++)
            {
                _imagesets.Remove(list[i]);
            }
        }
        return false;
    }

    //===================================================
    // 资源加载和整理模块
    //==================================================
    class ImageSet
    {
        public string path = string.Empty;
        public Dictionary<string, Sprite> images;
        public int refCount = 0;
        private Dictionary<string, List<string>> callBacks;
        private float lastUseTime;

        public ImageSet(string atlasImagePath)
        {
            path = atlasImagePath;
            callBacks = new Dictionary<string, List<string>>();
        }

        public Object GetImage(string name, string key)
        {
            if (images != null)
            {
                if (images.ContainsKey(name))
                {
                    CallLua(images[name], key, name);
                }
                else
                {
                    Debugger.LogError("在图集中没有找到资源" + name);
                }
            }
            else
            {
                if (!callBacks.ContainsKey(name))
                {
                    callBacks[name] = new List<string>();
                }
                callBacks[name].Add(key);
            }
            lastUseTime = Time.time;
            return null;
        }

        public void ReturnImage(Object image)
        {
            refCount--;
        }

        public void Load(string atlasImagePath)
        {
            AssetManager.LoadAltasAsset(atlasImagePath, OnAltasImageLoaded);
        }

        private void OnAltasImageLoaded(Object atlasimage)
        {
            images = new Dictionary<string, Sprite>();
            Sprite[] sps = (atlasimage as SpritesObject).sprites;
            foreach (Sprite sp in sps)
            {
                images[sp.name] = sp;
            }

            var assetNames = callBacks.GetEnumerator();
            string assetName;
            List<string> items;
            while (assetNames.MoveNext())
            {
                assetName = assetNames.Current.Key;
                items = assetNames.Current.Value;
                if (images.ContainsKey(assetName))
                {
                    for (int j = 0; j < items.Count; j++)
                    {
                        CallLua(images[assetName], items[j], assetName);
                    }
                }
                else
                {
                    Debugger.LogError("在图集中没有找到资源" + assetName);
                }
            }
            assetNames.Dispose();
            callBacks.Clear();
        }


        public int GetRefCount()
        {
            return refCount;
        }

        public void CallLua(Sprite sprite, string key, string assetName)
        {
            if (ioo.gameMain != null && ioo.gameMain.xluaMgr != null)//此时umgr有可能是空值
            {
                refCount++;
                _objectRef[sprite] = path;
                ioo.gameMain.xluaMgr.CallLuaFunction("UIManager.OnImageLoaded", sprite, key, assetName);
            }

        }

        public bool CanDestroy()
        {
            if (GetRefCount() == 0 && Time.time - lastUseTime > 10f)
            {
                return true;
            }
            return false;
        }

        public void Destroy()
        {
            foreach (var item in images)
            {
                _objectRef.Remove(item.Value);
            }
        }
    }

    //==================================================
    //    资源回收检测模块
    //==================================================
    private static ImageSetManager mInstance;
    void Awake()
    {
        mInstance = this;
    }

    public static ImageSetManager instance
    {
        get
        {
            if (mInstance == null)
            {
                GameObject obj = new GameObject("ImageSetManager");
                mInstance = obj.AddComponent<ImageSetManager>();
            }
            return mInstance;
        }
    }

    private static IEnumerator mGCAtor;
    public void StartCheckGC()
    {
        if (mGCAtor == null)
        {
            mGCAtor = CheckGC();
            StartCoroutine(mGCAtor);
        }
    }

    private void StopCheckGC()
    {
        if (mGCAtor != null)
        {
            StopCoroutine(mGCAtor);

            mGCAtor = null;
        }
    }

    IEnumerator CheckGC()
    {
        while (true)
        {
            yield return new WaitForSeconds(CHECK_GC_TIME);
            if (CheckImageSetGc())
            {
                StopCheckGC();
                break;
            }
        }
    }
}

public class SpritesObject : Object
{
    public Sprite[] sprites;
    public string path;
}
