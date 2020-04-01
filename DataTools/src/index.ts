import $path = require("path");
import $fs = require("fs");
import $XLSX = require("xlsx");
declare var XLSX: typeof $XLSX;
const path: typeof $path = nodeRequire("path");
const fs: typeof $fs = nodeRequire("fs");
const clipboard = nodeRequire('electron').clipboard;
import { PluginErrorType } from "./PluginErrorType";
import { writeJSONData,writeStringData, writeCfgJSONData } from "./writeJSONData";
import { TypeCheckers } from "./TypeCheckers";
import { genManualAreaCode, getManualCodeInfo, ManualCodeDefaultComment } from "./MenualCodeHelper";
import ClassHelper from "ClassHelper";
import ClientRegTemplate from "ClientRegTemplate";
import ServerRegTemplate from "ServerRegTemplate";
import PluginLoader from "PluginLoader";
import asyncFileLoad from "asyncFileLoad";
import $vm = require("vm");
import $http = require("http");

/**
 * 正常数据内容，列表数据
 */
const SHEET_MAIN = "导出";
/**
 * 附加数据，用于代替之前公共数据表功能
 * 这样可以将一个模块数据配置在一起
 * 第一列为Key
 * 第二列为Value
 */
const SHEET_EXTRA = "附加数据";

var $g: any = (id) => { return document.getElementById(id) };
/**
 * 输出日志
 */
function log(msg: string) {
    let txtLog = $g("txtLog");
    if (txtLog) {
        txtLog.innerHTML += msg + "<br/>";
    }
}

/**
 * 输出错误
 */
function error(msg: string, err?: Error) {
    let errMsg = "";
    if (err) {
        errMsg = `
<font color="#f00"><b>err:</b></font>
${err.message}
<font color="#f00"><b>stack:</b></font>
${err.stack}`
    }
    log(`<font color="#f00">${msg}</font>${errMsg}`);
}


/**
 * ExcelDataSaver
 */
export class ExcelDataSaver {
    constructor() {
        ready(() => {
            window.addEventListener("dragover", e => {
                e.preventDefault();
                return false;
            });

            window.addEventListener("drop", e => {
                e.preventDefault();
                this.onDrop(e.dataTransfer.files);
                return false;
            });
            this.getPathCookie("txtClientPath");
            this.getPathCookie("txtServerPath");
            $g("chkClientPath").checked = cookie.getCookie("h5excel_chkClientPath") != "false";
            $g("chkServerPath").checked = cookie.getCookie("h5excel_chkServerPath") != "false";
        });
    }

    private getPathCookie(id: string) {
        let sPath = cookie.getCookie("h5excel_" + id);
        if (sPath) {
            $g(id).value = sPath;
        }
    }

    private setPathCookie(id: string): string {
        let v: string = $g(id).value;
        v = v.trim();
        $g(id).value = v;
        if (v && fs.existsSync(v)) {
            let re = fs.statSync(v);
            if (re.isDirectory()) {
                cookie.setCookie("h5excel_" + id, v)
                return v;
            }
        } else {
            log("id = " + id + " setCookie value = " + v + "检查路径是否存在")
        }
        return undefined;
    }


