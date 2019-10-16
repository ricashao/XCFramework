using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEditor;

public class ExportDataTable : EditorWindow
{
    protected static ExportDataTable instance;
    string path;
    Rect rect;
    private StringBuilder log;
    private StringBuilder clientCode;

    [MenuItem("KCFramework/ExcelTool/Gen Data Table")]
    static void CreateDataToolPanel()
    {
        ExportDataTable panel;
        if ((UnityEngine.Object) ExportDataTable.instance == (UnityEngine.Object) null)
        {
            panel = EditorWindow.GetWindow<ExportDataTable>();
            panel.Show();
        }
        else
        {
            panel = ((ExportDataTable) ExportDataTable.instance);
            panel.Show();
        }
    }


    private void Awake()
    {
        log = new StringBuilder();
        clientCode = new StringBuilder();
    }

    void OnGUI()
    {
        if (EditorApplication.isCompiling)
        {
            return;
        }

        CoreStyle.Update();
        this.Init();
        using (new GUIHelper.Vertical(out rect, new GUILayoutOption[2]
        {
            GUILayout.ExpandWidth(true),
            GUILayout.ExpandHeight(true)
        }))
        {
            //基本数据显示
            using (new GUIHelper.Horizontal(CoreStyle.area, new GUILayoutOption[2]
            {
                GUILayout.ExpandWidth(true),
                GUILayout.Height(50f)
            }))
            {
                GUILayout.Label("客户端项目路径:" + Application.dataPath);
                isGenClient = GUILayout.Toggle(isGenClient, "生成代码");
            }

            GUILayout.Label("Log:");
            using (logScroll.Start())
            {
                GUILayout.Label(log.ToString());
            }

            GUILayout.Label("ClientCode:");
            using (codeScroll.Start())
            {
                GUILayout.Label(clientCode.ToString());
            }
        }

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
                this.OnDrop(DragAndDrop.paths);
            }
        }

        if ((Event.current.type == EventType.ContextClick)
            && rect.Contains(Event.current.mousePosition))
        {
            menu.ShowAsContext();
            Event.current.Use();
        }
    }

    private void Init()
    {
        if (log == null)
        {
            log = new StringBuilder();
        }

        if (clientCode == null)
        {
            clientCode = new StringBuilder();
        }

        if (logScroll == null)
            logScroll = new GUIHelper.Scroll(CoreStyle.area, new GUILayoutOption[2]
            {
                GUILayout.ExpandWidth(true),
                GUILayout.Height(300)
            });

        if (codeScroll == null)
            codeScroll = new GUIHelper.Scroll(CoreStyle.area, new GUILayoutOption[2]
            {
                GUILayout.ExpandWidth(true),
                GUILayout.ExpandHeight(true)
            });

        if (menu == null)
        {
            menu = new GenericMenu();
            menu.AddItem(new GUIContent("Clear Log"), false, this.ClearLog);
            menu.AddItem(new GUIContent("Clear ClientCode"), false, this.ClearClientCode);
//            menu.AddSeparator("");
//            menu.AddItem(new GUIContent("Test Add Log"), false, () => { this.log.Append("\n"); });
        }
    }


    private void OnDrop(string[] paths)
    {
        //目前只做单个文件拖拽不做文件夹
        string path = paths[0];
        FileInfo info = new FileInfo(path);
        if (info.Extension == ".xlsx")
        {
            XLSXDecoder.Decode(info, isGenClient);
        }
    }

    public void Log(string msg, string type = "")
    {
        log.Append(type + msg + "\n");
    }


    private void ClearLog()
    {
        this.log.Clear();
    }

    private void ClearClientCode()
    {
        clientCode.Clear();
    }

    private GenericMenu menu;

    private Boolean isGenClient = true;

    private GUIHelper.Scroll logScroll;
    private GUIHelper.Scroll codeScroll;
}