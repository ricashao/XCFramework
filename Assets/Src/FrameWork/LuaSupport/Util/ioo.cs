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
}