    private onDrop(files: FileList) {
        let gcfg: GlobalCfg;
        let cPath = this.setPathCookie("txtClientPath");
        let sPath = this.setPathCookie("txtServerPath");

        let useClientPath = $g("chkClientPath").checked;
        cookie.setCookie("h5excel_chkClientPath", useClientPath);
        let useServerPath = $g("chkServerPath").checked;
        cookie.setCookie("h5excel_chkServerPath", useServerPath);
        if (!useClientPath) {
            cPath = "";
        }
        if (!useServerPath) {
            sPath = "";
        }
        // 清理code区
        $g("code").innerHTML = "";
        let unsolved = Array.from(files);
        // 每拖一次文件，只加载一次全局配置
        for (let i = 0, len = files.length; i < len; i++) {
            let file = files[i];
            let re = path.parse(file.name);
            if (re.ext == ".xlsx") { // 只处理Excel
                if (!gcfg || !gcfg.project) {
                    // 得到全局配置路径
                    let globalCfgPath = path.join(file.path, "../..", "globalConfig.json");
                    gcfg = this.getGlobalCfg(globalCfgPath);
                    if (gcfg) {
                        if (gcfg.remote) { // 当前全局配置，如果配了远程路径，加载远程路径
                            gcfg = this.getGlobalCfg(gcfg.remote);
                        }
                    }
                }
                new XLSXDecoder(gcfg, file, cPath, sPath, i, cb);
            }
        }

        function cb(file: File, err: boolean) {
            let idx = unsolved.indexOf(file);
            if (~idx) {
                unsolved.splice(idx, 1);
            }
            if (unsolved.length == 0) {//全部文件处理完成
                //检查是否有完结处理
                if (gcfg.endScript) {
                    asyncFileLoad(gcfg.endScript, (er, data) => {
                        if (er) {
                            error(`处理加载结束脚本出错，${gcfg.endScript}`, er);
                            return
                        }
                        if (data) {
                            let script = data.toString();
                            let vm: typeof $vm = nodeRequire("vm");
                            let endScript = vm.createContext({ require: nodeRequire, console: console, gcfg: gcfg });
                            try {
                                vm.runInContext(script, endScript);
                            } catch (err1) {
                                error(`处理执行结束脚本出错，${gcfg.endScript}`, err1);
                            }
                        }
                    });
                }
                if (gcfg.endAction) {
                    var http: typeof $http = nodeRequire("http");
                    http.get(gcfg.endAction, res => {
                        let chunks: Buffer[] = [];
                        res.on("data", chunk => {
                            chunks.push(chunk);
                        });
                        res.on("end", () => {
                            let result = Buffer.concat(chunks).toString("utf8");
                            result = result.replace(/\n/g, "<br/>")
                            log(result);
                        })
                    })
                }
            }
        }
    }

    /**
     * 获取全局配置
     */
    private getGlobalCfg(globalCfgPath: string): GlobalCfg {
        let cfg: GlobalCfg;
        if (fs.existsSync(globalCfgPath)) {
            // 加载全局配置
            let globalJSON = fs.readFileSync(globalCfgPath, "utf8");

            try {
                cfg = <GlobalCfg>JSON.parse(globalJSON);
            } catch (e) {
                error("全局配置加载有误");
            }
        }
        return cfg;
    }
}

new ExcelDataSaver();

/**
 * XLSX解析器
 */
class XLSXDecoder {

    /**
     * 创建一个代码区
     * 
     * @private
     * @param {HTMLElement} parent (description)
     * @param {string} filename (description)
     * @param {number} idx (description)
     * @param {string} ccode (description)
     * @param {string} scode (description)
     */
    private createContent(parent: HTMLElement, filename: string, idx: number, ccode: string, scode: string) {
        let pane = document.createElement("div");
        pane.style.border = "#000 solid 1px";
        let idCopyClient = "btnCopyClient" + idx;
        let idCopyServer = "btnCopyServer" + idx;
        let template = `<div>${filename}</div>
    <div style="width:50%;height:50%;float:left;background:#eef">
        客户端代码：<input type="button" value="复制客户端代码" id="${idCopyClient}" />
        <textarea style="width:100%;height:200px;border:#ccf solid 1px;background:#eee" contenteditable="false">${ccode}</textarea>
    </div>
    <div style="width:50%;height:50%;float:left;background:#fee">
        服务端代码：<input type="button" value="复制服务端代码" id="${idCopyServer}" />
        <textarea style="width:100%;height:200px;border:#fcc solid 1px;background:#eee" contenteditable="false">${scode}</textarea>
    </div>`
        pane.innerHTML = template;
        parent.appendChild(pane);
        $g(idCopyClient).addEventListener("click", e => {
            clipboard.writeText(ccode);
        });
        $g(idCopyServer).addEventListener("click", e => {
            clipboard.writeText(scode);
        });

    }

