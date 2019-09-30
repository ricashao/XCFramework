using System;
using UnityEngine;

public interface IPool
{
    void Update();
    
    /// <summary>
    /// 获取对象
    /// </summary>
    /// <returns></returns>
    object GetObject(string key, Vector3 position, Quaternion rotation);
    object GetObject(Action<object> callback, Vector3 position, Quaternion rotation);
    
    /// <summary>
    /// 回收对象
    /// </summary>
    void Recycle(object obj);
    
    /// <summary>
    /// 清空池子
    /// </summary>
    void Clear();
    
    /// <summary>
    /// 销毁池子
    /// </summary>
    void Dispose();
    
    /// <summary>
    /// 设置池子大小
    /// </summary>
    /// <param name="value"></param>
    void SetSize(int value);
    
    /// <summary>
    /// 设置池子级别
    /// </summary>
    /// <param name="value"></param>
    void SetLevel(uint value);
    
    /// <summary>
    /// 设置池子生命周期
    /// </summary>
    /// <param name="value"></param>
    void SetLifeTime(float value);
    
    /// <summary>
    /// 最后使用时间
    /// </summary>
    float time { get; }
    /// <summary>
    /// 池子级别
    /// </summary>
    uint level { get; }
    /// <summary>
    /// 是否可以清空
    /// </summary>
    bool IsClearable { get;}
    /// <summary>
    /// 是否可以销毁
    /// </summary>
    bool IsDisposeable { get; }
    /// <summary>
    /// 是否没有被使用
    /// </summary>
    bool isUnused { get; }

    string id { get; }
}