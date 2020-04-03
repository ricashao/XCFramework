import $path = require("path");
import $fs = require("fs");
import $XLSX = require("xlsx");
declare var XLSX: typeof $XLSX;
const path: typeof $path = nodeRequire("path");
const fs: typeof $fs = nodeRequire("fs");
const clipboard = nodeRequire('electron').clipboard;
import { writeJSONData, writeStringData, writeCfgJSONData } from "./writeJSONData";
import { TypeCheckers } from "./TypeCheckers";
import asyncFileLoad from "asyncFileLoad";
import $vm = require("vm");
import $http = require("http");

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
            $g("chkClientPath").checked = cookie.getCookie("unityexcel_chkClientPath") != "false";
        });
    }

    private getPathCookie(id: string) {
        let sPath = cookie.getCookie("unityexcel_" + id);
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
                cookie.setCookie("unityexcel_" + id, v)
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

        let useClientPath = $g("chkClientPath").checked;
        cookie.setCookie("unityexcel_chkClientPath", useClientPath);
        if (!useClientPath) {
            cPath = "";
        }
        // 清理code区
        $g("code").innerHTML = "";
        let unsolved = Array.from(files);
        // 每拖一次文件，只加载一次全局配置
        for (let i = 0, len = files.length; i < len; i++) {
            let file = files[i];
            let re = path.parse(file.name);
            if (re.ext == ".xlsx") { // 只处理Excel
                new XLSXDecoder(file, cPath, i, cb);
            }
        }

        function cb(file: File, err: boolean) {
            let idx = unsolved.indexOf(file);
            if (~idx) {
                unsolved.splice(idx, 1);
            }
            if (unsolved.length == 0) {//全部文件处理完成
                //检查是否有完结处理
               
            }
        }
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

    constructor(file: File, cPath: string, idx: number, cb: { (file: File, error: boolean) }) {
        cPath = cPath || "";
        let fre = path.parse(file.name);
        let fname = fre.name;
        let data = fs.readFileSync(file.path, "base64");
        let wb = XLSX.read(data);
        if (!wb.Sheets[fname]) {
            error(`表的sheetname有误`);
            return cb(file, true);
        }
        let list = XLSX.utils.sheet_to_json(wb.Sheets[fname], { header: 1 });
        let len = list.length;

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

        let plugin: string = cfgRow[1] || "";
        plugin = plugin.trim();
        // 是否不做基础处理
        let useRaw = plugin == "" ? false : !!cfgRow[2];

        if (dataRowStart == 0 && !useRaw) {
            error(`表的配置有误，没有配置使用原始值，并且没有 "属性名称"这一行`);
            return cb(file, true);
        }

        let defines: ProDefine[] = [];

        let cdatas = [];
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
            let nameRow: any = list[rowCfgLines["nameRow"]];



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
                    defines[col] = { client: client, server: server, checker: checker, name: name, desc: desc, def: def, type: "String" };
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
                        let key: any;
                        for (let col = 1; col <= max; col++) {
                            try {
                                let def = defines[col];
                                if (!def) {
                                    continue;
                                }
                                let cell = rowData[col];
                                let dat = def.checker.check(cell || "");
                                if (def.client) {
                                    cRow.push(genLuaConfigOneLine(def.name,dat));
                                }
                                if (def.name == "id") {
                                    key = dat;
                                }
                            } catch (e) {
                                error(`解析${fname}第${row + 1}行，第${XLSX.utils.encode_col(col)}列数据有误：${e.message}`);
                            }
                        }
                        if (cRow.length) {
                            cdatas.push(genLuaConfigOneData(key,cRow));
                        }
                    }
                }
            }

        }

        writeData(cdatas);
        /**
         * 
         * 写最终数据
         * @param {any[]} cdatas
         * @param {any[]} sdatas
         */
        function writeData(cdatas: any[]) {
            // 导出客户端数据
            if (cdatas.length) {
                let code = genLuaConfig(cdatas)
                let cpath = saveLuaFile(fname, cPath, code);
                if (cpath) {
                    log(`文件${fname}，将客户端数据保存至：${cPath}`);
                } else {
                    log(`文件${fname}，未将客户端数据保存到${cPath}，请检查`)
                }
            }

            cb(file, false);
        }
    }

}

function genLuaConfigOneLine(name: string, data: any) {
    return `\t\t${name} = ${data},`
}

function genLuaConfigOneData(name: string, datas: string[]) {
    return `\t[${name}] = {
${datas.join("\n")}
\t},`
}

function genLuaConfig(datas: string[]) {
    return `local config = {
${datas.join("\n")}
\t}

return config`
}

function saveLuaFile(fname:string,directory:string,content:string){
    const path = nodeRequire("path");
    const fs = nodeRequire("fs");
    let outpath = path.join(directory, fname + ".lua");
    fs.writeFileSync(outpath, content);
    return outpath;
}