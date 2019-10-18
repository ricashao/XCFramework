using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using LitJson;
using OfficeOpenXml;
using UnityEditor;
using UnityEngine;

public class XLSXDecoder
{
    public static void Decode(FileInfo fileInfo, Boolean isGenCode)
    {
        var window = (ExportDataTable) EditorWindow.GetWindow<ExportDataTable>();
        string nodeName = fileInfo.Name.TrimEnd(fileInfo.Extension.ToCharArray());

        //通过ExcelPackage打开文件
        ExcelPackage package = new ExcelPackage(fileInfo);
        ExcelWorksheet worksheet = package.Workbook.Worksheets[nodeName];
        if (worksheet == null)
        {
            window.Log("表的sheetname有误", "error:");
            return;
        }

        var maxRow = worksheet.Dimension.End.Row;
        var maxCol = worksheet.Dimension.End.Column;
        var rowCfgs = new Dictionary<string, string>()
        {
            {"支持的数据类型", null},
            {"程序配置说明", null},
            {"程序配置内容", "cfgRow"},
            {"前端解析", "clientRow"},
            {"后端解析", "serverRow"},
            {"默认值", "defaultRow"},
            {"数据类型", "typeRow"},
            {"描述", "desRow"},
            {"属性名称", "nameRow"}, //必须为配置的最后一行
        };
        /**
         * 数据起始行
         */
        var dataRowStart = 1;
        var rowCfgLines = new Dictionary<string, int>();
        for (var i = 1; i <= maxRow; i++)
        {
            var col1 = worksheet.Cells[i, 1].Text;
            if (rowCfgs.ContainsKey(col1))
            {
                var key = rowCfgs[col1];
                if (key != null)
                {
                    rowCfgLines[key] = i;
                    if (key == "nameRow")
                    {
                        dataRowStart = i + 1;
                        break;
                    }
                }
            }
        }

        // 配置列
        ExcelRow cfgRow = worksheet.Row(rowCfgLines["cfgRow"]);
        if (cfgRow == null)
        {
            window.Log("表的配置有误，没有 程序配置内容这一行", "error:");
            return;
        }

        if (dataRowStart == 0)
        {
            window.Log("表的配置有误，没有配置使用原始值，并且没有 属性名称这一行", "error");
            return;
        }

        var cfilePackage = worksheet.Cells[cfgRow.Row, 4].Text; //|| parent; 不处理没填的情况
        /**
         * 前端是否解析此数据
         */
        var clientRow = worksheet.Row(rowCfgLines["clientRow"]);
        /**
         * 后端是否解析此数据
         */
        var serverRow = worksheet.Row(rowCfgLines["serverRow"]);

        var defaultRow = worksheet.Row(rowCfgLines["defaultRow"]);

        /**
        * 类型列
        */
        var typeRow = worksheet.Row(rowCfgLines["typeRow"]);
        /**
         * 描述列
         */
        var desRow = worksheet.Row(rowCfgLines["desRow"]);
        /**
         * 属性名称列
         */
        var nameRow = worksheet.Row(rowCfgLines["nameRow"]);
        var checks = TypeCheckers.checkers;
        var defines = new Dictionary<int, ProDefine>();
        for (var i = 2; i <= maxCol; i++)
        {
            var name = worksheet.Cells[nameRow.Row, i].Text;
            if (string.IsNullOrEmpty(name)) continue;
            var client = worksheet.Cells[clientRow.Row, i].Text;
            var isClient = string.IsNullOrEmpty(client) ? 0 : Int32.Parse(client);
            var server = worksheet.Cells[serverRow.Row, i].Text;
            var isServer = string.IsNullOrEmpty(server) ? 0 : Int32.Parse(server);
            var type = worksheet.Cells[typeRow.Row, i].Text;
            var checker = checks[type];
            var desc = worksheet.Cells[desRow.Row, i].Text;

            var def = worksheet.Cells[defaultRow.Row, i].Text;
            var prodefine = new ProDefine()
            {
                client = isClient,
                server = isServer,
                type = type,
                checker = checker,
                def = def,
                desc = desc,
                name = name
            };
            defines.Add(i, prodefine);
        }

        var cdatas = new ArrayList();
        var sdatas = new ArrayList();
        // 从第9行开始，是正式数据
        for (var row = dataRowStart; row <= maxRow; row++)
        {
            var cRow = new ArrayList();
            var sRow = new ArrayList();
            for (var col = 2; col <= maxCol; col++)
            {
                try
                {
                    ProDefine def = null;
                    defines.TryGetValue(col, out def);
                    if (def == null) continue;
                    var cellData = worksheet.Cells[row, col].Text;
                    var data = def.checker.Check(cellData);
                    if (def.client != 0)
                    {
                        cRow.Add(data);
                    }

                    if (def.server != 0)
                    {
                        sRow.Add(data);
                    }
                }
                catch (ValueTypeException e)
                {
                    window.Log(string.Format("解析{0}第{1}行，第{2}列数据有误：{3}", nodeName, row, col, e.GetError()), "error:");
                }
            }

            if (cRow.Count != 0)
            {
                cdatas.Add(cRow);
            }

            if (sRow.Count != 0)
            {
                sdatas.Add(sRow);
            }
        }

        writeClientData(nodeName, cdatas, cfilePackage, defines);

        AssetDatabase.Refresh();
    }

