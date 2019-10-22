using UnityEngine;
using System.Collections;

/// <summary>
/// 编辑器常量数据
/// </summary>
public static class EditorConstData
{
    /// <summary>
    /// 配置文件路径
    /// </summary>
    public static string ConfigPath = "Assets/Editor/Config/Config.csv";
    #region 配置数据的所有Key
    public static readonly string FbxDirKey = "fbx存放目录";
    public static readonly string AcDirKey = "ac生成目录";
    public static readonly string PrefabDirKey = "prefab生成目录";
    public static readonly string CutClipDirKey = "切动画配置目录";
    public static readonly string AcParamsDirKey = "ac参数配置目录";
    public static readonly string AcTranDirKey = "ac转换配置目录";
    public static readonly string StateCreateDirKey = "acState创建配置目录";
    public static readonly string SpriteDirKey = "精灵存放目录";
    public static readonly string ShadowModelPathKey = "影子模板路径";
    public static readonly string AMModelPathKey = "AM模板路径";
    public static readonly string PrefabConfigPathKey = "prefab配置文件路径";
    public static readonly string brushToolConfigPathKey = "刷数据工具配置文件路径";
    #endregion


    #region 刷工具的所有Key
    public static readonly string brushEffectPathKey = "刷精灵的目录";
    public static readonly string brushActPathKey = "刷角色预制的目录";
    public static readonly string clearPrimaryDataKey = "清除的目录";
    public static readonly string addPrimaryDataKey = "刷指定目录添加的目录";
    #endregion

    #region 图集工具的所有Key
    public static readonly string UIPrefabPathKey = "UIPrefab路径";
    #endregion

}
