using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public class AssetBundleTest : MonoBehaviour
{
    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 50), "加载login"))
        {
            AssetManager.LoadAsset("prefabs/win/win_login.ga", this.LoadAssetComplete);
        }
    }

    private void LoadAssetComplete(Object o)
    {
        var root = GameObject.Find("Root").transform;
        (((GameObject)o).transform as RectTransform).SetParent(root.transform as RectTransform,false);
    }
}