    constructor(gcfg: GlobalCfg, file: File, cPath: string, sPath: string, idx: number, cb: { (file: File, error: boolean) }) {
        cPath = cPath || "";
        sPath = sPath || "";
        let fre = path.parse(file.name);
        let fname = fre.name;
        let dirs: string[] = fre.dir.split(path.sep)
        let dlen = dirs.length;
        let parent = dlen ? dirs[dlen - 1] : fname;
        let data = fs.readFileSync(file.path, "base64");
        let wb = XLSX.read(data);
        if (!wb.Sheets[fname]) {
            error(`表的sheetname有误`);
            return cb(file, true);
        }
        let list = XLSX.utils.sheet_to_json(wb.Sheets[fname], { header: 1 });
        let len = list.length;

        let sDatas: { [index: string]: any[] } = {};
        let rowCfgs: { [index: string]: string } = {
            // 第一列的中文: 对应后续用到的属性
            "支持的数据类型": null,// 不允许随便动
            "程序配置说明": null,// 说明
            "程序配置内容": "cfgRow",
            "前端解析": "clientRow",
            "后端解析": "serverRow",
            "默认值": "defaultRow",
            "数据类型": "typeRow",
            "描述": "desRow",
            "属性名称": "nameRow"//必须为配置的最后一行
        }
        /**
         * 数据起始行
         */
        let dataRowStart: number = 0;
        let rowCfgLines: { [index: string]: number } = {};
        // 先遍历所有行，直到得到"属性名称"行结束
        for (let i = 0; i < len; i++) {
            let rowData = list[i];
            let col1 = rowData[0];
            if (col1 in rowCfgs) {
                let key = rowCfgs[col1];
                if (key != null) {
                    rowCfgLines[key] = i;
                    if (key == "nameRow") {
                        dataRowStart = i + 1;
                        break;
                    }
                }
            }
        }


        // 配置列
        let cfgRow = list[rowCfgLines["cfgRow"]];
        if (!cfgRow) {
            error(`表的配置有误，没有 "程序配置内容"这一行`);
            return cb(file, true);
        }

        // 先处理附加数据
        // let hasExtra = this.parseExtraData(wb, fname, gcfg);
        let hasExtra = false;//屏蔽附加数据

        let plugin: string = cfgRow[1] || "";
        plugin = plugin.trim();
        // 是否不做基础处理
        let useRaw = plugin == "" ? false : !!cfgRow[2];

        if (dataRowStart == 0 && !useRaw) {
            error(`表的配置有误，没有配置使用原始值，并且没有 "属性名称"这一行`);
            return cb(file, true);
        }

        let cfilePackage = cfgRow[3] //|| parent; 不处理没填的情况
        let sfilePackage = cfgRow[4] //|| parent; 不处理没填的情况
        let cSuper = cfgRow[5] || ""; //前端基类
        let sSuper = cfgRow[6] || ""; //后端基类
        let cInterfaces: string[], sInterfaces: string[];
        if (cfgRow[7]) {
            cInterfaces = (<string>cfgRow[7]).split(",");
        } else {
            cInterfaces = [];
        }
        if (cfgRow[8]) {
            sInterfaces = (<string>cfgRow[8]).split(",");
        } else {
            sInterfaces = [];
        }
        let defines: ProDefine[] = [];

        let cdatas = [];
        let sdatas = [];
        if (!useRaw) {
            /**
             * 前端是否解析此数据
             */
            let clientRow = list[rowCfgLines["clientRow"]];
            /**
             * 后端是否解析此数据
             */
            let serverRow = list[rowCfgLines["serverRow"]];

            let defaultRow = list[rowCfgLines["defaultRow"]] || [];
            /**
             * 类型列
             */
            let typeRow = list[rowCfgLines["typeRow"]];
            /**
             * 描述列
             */
            let desRow = list[rowCfgLines["desRow"]];
            /**
             * 属性名称列
             */
            let nameRow = list[rowCfgLines["nameRow"]];


            let max = 0;
            let checkers = TypeCheckers;
            for (let key in nameRow) {
                let col = +key;
                if (col != 0) {
                    let client = +clientRow[col];
                    let server = +serverRow[col];
                    let type = typeRow[col] || "";
                    let checker = checkers[type];
                    let desc = "" + desRow[col];
                    let name = "" + nameRow[col];
                    let def = defaultRow[col];
                    defines[col] = { client: client, server: server, checker: checker, name: name, desc: desc, def: def , type: "String"};
                    if (col > max) {
                        max = col;
                    }
                }
            }

            // 从第9行开始，是正式数据
            for (let row = dataRowStart; row < len; row++) {
                let rowData = list[row];
                let col1 = rowData[0];
                if (!col1 || col1.charAt(0) != "!") {
                    // 先做空行检查，减少误报信息
                    let flag = false;

                    for (let col = 1; col <= max; col++) {
                        let cell = rowData[col];
                        let def = defines[col];
                        // 没有def的为注释列
                        if (def && cell != void 0 && (def.client || def.server)) {
                            flag = true;
                        }
                    }
                    if (flag) {
                        let cRow = [];
                        let sRow: { [index: string]: string } = {};
                        let hasServerData =false;
                        for (let col = 1; col <= max; col++) {
                            try {
                                let def = defines[col];
                                if (!def) {
                                    continue;
                                }
                                let cell = rowData[col];
                                let dat = def.checker.check(cell || "");
                                if (def.client) {
                                    cRow.push(dat);
                                }
                                if (def.server) {
                                    sRow[nameRow[col]] = dat;
                                    hasServerData = true;
                                }

                                if (def.checker.type == "number" && !isNaN(cell) && defines[col].type != "float") {
                                    defines[col].type = "int";
                                }
                                if (def.checker.type == "number" && !isNaN(cell) &&(cell + '').indexOf('.') != -1) {
                                    defines[col].type = "float";
                                }
                            } catch (e) {
                                error(`解析${fname}第${row + 1}行，第${XLSX.utils.encode_col(col)}列数据有误：${e.message}`);
                            }
                        }
                        if (cRow.length) {
                            cdatas.push(cRow);
                        }
                        if (sRow && hasServerData) {
                            sdatas.push(sRow);
                        }
                    }
                }
            }
            
        }
        if (plugin) {
            new PluginLoader(plugin, { gcfg: gcfg, filename: fname, rawData: list, sdatas: sdatas, cdatas: cdatas, defines: defines, dataRowStart: dataRowStart, rowCfg: rowCfgLines }, m => {
                let mtype = m.type;
                if (mtype == "error") {
                    switch (m.error) {
                        case PluginErrorType.ExecuteFailed:
                            error(`插件：${plugin}执行失败，检查插件代码！`, m.err);
                            break;
                        case PluginErrorType.LoadFailed:
                            error(`插件：${plugin}加载失败，请检查路径是否正确！`, m.err);
                            break;
                        case PluginErrorType.InitFailed:
                            error(`插件：${plugin}初始化失败，检查插件代码！`, m.err);
                            break;
                        default:
                            error(`插件：${plugin}出现未知！`, m.err);
                            break;
                    }
                    cb(file, true);
                } else if (mtype == "success") {//插件处理完成
                    log(`插件数据处理完成：\n${m.output || ""}`);
                    if (!useRaw) {
                        writeData(m.cdatas || [], m.sdatas || []);
                    } else {
                        cb(file, false);
                    }
                }
            });
            return;
        }
        var _self = this;
        sDatas[fname] = sdatas;
        console.log("sdata "+sDatas)
        writeData(cdatas, sdatas.length>0?sDatas:null);
        /**
         * 
         * 写最终数据
         * @param {any[]} cdatas
         * @param {any[]} sdatas
         */
        function writeData(cdatas: any[], sdatas: any) {
            // 导出客户端数据
            if (cdatas.length) {
                let cpath = writeCfgJSONData(fname, gcfg.clientPath, cdatas);
                if (cpath) {
                    log(`文件${file.name}，将客户端数据保存至：${cpath}`);
                } else {
                    log(`文件${file.name}，未将客户端数据保存到${cpath}，请检查`)
                }
            }

            // 导出服务端数据
            if (sdatas) {
                let spath = writeStringData(fname, gcfg.serverPath, toXmlString(sdatas),".xml");
                if (spath) {
                    log(`文件${file.name}，将服务端数据保存至：${spath}`);
                } else {
                    log(`文件${file.name}，未将服务端数据保存到${spath}，请检查`)
                }
            }

            let cPros = "";
            let cDecode = "";
            let sPros = "";
            let sDecode = "";
            let cout: string = "", sout: string = "";
            let hasClocal = false, hasSlocal = false;
            for (let define of defines) {
                if (!define) {
                    continue;
                }
                let checker = define.checker;
                let pro = `\t\t\t/**
\t\t\t* ${define.desc.replace(/\r\n/g, "<br/>\n\t\t\t* ")}
\t\t\t**/
\t\t\tpublic ${define.name}: ${checker.type};
`
                let decode = "";
                let def = "";
                if (define.def) {
                    def = define.def;
                }

                if (checker.solveString) {
                    decode = `\t\t\t@target@.${define.name} = ${checker.solveString.substitute({ value: "data[i++]" })}${def ? " || " + checker.solveString.substitute({ value: def }) : ""};
`;
                } else {
                    decode = `\t\t\t@target@.${define.name} = data[i++]${def ? " || " + def : ""};
`;
                }
                let client = define.client;
                let tmp: string;
                if (client) {
                    if (client == 1) {
                        cPros += pro;
                        tmp = decode.replace("@target@", "this");
                    } else if (client == 2) {
                        hasClocal = true;
                        tmp = decode.replace("@target@", "local");
                    }
                    cDecode += tmp;
                }
                let server = define.server;
                if (server) {
                    if(define.checker.idx == 3){

        let jpro = `
        @Attribute("${define.name}")
        @Getter                  
        protected  ${define.checker.type} ${getNameNoSymbol(define.name)};
                `
                    sPros += jpro;
                    }else{

        let jpro = `
        @Attribute("${define.name}")
        @Getter                  
        protected ${define.type} ${getNameNoSymbol(define.name)};
                `
                    sPros += jpro;
                    }
                }       
            }
            let cdict = getManualCodeInfo(path.join(cPath, cfilePackage || "", fname + "Cfg.ts"));
            let createTime = new Date().format("yyyy-MM-dd HH:mm:ss");
            // 生成客户端代码
            if (cPros) {
                cout = `namespace xc.${gcfg.project} {
    ${genManualAreaCode("$area1", cdict)}
    /**
     * 创建时间：${createTime}
     **/
    export class ${fname}Cfg${cSuper ? " extends " + cSuper : ""}${cInterfaces.length ? " implements " + cInterfaces.join(",") : ""} {
${cPros}
${genManualAreaCode("$area2", cdict)}
        public decode(data:any[]){
\t\t\tlet i = 0;
${hasClocal ? "\t\t\tlet local:any = {};" : ""}
${cDecode}
${genManualAreaCode("$decode", cdict)}
        }
    }
    ${genManualAreaCode("$area3", cdict)}
}`
            }
            // 生成服务端代码
            // let sdict = getManualCodeInfo(path.join(sPath, sfilePackage || "", fname + "Cfg.ts"));
            if (sPros) {
                    let imps = "";
                    sInterfaces.forEach(it => {
                        imps += writeServerImport(it, sPath);//`///ts:import=${it}\n`;
                    })
                    sout = `package org.szc.tableConfig;\r\nimport org.szc.annotation.Attribute;\r\nimport org.szc.annotation.Xml;
${imps}
import lombok.Getter;
/**
* 由数据生成工具，从"${file.path}"生成
* 创建时间：${createTime}
**/
@Xml(res = "${fname}.xml", node = "${fname}")
public class ${fname}VO${sSuper ? " extends " + sSuper : ""}${sInterfaces.length ? " implements " + sInterfaces.join(",") : ""} {
${sPros}
}
`
            }

            _self.createContent($g("code"), fname, idx, cout, sout);
            // 尝试存储文件
            if (cPath)
                _self.saveCodeFile(cPath, cfilePackage, cout, fname + "Cfg");
            if (sPath && sfilePackage)
            {
                let packages = sfilePackage.split(";")
                for(let pack of packages)
                {
                    _self.saveCodeFile(sPath, path.join(pack,"src\\main\\java\\org\\szc\\tableConfig\\"), sout, fname + "VO", ".java");
                }
            }

            // 尝试生成注册文件
            if (cPath && cout && gcfg.clientRegClass) {
                let clientReg: ClientRegTemplate = new ClientRegTemplate();
                let [cerr, crout] = clientReg.addToFile(path.join(cPath, gcfg.clientRegClass[1], gcfg.clientRegClass[0] + ".ts"), fname, `xc.${gcfg.project}`, hasExtra);
                if (cerr) {
                    error(cerr);
                } else {
                    _self.saveCodeFile(cPath, gcfg.clientRegClass[1], crout, gcfg.clientRegClass[0]);
                }
            }
            if (sPath && sout && gcfg.serverRegClass) {
                let serverReg: ServerRegTemplate = new ServerRegTemplate();
                let [serr, srout] = serverReg.addToFile(path.join(sPath, gcfg.serverRegClass[1], gcfg.serverRegClass[0] + ".java"), fname, hasExtra);
                if (serr) {
                    error(serr);
                } else {
                    _self.saveCodeFile(sPath, gcfg.serverRegClass[1], srout, gcfg.serverRegClass[0]);
                }
            }

            cb(file, false);
        }
    }
    