    private static void writeClientData(string fname, ArrayList cdatas, string cfilePackage,
        Dictionary<int, ProDefine> defines)
    {
        var window = (ExportDataTable) EditorWindow.GetWindow<ExportDataTable>();
        // 导出客户端数据
        if (cdatas.Count != 0)
        {
            var cpath = WriteCfgJSONData(fname, cdatas, cfilePackage);
            if (!string.IsNullOrEmpty(cpath))
            {
                window.Log(string.Format("文件{0}，将客户端数据保存至：{1}", fname, cpath));
            }
            else
            {
                window.Log(string.Format("文件{0}，未将客户端数据保存到{1}，请检查", fname, cpath), "error:");
            }
        }

        //生成lua文件
        string cDecodes = "";
        var enums = defines.GetEnumerator();
        var index = 1;
        //decode 数据
        while (enums.MoveNext())
        {
            var define = enums.Current.Value;
            if (define.client == 1)
            {
                cDecodes += string.Format("\t--{0}\n\tcachetable.{1} = data[{2}];\n",define.desc,define.name,index);
                index++;
            }
        }

        var cluapath = Path.Combine(Application.dataPath + "/Resources/Lua/luabean"+
            cfilePackage.Trim(),
            fname + "Table.lua");
        var cdict = MenualCodeHelper.GetManualCodeInfo(cluapath);

        var createTime = DateTime.Now;
        var cout = "";
        if (!string.IsNullOrEmpty(cDecodes))
        {
            cout = MenualCodeHelper.GenManualAreaCode("$area1", cdict) 
                   +String.Format("\n--创建时间{0}",createTime)
                   + createPart1.Replace("Templete", fname)
                   +MenualCodeHelper.GenManualAreaCode("$area2", cdict)
                   +"\nfunction "+fname+"Table:Decode(data)\n\t local cachetable = {}\n"+cDecodes
                   +"\n"+MenualCodeHelper.GenManualAreaCode("$decode", cdict)
                   +"\n\tself.m_cache[cachetable.id] = cachetable"
                   +"\nend\n"
                   + "return "+fname+"Table";
            SaveLuaFile(cluapath, cout);
        }
    }

    private static void SaveLuaFile(string cluapath,string content)
    {
        if (string.IsNullOrEmpty(content)) return;
        if (File.Exists(cluapath))
        {
            File.Delete(cluapath);
        }

        string dirname = Path.GetDirectoryName(cluapath);
        if (!Directory.Exists(dirname))
        {
            Directory.CreateDirectory(dirname);
        }

        var window = (ExportDataTable) EditorWindow.GetWindow<ExportDataTable>();
        try
        {
            FileStream fs = new FileStream(cluapath, FileMode.Create);
            StreamWriter wr = null;
            wr = new StreamWriter(fs);
            wr.WriteLine(content);
            wr.Close();

        }
        catch (Exception e)
        {
            window.Log(string.Format("写入文件时失败，路径：{0}",cluapath),"error:");
            throw;
        }
        window.Log(string.Format("生成lua文件成功生成路径为:{0}",cluapath));
        window.LogClientCode(content);
    }


    private static string WriteCfgJSONData(string fname, ArrayList datas, string cfilePackage)
    {
        string dirPath = Application.dataPath + "/Resources/ConfigJson/" + cfilePackage;
        string outPath = dirPath + fname + ".json";
        if (File.Exists(outPath))
        {
            File.Delete(outPath);
        }

        if (!Directory.Exists(dirPath))
        {
            Directory.CreateDirectory(dirPath);
        }

        FileStream fs = new FileStream(outPath, FileMode.Create);
        var contentSrt = JsonMapper.ToJson(datas);
        Regex reg = new Regex(@"(?i)\\[uU]([0-9a-f]{4})");
        contentSrt = reg.Replace(contentSrt,
            delegate(Match m) { return ((char) Convert.ToInt32(m.Groups[1].Value, 16)).ToString(); });
        StreamWriter wr = null;
        wr = new StreamWriter(fs);
        wr.WriteLine(contentSrt);
        wr.Close();
        return outPath;
    }


    private static string createPart1 = @"
TempleteTable = {}
TempleteTable.__index = TempleteTable
function TempleteTable:new()
    local self = {}
    setmetatable(self, TempleteTable)
    self.m_cache = {}

    return self
end


function TempleteTable:LoadBeanFromJsonFile(filename)
    if not filename then
        return false
    end
    local data =  Resources.Load(filename):ToString()
    local json = require 'rapidjson'
    local root = json.decode(data);
    self:BeanFromJson(root)
    return true;
end

function TempleteTable:BeanFromJson(datas)
    if not datas then return end
    for i,v in pairs(datas) do
        self:Decode(v)
    end
end
";
}