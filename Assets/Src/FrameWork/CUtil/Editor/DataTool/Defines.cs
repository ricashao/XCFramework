using NUnit.Framework;
using UnityEditor.PackageManager;

public class ProDefine
{
     /// <summary>
     /// 名称
     /// </summary>
     public string name;

     /// <summary>
     /// 描述
     /// </summary>
     public string desc;

     /// <summary>
     /// 默认值
     /// </summary>
     public object def;

     /// <summary>
     /// 是否导出客户端数据
     /// </summary>
     public int client;

     /// <summary>
     /// 是否导出服务端数据
     /// </summary>
     public int server;
     
     public TypeChecker checker;

     public string type;

}

public abstract class TypeChecker
{
     public string type;

     public int idx;

     public abstract object Check(string value);

}