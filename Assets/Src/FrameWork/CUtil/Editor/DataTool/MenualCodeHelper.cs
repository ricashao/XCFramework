using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;

public class MenualCodeHelper
{
    private static Dictionary<string, string> ManualCodeDefaultComment = new Dictionary<string, string>()
    {
        {"$area1", "--这里填写类上方的require内容"},
        {"$area2", "--这里填写类里面的手写内容"},
        {"$area3", "--这里填写类下发的手写内容"},
        {"$decode", "--这里填写方法中的手写内容"}
    };

    private static Regex reg =
        new Regex(@"[-][-][/][*]-[*]begin[ ]([$]?[a-zA-Z0-9]+)[*]-[*][/]([\s\S]*)[-][-][/][*]-[*]end[ ]\1[*]-[*][/]");

    /// <summary>
    /// 获取手动写的代码信息
    /// </summary>
    /// <param name="luaPath"></param>
    public static Dictionary<string, string> GetManualCodeInfo(string luaPath)
    {
        var result = new Dictionary<string, string>();
        if (File.Exists(luaPath))
        {
            string content = File.ReadAllText(luaPath);
            var mc = reg.Matches(content);
            foreach (Match match in mc)
            {
                var key = match.Groups[1].Value;
                var manual = match.Groups[2].Value.Trim();
                if (string.IsNullOrEmpty(manual))
                {
                    continue;
                }
                else if (ManualCodeDefaultComment.ContainsKey(key))
                {
                    if (ManualCodeDefaultComment[key] == manual)
                    {
                        continue;
                    }

                    result[key] = manual.Trim('\n');
                }
                else
                {
                    break;
                }
            }
        }

        return result;
    }

    public static string GenManualAreaCode(string key, Dictionary<string, string> cinfo)
    {
        var manual = "";
        if (!cinfo.ContainsKey(key))
        {
            if (ManualCodeDefaultComment.ContainsKey(key))
            {
                manual = ManualCodeDefaultComment[key];
            }
            else
            {
                Debug.LogError("错误的区域标识"+key);
            }
        }
        else
        {
            manual = cinfo[key];
        }

        return string.Format("--/*-*begin {0}*-*/\n{1}\n--/*-*end {2}*-*/", key, manual, key);
    }
}