    /**
     * 
     * 检查附加数据
     * 附加数据形式为 Key Value式的
     * @private
     * @param {$XLSX.IWorkBook} wb
     */
    private parseExtraData(wb: $XLSX.IWorkBook, fname: string, gcfg: GlobalCfg) {
        let ws = wb.Sheets[SHEET_EXTRA];
        if (!ws) {//没有附加数据表
            return;
        }
        let list = XLSX.utils.sheet_to_json(ws);
        let len = list.length;
        let output = [];
        let checkers = TypeCheckers;
        for (let row = 0; row < len; row++) {
            let data = list[row];
            let key: string = data["标识"] + "";
            if (key && (key = key.trim())) {
                let value = data["数据"];
                let checker = checkers[data["数据类型"]];
                try {
                    value = checker.check(value);
                } catch (e) {
                    error(`解析${fname}第${row + 1}行，数据有误：${e.message}`);
                    continue;
                }
                output.push(key, value);
                if (checker.solveString) {
                    output.push(+checker.idx);
                }
            }
        }
        if (output.length) {
            fname = "$" + fname;
            //存储附加文件数据
            //数据为 string,any[,number]...string,any[,number]
            let cpath = writeJSONData(fname, gcfg.clientPath, output);
            if (cpath) {
                log(`文件${fname}，将客户端附加数据保存至：${cpath}`);
            } else {
                log(`文件${fname}，未将客户端附加数据保存到${cpath}，请检查`)
            }
            let spath = writeJSONData(fname, gcfg.serverPath, output);
            if (spath) {
                log(`文件${fname}，将服务端附加数据保存至：${spath}`);
            } else {
                log(`文件${fname}，未将服务端附加数据保存到${spath}，请检查`)
            }
            return true;
        }
        return false;
    }

