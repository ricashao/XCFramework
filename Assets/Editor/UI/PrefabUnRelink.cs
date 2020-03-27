using UnityEngine;
using UnityEngine.UI;
using UnityEditor;
using System.IO;
using Object = UnityEngine.Object;
using System.Collections.Generic;
using System;
using System.Linq;

public static class UIUnAttackTexture
{
    private static Dictionary<string, Sprite> sprites = null;

    [MenuItem("Assets/图集资源替换/散图-->图集")]
    public static void UpdateFolderTexture()
    {
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
            Debug.LogError("选择的目录有问题");
        }
    }

    [MenuItem("XCFramework/ui工具/sprite刷新所有prefab")]
    public static void UpdateTexture()
    {
        LoadAllAsset();
        LoadAllPrefabs();
    }

    private static void LoadAllPrefabs()
    {
        string spritePath = EditorHelper.UIPrefabsPath;
        ProcessFolderAssets(spritePath);
    }

    /// <summary>
    /// 处理当前文件夹下的uiprefab 散图替换图集
    /// </summary>
    /// <param name="folder"></param>
    private static void ProcessFolderAssets(string folder)
    {
        Debug.Log("开始处理目录 散图-->图集 " + folder);
        List<string> allPrefabPath = os.walkAssets(folder, "*.prefab").ToList();

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

        Debug.Log("所有散图替换完成");
    }

    /// <summary>
    /// 搜集制作界面用的所有ui资源
    /// </summary>
    private static void LoadAllAsset()
    {
        if (sprites != null && sprites.Count > 0) return;

        sprites = new Dictionary<string, Sprite>();
        string path = EditorHelper.UISpritesPath;
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
        Sprite sp = AssetDatabase.LoadAssetAtPath<Sprite>(path);
        AddToDic(sp);
    }

    private static void AddToDic(Sprite sprite)
    {
        if (sprite != null)
        {
            string name = sprite.name;
            if (!name.Contains(".png"))
            {
                name += ".png";
            }

            if (sprites.ContainsKey(name))
            {
                Debug.LogError("duplicate add key:" + name);
            }
            else
            {
                sprites.Add(name, sprite);
            }
        }
    }


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
            // Debugger.Log("找到需要替换的名字" + name);
            if (sprites.ContainsKey(name))
            {
                if (sprites[name] != null)
                {
                    Debug.Log("replaced texture:" + name);
                    img.sprite = sprites[name];
                }
                else
                {
                    Debug.Log("没有找到资源" + name);
                }
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