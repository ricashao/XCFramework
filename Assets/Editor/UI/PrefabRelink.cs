using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using Object = UnityEngine.Object;
using System.Collections.Generic;
using System;
using System.Linq;

public static class UIReAttackTexture
{
    private static Dictionary<string, Sprite> sprites = null;

    [MenuItem("Assets/图集资源替换/图集-->散图")]
    public static void UpdateFolderTexture()
    {
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
            Debug.LogError("选择的目录有问题");
        }
    }

    [MenuItem("XCFramework/ui工具/图集刷新所有prefab",false,3)]
    public static void UpdateTexture()
    {
        LoadAllAsset();
        LoadAllPrefabs();
    }

    private static void LoadAllPrefabs()
    {
        string prefabPath = EditorHelper.UIPrefabsPath;
        ProcessFolderAssets(prefabPath);
    }

    /// <summary>
    /// 图集替换ui上的散图资源
    /// </summary>
    /// <param name="folder"></param>
    private static void ProcessFolderAssets(string folder)
    {
        Debug.Log("开始替换散图资源  图集-->散图" + folder);
        string[] allPrefabPath = os.walkAssets(folder, "*.prefab");
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

        Debug.Log("所有图集替换散图完成");
    }


    //获取所有的图集
    private static void LoadAllAsset()
    {
        if (sprites != null && sprites.Count > 0) return;

        sprites = new Dictionary<string, Sprite>();
        
        string path = EditorHelper.UIGenAtlasPath;
        string[] extList = {"*.png"};
        foreach (string extension in extList)
        {
            string[] files = os.walkAssets(path, extension);
            foreach (string file in files)
            {
                LoadFile(file);
            }
        }
    }

    private static void LoadFile(string path)
    {
        Sprite[] objs = AssetDatabase.LoadAllAssetsAtPath(path).OfType<Sprite>().ToArray();
        AddToDic(objs);
    }

    private static void AddToDic(Sprite[] objs)
    {
        for (int i = 0; i < objs.Length; i++)
        {
            Sprite sp = objs[i];
            if (sp != null && objs[i].name.Contains("."))
            {
                string name = objs[i].name.Substring(0, objs[i].name.LastIndexOf("."));
                if (sprites.ContainsKey(name))
                {
                    Debug.LogError("duplicate add key:" + name);
                }
                else
                {
                    sprites.Add(name, sp);
                }
            }
        }
    }

    private static void UpdateOldPrefab(GameObject oldPrefab)
    {
        if (oldPrefab == null) return;

        int count = oldPrefab.transform.childCount;
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

            var paName = p1 + children[i].name;
            DealOnChild(children[i], paName);
        } //---------------end for
    }

    private static void DealOnChild(Transform child, string paName)
    {
        //-----------Image
        Image img = child.gameObject.GetComponent<Image>();
        if (img && img.sprite)
        {
            string name = img.sprite.name;
            if (sprites.ContainsKey(name))
            {
                img.sprite = sprites[name];
                Debug.Log("replaced texture:" + name);
            }
        }

        RawImage rimg = child.gameObject.GetComponent<RawImage>();
        if (rimg && rimg.texture)
        {
            Debug.LogWarning("find rawImage in prefab:  " + paName + "    " + child.name);
        }

        //------------UISpriteSwap
//        UISpriteSwap script = child.gameObject.GetComponent<UISpriteSwap>();
//        if (script != null && script.Spritelist.Count > 0)
//        {
//            for (int m = 0; m < script.Spritelist.Count; m++)
//            {
//                Sprite sp = script.Spritelist[m];
//                if (sp != null && sprites.ContainsKey(sp.name))
//                {
//                    script.Spritelist[m] = sprites[sp.name];
//                    Debug.Log("replaced texture in UISpriteSwap:" + sp.name);
//                }
//            }
//        }

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
                    Debug.Log("replaced texture in Button:" + a.name);
                }
            }

            if (btn.spriteState.highlightedSprite != null)
            {
                deal = true;
                Sprite a = btn.spriteState.highlightedSprite;
                if (sprites.ContainsKey(a.name))
                {
                    state.highlightedSprite = sprites[a.name];
                    Debug.Log("replaced texture in Button:" + a.name);
                }
            }

            if (btn.spriteState.pressedSprite != null)
            {
                deal = true;
                Sprite a = btn.spriteState.pressedSprite;
                if (sprites.ContainsKey(a.name))
                {
                    state.pressedSprite = sprites[a.name];
                    Debug.Log("replaced texture in Button:" + a.name);
                }
            }

            if (deal)
            {
                btn.spriteState = state;
            }
        } //end Button
    }
}