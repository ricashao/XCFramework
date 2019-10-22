using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using Object = UnityEngine.Object;
using System.Collections.Generic;
using System.Diagnostics;
using System;

public static class UIUnAttackTexture
{
    private static Dictionary<string, Sprite> sprites = null;

    [MenuItem("Assets/图集资源替换/图集-->散图")]
    public static void UpdateFolderTexture()
    {
        if(sprites != null)sprites.Clear();
        //string path = AssetDatabase.GetAssetPath(Selection.);
        string path = "";
        foreach (UnityEngine.Object obj in Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.Assets))
        {
            path = AssetDatabase.GetAssetPath(obj);
            if (!string.IsNullOrEmpty(path) && File.Exists(path))
            {
                path = Path.GetDirectoryName(path);
                break;
            }
        }
        if (path != "" && path.Contains("UI"))
        {
            LoadAllAsset();
            ProcessFolderAssets(path);
        }
        else
        {
            Debugger.LogError("选择的目录有问题");
        }
    }

    //[MenuItem("UITools/图集-->散图")]
    //public static void UpdateTexture()
    //{
    //    LoadAllAsset();
    //    LoadAllPrefabs();
    //}

    private static void LoadAllPrefabs()
    {
        Dictionary<string, string> config = GlobalEditorHelper.GetConfig();
        string spritePath = config[EditorConstData.UIPrefabPathKey];
        ProcessFolderAssets(spritePath);
    }

    private static void ProcessFolderAssets(string folder)
    {
        Debugger.Log("开始处理目录 图集-->散图 " + folder);
        List<string> allPrefabPath = GlobalEditorHelper.GetAssetsPathFileName(folder, "prefab", true);

        List<GameObject> allPrefabs = new List<GameObject>();
        foreach (var onePath in allPrefabPath)
        {
            //Debugger.Log("开始处理" + onePath);
            GameObject oldPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(onePath);
            GameObject newPrefab = GameObject.Instantiate(oldPrefab);
            UpdateOldPrefab(newPrefab);
            PrefabUtility.ReplacePrefab(newPrefab, oldPrefab);
            Editor.DestroyImmediate(newPrefab);
        }
        AssetDatabase.SaveAssets();

        Debugger.Log("所有散图替换完成");
    }

    private static void LoadAllAsset()
    {

        if (sprites != null && sprites.Count > 0) return;

        sprites = new Dictionary<string, Sprite>();
        string p1 = Application.dataPath + "/Resources/";
        string path = p1 + "UI";
        string[] extList = { "*.png" };
        foreach (string extension in extList)
        {

            string[] files = os.walk(path, extension);
            foreach (string file in files)
            {
                if (!file.Contains("GenAltas"))
                {
                    LoadFile(file, p1.Length);
                }
            }
        }

    }

    private static void LoadFile(string path, int pl)
    {
        path = path.Substring(pl);
        path = path.Substring(0, path.LastIndexOf("."));
        path = path.Replace("\\", "/");

        Sprite sp = Resources.Load<Sprite>(path);
        AddToDic(sp);
    }

    private static void AddToDic(Sprite sprite)
    {
        //for (int i = 0; i < objs.Length; i++)
        //{
        //    Sprite sp = objs[i] as Sprite;
            if (sprite != null)
            {
                string name = sprite.name;
                if (!name.Contains(".png"))
                {
                    name += ".png";
                }
            if (sprites.ContainsKey(name))
                {
                    Debugger.LogError("duplicate add key:" + name);
                }
                else
                {
                    sprites.Add(name, sprite);
                }
           }
        //}
    }

    private static T LoadAsset<T>(string path) where T : Object
    {
        return AssetDatabase.LoadAssetAtPath(path, typeof(T)) as T;
    }

    private static String paName = "";
    private static void UpdateOldPrefab(GameObject oldPrefab)
    {
        if (oldPrefab == null) return;

        Transform[] children = oldPrefab.GetComponentsInChildren<Transform>(true);
        for (int i = 0; i < children.Length; i++)
        {
            String p1 = "";
            Transform s = children[i];
            while (s.parent)
            {
                p1 = s.parent.name + "_" + p1;
                s = s.parent;
            }
            paName = p1 + children[i].name;
            DealOnChild(children[i]);

        }//---------------end for

    }

    private static void DealOnChild(Transform child)
    {
        //-----------Image
        Image img = child.gameObject.GetComponent<Image>();
        if (img && img.sprite)
        {
            string name = img.sprite.name;
           // Debugger.Log("找到需要替换的名字" + name);
            if (sprites.ContainsKey(name))
            {
                if (sprites[name] != null)
                {
                    Debugger.Log("replaced texture:" + name);
                    img.sprite = sprites[name];
                }
                else
                {
                    Debugger.Log("没有找到资源" + name);
                }
                
                
            }
        }
        RawImage rimg = child.gameObject.GetComponent<RawImage>();
        if (rimg && rimg.texture)
        {
            Debugger.LogWarning("find rawImage in prefab:  " + paName + "    " + child.name);
        }

        //------------UISpriteSwap
        UISpriteSwap script = child.gameObject.GetComponent<UISpriteSwap>();
        if (script != null && script.Spritelist.Count > 0)
        {
            for (int m = 0; m < script.Spritelist.Count; m++)
            {
                Sprite sp = script.Spritelist[m];
                if (sp != null && sprites.ContainsKey(sp.name))
                {
                    script.Spritelist[m] = sprites[sp.name];
                    Debugger.Log("replaced texture in UISpriteSwap:" + sp.name);
                }
            }
        }

        //--------------Button
        DealButton(child);

    }

    private static void DealButton(Transform child)
    {
        Button btn = child.gameObject.GetComponent<Button>();
        if (btn != null)
        {
            SpriteState state = new SpriteState();
            bool deal = false;
            if (btn.spriteState.disabledSprite != null)
            {
                deal = true;
                Sprite a = btn.spriteState.disabledSprite;
                if (sprites.ContainsKey(a.name))
                {
                    state.disabledSprite = sprites[a.name];
                    Debugger.Log("replaced texture in Button:" + a.name);
                }

            }
            if (btn.spriteState.highlightedSprite != null)
            {
                deal = true;
                Sprite a = btn.spriteState.highlightedSprite;
                if (sprites.ContainsKey(a.name))
                {
                    state.highlightedSprite = sprites[a.name];
                    Debugger.Log("replaced texture in Button:" + a.name);
                }

            }
            if (btn.spriteState.pressedSprite != null)
            {
                deal = true;
                Sprite a = btn.spriteState.pressedSprite;
                if (sprites.ContainsKey(a.name))
                {
                    state.pressedSprite = sprites[a.name];
                    Debugger.Log("replaced texture in Button:" + a.name);
                }

            }
            if (deal)
            {
                btn.spriteState = state;
            }
        }//end Button
    }
}