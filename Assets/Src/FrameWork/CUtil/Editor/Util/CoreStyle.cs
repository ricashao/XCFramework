using System;
using UnityEditor;
using UnityEngine;

public static class CoreStyle
{
    public static GUIStyle area;

    /// <summary>
    /// 初始化标志位
    /// </summary>
    private static bool initialized = false;

    [InitializeOnLoadMethod]
    private static void OnLoad()
    {
        EditorApplication.update += new EditorApplication.CallbackFunction(CoreStyle.Update);
    }

    public static void Update()
    {
        if (CoreStyle.initialized)
            return;
        CoreStyle.Initialize();
    }

    public static void Initialize()
    {
        
        try
        {
            CoreStyle.area = new GUIStyle(EditorStyles.textArea);
            CoreStyle.area.border = new RectOffset(4, 4, 5, 3);
            CoreStyle.area.margin = new RectOffset(2, 2, 2, 2);
            CoreStyle.area.padding = new RectOffset(4, 4, 4, 4);

        }
        catch (Exception ex)
        {
            return;
        }
    }
}