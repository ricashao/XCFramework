using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System;
using System.Text;

/// <summary>
/// 编辑器帮助类(已经存在一个EditorHelper,所以起了这个名字)
/// </summary>
public class GlobalEditorHelper
{
    /// <summary>
    /// 配置文件列数
    /// </summary>
    static int configColumnsCount = 2;
    /// <summary>
    /// csv分隔符
    /// </summary>
    static char csvSeparator = ',';

    /// <summary>
    /// 读取配置Csv表,创建配置数据字典
    /// </summary>
    /// <returns></returns>
    public static Dictionary<string, string> GetConfig()
    {
        Dictionary<string, string> result = new Dictionary<string, string>();
        CsvDataProcess(EditorConstData.ConfigPath, (oneLine) =>
        {
            string key = oneLine[0].Trim();
            //配置Key存在"目录"或者"路径"两个字,则表示需要修正路径
            result.Add(key, (key.Contains("目录") || key.Contains("路径")) ? RepairPath(oneLine[1]) : oneLine[1]);
        }, configColumnsCount);
        return result;
    }

    /// <summary>
    /// 获取一个文件夹下的子文件夹
    /// </summary>
    /// <param name="isDeepSearch">是否检索所有层级目录</param>
    /// <returns>返回路径是相对路径(Assets开始),还是绝对路径与rootPath相同</returns>
    public static List<string> GetDirectories(string rootPath, bool isDeepSearch = false)
    {
        rootPath = RepairPath(rootPath);
        List<string> result = new List<string>();
        string[] currentLevel = Directory.GetDirectories(rootPath);
        for (int i = 0; i < currentLevel.Length; i++)
        {
            result.Add(RepairPath(currentLevel[i]));
            if (isDeepSearch)
            {
                result.AddRange(GetDirectories(currentLevel[i], true));
            }
        }

        return result;
    }

