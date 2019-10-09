using System;
using System.Collections;
using UnityEngine;


public class ioo
{
    private static Hashtable prefabs = new Hashtable();


    private static GameObject _manager = null;

    public static GameObject manager
    {
        get
        {
            if (_manager == null)
                _manager = GameObject.FindWithTag("GameMain");
            return _manager;
        }
    }

    private static GameMain _gameMain = null;

    public static GameMain gameMain
    {
        get
        {
            if (manager == null) return null;

            if (_gameMain == null)
                _gameMain = manager.GetComponent<GameMain>();
            return _gameMain;
        }
    }
    
    private static PanelManager _panelManager = null;
    public static PanelManager panelManager {
        get {
            if (_panelManager == null)
                _panelManager = manager.GetComponent<PanelManager>();
            return _panelManager;
        }
    }
    
    
    
    
    public static Transform guiCamera {
        get {
            GameObject go = GameObject.FindWithTag("GuiCamera");
            if (go != null) return go.transform;
            return null;
        }
    }

    public static GameObject guiRoot
    {
        get
        {
            var go = GameObject.FindWithTag("GuiRoot");
            if (go != null) return go;
            return null;
        }
    }
    public static GameObject effects
    {
        get
        {
            var go = GameObject.FindWithTag("Effects");
            if (go != null) return go;
            return null;
        }

    }

    public static int GetSystemTimeSecond()
    {
        return DateTime.Now.Second;
    }
}