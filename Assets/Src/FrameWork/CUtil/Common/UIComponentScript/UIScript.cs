using UnityEngine;
using System.Collections.Generic;

public class UIScript : MonoBehaviour 
{

    public GameObject Prefab;
    public string PrefabScriptName = string.Empty; //prefab固定的名字,方便修改挂载的prefab
    public List<ElementItem> Element = new List<ElementItem>();
}

[System.Serializable]
public class ElementItem
{
    public string key;
    public string value;
}