using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ExportDataTable : EditorWindow
{
    string path;
    Rect rect;
    public GUIStyle centeredMiniLabel;

    [MenuItem("KCFramework/ExcelTool/Gen Data Table")]
    static void Init()
    {
        EditorWindow.GetWindow(typeof(ExportDataTable));
    }

    private void Awake()
    {
        centeredMiniLabel = new GUIStyle(EditorStyles.centeredGreyMiniLabel);
        centeredMiniLabel.normal.textColor = EditorStyles.label.normal.textColor;
    }

    void OnGUI()
    {
        
        if (EditorApplication.isCompiling)
        {
            GUILayout.Label("Compiling...", centeredMiniLabel,
                GUILayout.ExpandHeight(true), GUILayout.ExpandWidth(true));
        }
        else
        {
            EditorGUILayout.LabelField("路径");
            //获得一个长300的框
            rect = EditorGUILayout.GetControlRect(GUILayout.Width(300));
            //将上面的框作为文本输入框
            path = EditorGUI.TextField(rect, path);

            if ((Event.current.type == EventType.DragUpdated)
                && rect.Contains(Event.current.mousePosition))
            {
                //改变鼠标的外表
                DragAndDrop.visualMode = DragAndDropVisualMode.Generic;
            }

            //如果鼠标正在拖拽中或拖拽结束时，并且鼠标所在位置在文本输入框内
            if ((Event.current.type == EventType.DragExited)
                && rect.Contains(Event.current.mousePosition))
            {
                if (DragAndDrop.paths != null && DragAndDrop.paths.Length > 0)
                {
                    path = DragAndDrop.paths[0];
                    Debug.Log(path);
                }
            }
        }
    }
}