    /// <summary>
    /// 连接路径,与Path的方法区别是得到的路径分隔符是"/"
    /// </summary>
    /// <returns></returns>
    public static string CompinePath(params string[] cells)
    {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < cells.Length; i++)
        {
            sb.AppendFormat("{0}/", RepairPath(cells[i]));
        }
        sb.Remove(sb.Length - 1, 1);
        return sb.ToString();
    }

    /// <summary>
    /// 将路径中的\全部换为/,如果以/结尾,则移除最后一个/
    /// </summary>
    /// <returns></returns>
    public static string RepairPath(string path)
    {
        string result = path.Replace('\\', '/');
        return result.TrimEnd('/');
    }

    /// <summary>
    /// 将Asset路径转化为Resources加载路径
    /// </summary>
    /// <param name="assetPath"></param>
    /// <returns></returns>
    public static string AssetPathToResourcesPath(string assetPath)
    {
        int index = assetPath.IndexOf("Resources");
        if (index > 0)
        {
            assetPath = assetPath.Substring(index + 10);
        }
        else
        {
            Debug.LogError("路径中未找到Resources文件夹,转换失败");
        }
        return assetPath;
    }

    /// <summary>
    /// 获取以Assets目录开始的文件路径(包括文件名和扩展名)
    /// </summary>
    /// <param name="dirPath">文件夹路径,从Assets下一级开始写</param>
    /// <param name="pattern">文件扩展名,给空或*则表示不限定扩展名</param>
    /// <param name="isDeepSearch">是否检索所有层级目录</param>
    /// <returns>返回的路径是从Assets开始的</returns>
    public static List<string> GetAssetsPathFileName(string dirPath, string pattern, bool isDeepSearch = false)
    {
        DirectoryInfo dirInfo = new DirectoryInfo(dirPath);
        if (string.IsNullOrEmpty(pattern))
        {
            pattern = "*";
        }
        FileInfo[] fileInfos = dirInfo.GetFiles("*." + pattern);
        List<string> result = new List<string>();
        for (int i = 0; i < fileInfos.Length; i++)
        {
            result.Add(fileInfos[i].FullName.Substring(fileInfos[i].FullName.IndexOf("Assets\\")));
        }
        if (isDeepSearch)
        {//深度检索对文件夹也处理
            DirectoryInfo[] sonDirs = dirInfo.GetDirectories();
            foreach (var oneDir in sonDirs)
            {
                result.AddRange(GetAssetsPathFileName(oneDir.FullName, pattern, true));
            }
        }
        return result;
    }
    /// <summary>
    ///  获取一个文件夹下面的文件名(不包含路径和扩展名)
    /// </summary>
    /// <param name="dirPath"></param>
    /// <param name="pattern"></param>
    /// <param name="isDeepSearch">是否检索所有层级目录</param>
    /// <returns></returns>
    public static List<string> GetSimpleFileName(string dirPath, string pattern, bool isDeepSearch = false)
    {
        if (pattern.StartsWith("."))
        {
            pattern = pattern.Remove(0, 1);
        }
        DirectoryInfo dirInfo = new DirectoryInfo(dirPath);
        FileInfo[] fileInfos = dirInfo.GetFiles("*." + pattern);
        List<string> result = new List<string>();
        for (int i = 0; i < fileInfos.Length; i++)
        {
            result.Add(Path.GetFileNameWithoutExtension(fileInfos[i].Name));
        }
        if (isDeepSearch)
        {//深度检索对文件夹也处理
            DirectoryInfo[] sonDirs = dirInfo.GetDirectories();
            foreach (var oneDir in sonDirs)
            {
                result.AddRange(GetSimpleFileName(oneDir.FullName, pattern, true));
            }
        }
        return result;
    }

    public static void ClearDirectory(string path)
    {
        string[] allFiles = Directory.GetFiles(path);
        foreach (var oneFile in allFiles)
        {
            File.Delete(oneFile);
        }
    }

    /// <summary>
    /// csv处理,给定一个csv路径,和处理方法,不会处理第一列为""的行
    /// </summary>
    /// <param name="csvPath">文件路径</param>
    /// <param name="process">处理方法</param>
    /// <param name="columnCount">csv列数,默认-1,不检测列数</param>
    /// <param name="startProcessRowIndex">开始处理的行索引,默认为1</param>
    public static void CsvDataProcess(string csvPath, Action<string[]> process, int columnCount = -1, int startProcessRowIndex = 1)
    {
        string[] allLines = GlobalEditorHelper.ReadAllLines(csvPath, columnCount);
        for (int i = startProcessRowIndex; i < allLines.Length; i++)
        {
            string[] oneRow = allLines[i].Split(csvSeparator);
            if (oneRow.Length > 0 && oneRow[0] != "")
            {
                process(oneRow);
            }
        }

    }


    /// <summary>
    /// 读取所有行数据,并在列数不符合是报错
    /// </summary>
    /// <param name="csvPath"></param>
    /// <param name="checkColumnCount"></param>
    /// <returns></returns>
    public static string[] ReadAllLines(string csvPath, int checkColumnCount = -1)
    {
        string[] result = File.ReadAllLines(csvPath, System.Text.Encoding.GetEncoding("gb2312"));

        if (checkColumnCount > 0)
        {
            int columnsCount = result[0].Split(',').Length;
            if (columnsCount != checkColumnCount)
            {
                Debug.LogErrorFormat("列数异常,文件路径{0},希望列数{1},实际列数{2}", csvPath, checkColumnCount, columnsCount);
            }
        }
        return result;
    }

    /// <summary>
    /// 重置Transform组件的数据
    /// </summary>
    /// <param name="tran"></param>
    public static void TransformReset(Transform tran)
    {
        tran.localPosition = Vector3.zero;
        tran.localEulerAngles = Vector3.zero;
        tran.localScale = Vector3.one;
    }

}