    //递归创建目录 同步方法
    private mkdirsSync(dirname) {
        console.log(dirname);
        if (fs.existsSync(dirname)) {
            return true;
        } else {
            if (this.mkdirsSync(path.dirname(dirname))) {
                fs.mkdirSync(dirname);
                return true;
            }
        }
    }

    /**
     * 存储文件
     * 
     */
    private saveCodeFile(dir: string, filePackage: string, content: string, fname: string, ext = ".ts") {
        if (!content) {
            return;
        }
        if (dir && filePackage) {// 如果没有包名或者路径不填 则不生成，也不报错
            fname += ext;
            let fullPath = path.join(dir, filePackage);
            if (fullPath) {
                if (!fs.existsSync(fullPath)) {
                    this.mkdirsSync(fullPath);
                }
                let re = fs.statSync(fullPath);
                if (re.isDirectory()) {
                    let file = path.join(fullPath, fname);
                    try {
                        fs.writeFileSync(file, content);
                    }
                    catch (e) {
                        error(`写入文件时失败，路径："${fullPath}"，文件名："${fname}"，错误信息：${e.message}\n${e.stack}`);
                        return;
                    }
                    log(`<font color="#0c0">生成代码成功，${file}</font>`);
                    return;
                }
            }
            error(`生成路径有误，无法生成，路径："${fullPath}"，文件名："${fname}"`);
        }
    }
}

