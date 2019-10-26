using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InputFieldEvent : MonoBehaviour
{
    private const string ON_VALUE_CHANGE = ".OnValueChange";
    private const string ON_END_EDIT = ".OnEndEdit";
    private const string ON_SUBMIT = ".OnSubmit";
    
    private InputField inputField;
    private string key = String.Empty;
    private bool enterPress = false;
    private string eventType = String.Empty;
    
    public void SetKey(string key)
    {
        this.key = key;
    }

    private void Start()
    {
        inputField = GetComponent<InputField>();

        if (inputField)
        {
            inputField.onValueChange.AddListener(delegate { OnValueChange(); });
            inputField.onEndEdit.AddListener(delegate { OnEndEdit(); });
        }
    }
    
    private void OnValueChange()
    {
        eventType = ON_VALUE_CHANGE;
        CallMethond();
    }

    private void OnEndEdit()
    {
        eventType = ON_END_EDIT;
        CallMethond();
    }

    private void CallMethond()
    {
        if (ioo.gameMain.xluaMgr != null && eventType != String.Empty)
        {
            string func = (key == String.Empty ? name : key) + eventType;

            ioo.gameMain.xluaMgr.CallLuaFunction(func, inputField.text);
        }
    }
    
    private void Update()
    {
        if (inputField)
        {
            if (Input.GetKeyDown(KeyCode.Return))
            {
                enterPress = true;
            }

            if (Input.GetKeyUp(KeyCode.Return) && enterPress)
            {
                enterPress = false;
                eventType = ON_SUBMIT;
                CallMethond();
            }
        }
    }
}
