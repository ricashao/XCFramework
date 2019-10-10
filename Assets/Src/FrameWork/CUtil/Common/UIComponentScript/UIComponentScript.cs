using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

public class UIComponentScript : MonoBehaviour
{

    public object uicomponent;
    // public string uiComponentName = string.Empty; //标记，方便查看
    public string componentType = string.Empty; //UIComponent 类型
    public List<PropsItem> componentProps = new List<PropsItem>();//属性列表
    
    public List<PropsItem> GetProps()
    {
        return componentProps;
    }

    protected void OnDestroy()
    {
        
    }
}
[System.Serializable]
public class PropsItem
{
    public string key;
    public string value;
}