let classHelper: ClassHelper = new ClassHelper();
/**
 * 生成服务端的Import语句
 * 
 * @param {string} className 类名
 * @param {string} base 文件路径
 * @returns (description)
 */
function writeServerImport(className: string, base: string) {
    var out = `///ts:import=${className}\n`;
    let p = classHelper.getRelativePath(className, base);
    if (p) {
        out += `import ${className} = require('${p}');///ts:import:generated\n`;
    }
    return out;
}


function writeSServerImport(){
    
}


function toXmlString(data: any): string {
    let ret: string = `<?xml version="1.0" encoding="UTF-8"?>\r\n<root>\r\n`;
    for (let key1 in data) {
        ret += `<${key1}>\r\n`;
        for (let i = 0; i < data[key1].length; i++) {
            ret += `\t<entry `;
            for (let key2 in data[key1][i]) {
                ret += ` ${key2}="${xmlEncode(data[key1][i][key2].toString())}" `;
            }
            ret += ` />\r\n`;
        }
        ret += `</${key1}>\r\n`;
    }
    ret += `</root>`;
    return ret;
}

function xmlEncode(str: string): string {
    return str.replace(/&/g, "&amp;")
        .replace(/"/g, "&quot;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/'/g, "&apos;");
}

function getJavaName(name: string) {
    return name[0].toUpperCase() + name.substr(1);
}

function getNameNoSymbol(name: string) {
    let str = name.split('_');
    let ret = '';
    if (str.length == 1) {
        return name;
    } else {
        for (let i = 0; i < str.length; i++) {
            if (i > 0) {
                ret += str[i].replace(/^\S/, function (s) { return s.toUpperCase(); });
            } else {
                ret += str[i];
            }
        }
        return ret;
    }
}
