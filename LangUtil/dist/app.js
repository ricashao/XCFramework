define(["require", "exports", "ClassHelper", "ServerServiceNameTemplate", "CookieForPath"], function (require, exports, ClassHelper_1, ServerServiceNameTemplate_1, CookieForPath_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const fs = nodeRequire("fs");
    const path = nodeRequire("path");
    const http = nodeRequire("http");
    const clipboard = nodeRequire('electron').clipboard;
    const $g = (id) => { return document.getElementById(id); };
    /**
     * 输出日志
     */
    function log(msg) {
        let txtLog = $g("txtLog");
        if (txtLog) {
            txtLog.innerHTML += `[${new Date().format("HH:mm:ss")}] ${msg} <br/>`;
        }
    }
    /**
     * 输出错误
     */
    function error(msg) {
        log(`<font color="#f00">${msg}</font>`);
    }
    const Options = {
        /**
         * 服务名称
         */
        ServiceName: "(service)",
        /**
         * 客户端模块
         */
        ClientModule: "(cmodule)",
        /**
         * 客户端路径，和前缀路径拼接得到文件生成路径地址
         */
        ClientPath: "(cpath)",
        /**
         * 服务器路径，和前缀路径拼接得到文件生成路径地址
         */
        ServerPath: "(spath)",
        /**
         * 通信用指令
         */
        CMD: "(cmd)",
        /**
         * S2C的指令才会有影响
         * 服务端的send广播方式
         * 0 send  默认
         * 1 broadcast
         * 2 negcast
         */
        BrocastType: "(btype)"
    };
    const TYPE_DOUBLE = 1;
    const TYPE_FLOAT = 2;
    const TYPE_INT64 = 3;
    const TYPE_UINT64 = 4;
    const TYPE_INT32 = 5;
    const TYPE_FIXED64 = 6;
    const TYPE_FIXED32 = 7;
    const TYPE_BOOL = 8;
    const TYPE_STRING = 9;
    const TYPE_GROUP = 10;
    const TYPE_MESSAGE = 11;
    const TYPE_BYTES = 12;
    const TYPE_UINT32 = 13;
    const TYPE_ENUM = 14;
    const TYPE_SFIXED32 = 15;
    const TYPE_SFIXED64 = 16;
    const TYPE_SINT32 = 17;
    const TYPE_SINT64 = 18;
    const type2number = (function () {
        let t = {};
        t["double"] = TYPE_DOUBLE;
        t["float"] = TYPE_FLOAT;
        t["int64"] = TYPE_INT64;
        t["uint64"] = TYPE_UINT64;
        t["int32"] = TYPE_INT32;
        t["fixed64"] = TYPE_FIXED64;
        t["fixed32"] = TYPE_FIXED32;
        t["bool"] = TYPE_BOOL;
        t["string"] = TYPE_STRING;
        t["group"] = TYPE_GROUP;
        t["message"] = TYPE_MESSAGE;
        t["bytes"] = TYPE_BYTES;
        t["uint32"] = TYPE_UINT32;
        t["enum"] = TYPE_ENUM;
        t["sfixed32"] = TYPE_SFIXED32;
        t["sfixed64"] = TYPE_SFIXED64;
        t["sint32"] = TYPE_SINT32;
        t["sint64"] = TYPE_SINT64;
        return t;
    })();
    // google.protobuf.descriptor.proto
    // enum Label {
    // // 0 is reserved for errors
    // LABEL_OPTIONAL      = 1;
    // LABEL_REQUIRED      = 2;
    // LABEL_REPEATED      = 3;
    // // TODO(sanjay): Should we add LABEL_MAP?
    // };
    // protobuf.js
    // // Field rules
    // RULE: /^(?:required|optional|repeated|map)$/,
    const rule2number = {
        "optional": 1,
        "required": 2,
        "repeated": 3
    };
    function field2type(field, imports) {
        let type = field.type;
        switch (type) {
            case "int32":
            case "uint32":
            case "sint32":
            case "int64":
            case "uint64":
            case "sint64":
            case "double":
            case "fixed32":
            case "sfixed32":
            case "enum":
            case "float":
                type = "number";
                break;
            case "bool":
                type = "boolean";
                break;
            case "bytes":
                type = "ByteArray";
                break;
            case "fixed64":
            case "sfixed64":
                // 项目理论上不使用
                type = "Int64";
                break;
            case "message":
                type = getTypeName(field, imports);
                break;
            case "string":
                type = "string";
                break;
            default:
                type = getTypeName(field, imports);
                break;
        }
        if (field.rule == "repeated") { // 数组赋值
            return type + "[]";
        }
        return type;
    }
    function getTypeName(field, imports) {
        let ret = field.type;
        addImport(ret, imports);
        return ret;
    }
    function getVariable(field, variables, imports) {
        let comment = field.comment; // 调整protobuf.js代码 让其记录注释
        let fname = field.name;
        // let def = field.options.default; // 获取默认值
        // def = def !== undefined ? ` = ${def}` : "";
        let def = ""; //改成不赋值默认值，这样typescript->js能减少字符串输出，将默认值记入mMessageEncode，也方便传输时做判断
        let ftype = field2type(field, imports);
        let ttype = ftype;
        // 不再初始化数组
        // if (field.rule == "repeated") {
        // 	ttype = ftype + " = []";
        // }
        if (field.rule == "optional") { // 可选参数
            // public get hasXXX():{
            //		return this.has(fieldnumber);
            // }
            variables.push(`/**`);
            variables.push(` * 可选参数 ${comment}`);
            variables.push(` */`);
            variables.push(`public ${fname}: ${ttype}${def};`);
            return `${fname}?: ${ftype}`;
        }
        else {
            variables.push(`/**`);
            variables.push(` * ${comment}`);
            variables.push(` */`);
            variables.push(`public ${fname}: ${ttype}${def};`);
            if (field.rule == "repeated") { // 可选参数
                return `${fname}?: ${ttype}`;
            }
            else {
                return `${fname}: ${ttype}`;
            }
        }
    }
    function parseProto(proto, gcfg) {
        let url = gcfg ? gcfg.url : "";
        url = url || "[文本框中，复制粘贴]";
        let cprefix = gcfg ? gcfg.cprefix : null;
        let sprefix = gcfg ? gcfg.sprefix : null;
        let sServiceName = gcfg ? gcfg.sServiceName : null;
        cprefix = cprefix || "";
        sprefix = sprefix || "";
        let p = ProtoBuf.DotProto.Parser.parse(proto);
        let options = p.options;
        // 处理文件级的Option
        let fcpath = options[Options.ClientPath];
        let fcmodule = options[Options.ClientModule];
        let fspath = options[Options.ServerPath];
        let service = options[Options.ServiceName];
        let now = new Date().format("yyyy-MM-dd HH:mm:ss");
        let idx = 0;
        let hasService = false;
        // 客户端和服务端的Service收发数组
        let cSends = [], cRecvs = [], cRegs = [], sSends = [], sRecvs = [], sRegs = [], simports = [];
        for (let msg of p.messages) {
            // 所有的变量
            // 一行一个
            let variables = [];
            let messageEncodes = [];
            // 如果有消息体的同名 Option，覆盖
            let options = msg.options;
            let cpath = options[Options.ClientPath] || fcpath;
            let cmodule = options[Options.ClientModule] || fcmodule;
            let spath = options[Options.ServerPath] || fspath;
            let cmddata = options[Options.CMD];
            let cmds = Array.isArray(cmddata) ? cmddata : [cmddata];
            let requireds = [];
            let repeateds = [];
            let optionals = [];
            let fnames = [];
            let imports = [];
            // 检查是否有Message类型的数据
            let msgType = null;
            for (let field of msg.fields) {
                let rule = field.rule;
                let fnumber = type2number[field.type];
                let MType = "";
                let def = field.options.default;
                if (def !== undefined) {
                    let t = typeof def;
                    if (t === "string") {
                        def = `"${def}"`;
                    }
                    else if (t === "object") { //不支持对象类型默认值
                        def = undefined;
                    }
                }
                if (fnumber == undefined) { // message类型不支持默认值
                    fnumber = 11; // message
                    MType = `, ${field.type}`;
                    msgType = field.type;
                }
                else if (def !== undefined) {
                    MType = `,,${def}`;
                    messageEncodes["hasDef"] = true;
                }
                messageEncodes.push(`${field.id} : ["${field.name}", ${rule2number[rule]}, ${fnumber}${MType}]`);
                let data = getVariable(field, variables, imports);
                fnames.push(field.name);
                if (rule == "required") {
                    requireds.push(data);
                }
                else if (rule == "repeated") {
                    repeateds.push(data);
                }
                else {
                    optionals.push(data);
                }
            }
            simports = simports.concat(imports);
            // 根据CMD 生成通信代码
            // 生成代码
            let className = msg.name;
            let type = className.substr(-3);
            let handlerName = className[0].toLowerCase() + className.substring(1, className.length - 4);
            let p = requireds.concat(repeateds, optionals);
            if (type == "C2S") { // client to server
                hasService = true;
                makeCSendFunction(p, fnames, className, handlerName, cSends, cmds[0]);
                makeReciveFunc(className, handlerName, sRegs, sRecvs, cmds, fnames.length, msgType, p, simports);
            }
            else if (type == "S2C") { // server to client
                hasService = true;
                makeSSendFunction(p, fnames, className, handlerName, sSends, cmds[0], simports);
                makeReciveFunc(className, handlerName, cRegs, cRecvs, cmds, fnames.length, msgType, p);
            }
            if (msg.fields.length > 1) { //属性数量大于1
                let cfile;
                if (cprefix) {
                    cfile = path.join(cprefix, cpath, className + ".ts");
                }
                let clientCode = getClientCode(now, url, className, cmodule, variables, messageEncodes, getManualCodeInfo(cfile));
                if (cprefix) {
                    let cdir = path.join(cprefix, cpath);
                    let out = writeFile(className + ".ts", cdir, clientCode);
                    if (out) {
                        log(`<font color="#0c0">生成客户端代码成功，${out}</font>`);
                    }
                }
                let sdir = "", sfile;
                if (sprefix) {
                    sdir = path.join(sprefix, spath);
                    sfile = path.join(sdir, className + ".ts");
                }
                let serverCode = getServerCode(now, url, className, variables, messageEncodes, imports, sdir, getManualCodeInfo(sfile));
                if (sprefix) {
                    let out = writeFile(className + ".ts", sdir, serverCode);
                    if (out) {
                        log(`<font color="#0c0">生成服务端代码成功，${out}</font>`);
                    }
                }
                createContent($g("code"), className, idx++, clientCode, serverCode);
            }
            // console.log(clientCode);
            // console.log("============================================================");
            // console.log(serverCode);
        }
        if (service && hasService) {
            //预处理Service
            //检查是否有客户端Service文件
            let cdir = path.join(cprefix, fcpath);
            let sfileName = service + ".ts";
            let cpath = path.join(cdir, sfileName);
            let ccode = getCServiceCode(now, url, service, fcmodule, cSends, cRecvs, cRegs, getManualCodeInfo(cpath));
            //检查是否有服务端Service文件
            let sdir = path.join(sprefix, fspath);
            let spath = path.join(sdir, sfileName);
            let scode = getSServiceCode(now, url, service, sSends, sRecvs, sRegs, simports, getManualCodeInfo(spath), sdir);
            // 创建客户端Service
            if (cprefix) {
                let out = writeFile(sfileName, cdir, ccode);
                if (out) {
                    log(`<font color="#0c0">生成客户端Service代码成功，${out}</font>`);
                }
            }
            // 创建服务端Service
            if (sprefix) {
                let out = writeFile(sfileName, sdir, scode);
                if (out) {
                    log(`<font color="#0c0">生成服务端Service代码成功，${out}</font>`);
                }
            }
            createContent($g("code"), service, idx++, ccode, scode);
            // 创建ServiceName常量文件
            if (sServiceName) {
                let temp = new ServerServiceNameTemplate_1.default();
                let snPath = path.join(sprefix, sServiceName);
                let [serr, srout] = temp.addToFile(snPath, service);
                if (serr) {
                    error(serr);
                }
                else {
                    let out = writeFile(sServiceName, sprefix, srout);
                    if (out) {
                        log(`<font color="#0c0">生成服务端ServiceName代码成功，${out}</font>`);
                    }
                }
                createContent($g("code"), snPath, idx++, "", srout);
            }
        }
    }
    function makeCSendFunction(p, fnames, className, handlerName, sends, cmd) {
        sends.push(`public ${handlerName}(${p.join(", ")}) {`);
        let len = fnames.length;
        if (len == 0) { //没有参数
            sends.push(`\tthis.send(${cmd}, null)`);
        }
        else if (len == 1) { //只有一个参数的情况
            sends.push(`\tthis.send(${cmd}, ${fnames[0]})`);
        }
        else { //超过1个参数
            sends.push(`\tlet _${className}: ${className} = new ${className}();`);
            fnames.forEach(fname => {
                sends.push(`\t_${className}.${fname} = ${fname};`);
            });
            sends.push(`\tthis.send(${cmd}, _${className})`);
        }
        sends.push(`}`);
    }
    function makeSSendFunction(p, fnames, className, handlerName, sends, cmd, sImports) {
        let len = fnames.length;
        if (len > 1) { //超过1个参数，才生成PBMessage类型
            addImport(className, sImports);
        }
        sends.push(`public ${handlerName}(se:any, ${p.join(", ")}) {`);
        if (len == 0) { //没有参数
            sends.push(`\tthis.send(se, ${cmd}, null)`);
        }
        else if (len == 1) { //只有一个参数的情况
            sends.push(`\tthis.send(se, ${cmd}, ${fnames[0]})`);
        }
        else { //超过1个参数	
            sends.push(`\tlet _${className}: ${className} = new ${className}();`);
            fnames.forEach(fname => {
                sends.push(`\t_${className}.${fname} = ${fname};`);
            });
            sends.push(`\tthis.send(se, ${cmd}, _${className})`);
        }
        sends.push(`}`);
    }
    function makeReciveFunc(className, handlerName, regs, recvs, cmds, len, msgType, p, sImports) {
        if (len > 1 && sImports) {
            addImport(className, sImports);
        }
        let strCMD = cmds.join(",");
        if (len == 1 && msgType) { //如果是一个参数，并且是PBMessage类型，则添加注册
            className = msgType;
            len = 2; //用于处理后续判断
        }
        if (len > 1) {
            regs.push(`this.regMsg(${className}, ${strCMD});`);
        }
        regs.push(`this.regHandler(this.${handlerName},${strCMD});`);
        recvs.push(`protected ${handlerName} = (data:NetData) => {`);
        if (len > 1) {
            recvs.push(`\tlet msg:${className} = <${className}>data.data;`);
        }
        else if (len == 1) { //创建数据
            recvs.push(`\tlet ${p[0]} = <any>data.data;`);
        }
        recvs.push(`/*|${handlerName}|*/`);
        recvs.push(`}`);
    }
    function addImport(imp, imports) {
        if (!~imports.indexOf(imp)) {
            imports.push(imp);
        }
    }
    function writeFile(fname, directory, data, corver = true) {
        let outpath = path.join(directory, fname);
        try {
            FsExtra.writeFileSync(outpath, data, corver);
        }
        catch (e) {
            error(`写入文件时失败，路径："${directory}"，文件名："${fname}"，错误信息：${e.message}\n${e.stack}`);
            return null;
        }
        return outpath;
    }
    function getClientCode(createTime, path, className, module, variables, messageEncodes, cinfo) {
        let vars = `		` + variables.join(`\n		`);
        return `/**
 * 使用JunyouProtoTools，从 ${path} 生成
 * 生成时间 ${createTime}
 **/
module ${module} {
	${genManualAreaCode("$area1", cinfo)}
	export class ${className} extends PBMessage {
		public static M = {${messageEncodes.join(",")}};
${vars}
		constructor(){	
			super();		
			this.mMessageEncode = ${className}.M;
			${messageEncodes["hasDef"] ? "super.initDef();" : ""}
			${genManualAreaCode("$init", cinfo)}
		}
${genManualAreaCode("$area2", cinfo)}
	}
${genManualAreaCode("$area3", cinfo)}
}
`;
    }
    function getServerCode(createTime, path, className, variables, messageEncodes, imports, base, cinfo) {
        let vars = `		` + variables.join(`\n		`);
        let strImp = "";
        imports.forEach(imp => {
            strImp += `${writeServerImport(imp, base)}`;
        });
        return `${writeServerImport("PBMessage", base)}
${strImp}
${genManualAreaCode("$area1", cinfo)}
/**
 * 使用JunyouProtoTools，从 ${path} 生成
 * 生成时间 ${createTime}
 **/
class ${className} extends PBMessage {
	public static M = {${messageEncodes.join(",")}};
${vars}
	constructor(){		
		super();		
		this.mMessageEncode = ${className}.M;
		${messageEncodes["hasDef"] ? "super.initDef();" : ""}
		${genManualAreaCode("$init", cinfo)}
	}
${genManualAreaCode("$area2", cinfo)}
}
${genManualAreaCode("$area3", cinfo)}
export = ${className};
`;
    }
    function getCServiceCode(createTime, path, className, module, sends, recvs, regs, cinfo) {
        return `/**
 * 使用JunyouProtoTools，从 ${path} 生成
 * 生成时间 ${createTime}
 **/
module ${module} {
${genManualAreaCode("$area1", cinfo)}
	export class ${className} extends junyou.mvc.Service {
		constructor(){
			super("${className}");
		}
		
		onRegister(){
			super.onRegister();
			${regs.join(`\n			`)}
			${genManualAreaCode("$onRegister", cinfo)}
		}
		
		${sends.join(`\n		`)}
		${parseRecvs(recvs, cinfo)}
${genManualAreaCode("$area2", cinfo)}
	}
${genManualAreaCode("$area3", cinfo)}
}`;
    }
    /**
     * 生成服务端的Import语句
     *
     * @param {string} className 类名
     * @param {string} base 文件路径
     * @returns (description)
     */
    function writeServerImport(className, base) {
        var out = `///ts:import=${className}\n`;
        let p = classHelper.getRelativePath(className, base);
        if (p) {
            out += `import ${className} = require('${p}');///ts:import:generated\n`;
        }
        return out;
    }
    function getSServiceCode(createTime, path, className, sends, recvs, regs, imports, cinfo, base) {
        let _imports = "";
        imports.forEach(imp => {
            _imports += `${writeServerImport(imp, base)}\n`;
        });
        return `${writeServerImport("Service", base)}
${writeServerImport("NetData", base)}
${_imports}
${genManualAreaCode("$area1", cinfo)}
/**
 * 使用JunyouProtoTools，从 ${path} 生成
 * 生成时间 ${createTime}
 **/
class ${className} extends Service {

	constructor(){
		super("${className}");
	}
	
	onRegister(){
		super.onRegister();
		${regs.join(`\n			`)}
		${genManualAreaCode("$onRegister", cinfo)}
	}
	
	${sends.join(`\n		`)}
	${parseRecvs(recvs, cinfo)}
${genManualAreaCode("$area2", cinfo)}
}
${genManualAreaCode("$area3", cinfo)}
export = ${className};
`;
    }
    function parseRecvs(recvs, cinfo) {
        return recvs.map(recv => {
            return recv.replace(/[/][*][|]([$_a-zA-Z0-9]+)[|][*][/]/, (rep, hander) => {
                return genManualAreaCode(hander, cinfo);
            });
        }).join(`\n			`);
    }
    /**
     * 获取http数据
     *
     * @param {string} url 要获取数据的地址
     * @returns {Promise}
     */
    function getHttpData(url, gcfg) {
        let promise = new Promise((resolve, reject) => {
            let req = http.get(url, res => {
                let size = 0;
                let chunks = [];
                res.on("data", (chunk) => {
                    size += chunk.length;
                    chunks.push(chunk);
                });
                res.on("end", () => {
                    let data = Buffer.concat(chunks, size);
                    resolve({ content: data.toString("utf8"), gcfg: gcfg, url: url });
                });
            });
            req.on("error", (err) => {
                reject(err.message);
            });
        });
        return promise;
    }
    /**
     * 提取Proto数据
     */
    function getProtoData(data) {
        let content = escapeHTML(data.content);
        // 从HTML流中截取 message {} 或者 option (xxxx) = "xxxx" 这样的数据
        let reg;
        if (/^http:\/\/192.168.0.205:1234\//.test(data.url)) {
            // gitlab wiki
            reg = /<code>([^]*?)<\/code>/mg;
        }
        else {
            // dokuwiki
            reg = /<pre class="code">([^>]*?message[ ]+[A-Z][a-zA-Z0-9_$]*[ ]*[{][^]*?[}][^]*?|[^>]*?option[ ]+[(]\w+[)][ ]*=[ ]*".*?";[^]*?)<\/pre>/mg;
        }
        let proto = "";
        while (true) {
            let result = reg.exec(content);
            if (result) {
                proto += result[1] + "\n";
            }
            else {
                break;
            }
        }
        $g("txtProto").value = proto;
        parseProto(proto, data.gcfg);
    }
    const escChars = { "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&apos;": "\'", "&amp;": "&", "&nbsp;": " ", "&#x000A;": "\n" };
    function escapeHTML(content) {
        return content.replace(/&lt;|&gt;|&quot;|&apos;|&amp;|&nbsp;|&#x000A;/g, substring => {
            return escChars[substring];
        });
    }
    function getProtoFromHttp(url, gcfg) {
        let promise = getHttpData(url, gcfg);
        promise.then(getProtoData, error).catch(error);
    }
    let classHelper = new ClassHelper_1.default();
    const cookieForPath = new CookieForPath_1.default("protoTools_");
    ready(() => {
        cookieForPath.getPathCookie("txtClientPath");
        cookieForPath.getPathCookie("txtServerPath");
        cookieForPath.getPathCookie("txtServerServiceNamePath");
        $g("btnGen").addEventListener("click", (ev) => {
            let cPath = cookieForPath.setPathCookie("txtClientPath");
            let sPath = cookieForPath.setPathCookie("txtServerPath");
            let sServiceName = cookieForPath.setPathCookie("txtServerServiceNamePath", false, false);
            if (sPath != classHelper.base) {
                // 将类的路径数据缓存，以便处理ts:import那种，省的每次执行完，还需要再次执行grunt指令
                classHelper.initClassHelper(sPath);
            }
            // 清理code区
            $g("code").innerHTML = "";
            // 检查url路径
            let url = $g("txtUrl").value;
            url = url.trim();
            let gcfg = { cprefix: cPath, sprefix: sPath, url: url, sServiceName: sServiceName };
            if (url) {
                getProtoFromHttp(url, gcfg);
            }
            else {
                let proto = $g("txtProto").value;
                if (proto) {
                    parseProto(proto, gcfg);
                }
                else {
                    error("没有填写wiki地址，也没有在文本框中输入任何proto数据。");
                }
            }
        });
    });
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
    function createContent(parent, filename, idx, ccode, scode) {
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
    </div>`;
        pane.innerHTML = template;
        parent.appendChild(pane);
        $g(idCopyClient).addEventListener("click", e => {
            clipboard.writeText(ccode);
        });
        $g(idCopyServer).addEventListener("click", e => {
            clipboard.writeText(scode);
        });
    }
    /**
     * 手写代码的默认提示
     */
    const ManualCodeDefaultComment = {
        /**
         * 类上方提示
         */
        $area1: "//这里填写类上方的手写内容",
        /**
         * 类中提示
         */
        $area2: "//这里填写类里面的手写内容",
        /**
         * 类下方提示
         */
        $area3: "//这里填写类下发的手写内容",
        /**
         * onRegister方法中
         */
        $onRegister: "//这里写onRegister中手写内容",
        /**
         * 处理函数提示
         */
        $handler: "//这里填写方法中的手写内容",
    };
    /**
     * 生成手动代码区域的文本
     */
    function genManualAreaCode(key, cinfo) {
        let manual = cinfo[key];
        if (!manual) {
            if (key in ManualCodeDefaultComment) {
                manual = ManualCodeDefaultComment[key];
            }
            else {
                manual = ManualCodeDefaultComment.$handler;
            }
        }
        return `/*-*begin ${key}*-*/
${manual}
/*-*end ${key}*-*/`;
    }
    /**
     * 获取手动写的代码信息
     */
    function getManualCodeInfo(file) {
        let dict = {};
        if (file && fs.existsSync(file)) {
            //读取文件内容
            let content = fs.readFileSync(file, "utf8");
            // /*-*begin $area1*-*/
            // //这里填写类上方的手写内容
            // /*-*end $area1*-*/
            // class XXService{
            // protected handlerName(data:NetData) {
            // 	let msg:className = <className>data.data;
            // 	/*-*begin handlerName*-*/
            // 	//这里填写方法中的手写内容
            // 	/*-*end handlerName*-*/
            // }
            // /*-*begin $area2*-*/
            // //这里填写类里面的手写内容
            // /*-*end $area2*-*/
            // }
            // /*-*begin $area3*-*/
            // //这里填写类下发的手写内容
            // /*-*end $area3*-*/
            //找到手写内容
            let reg = /[/][*]-[*]begin[ ]([$]?[a-zA-Z0-9]+)[*]-[*][/]([^]*?)[/][*]-[*]end[ ]\1[*]-[*][/]/g;
            while (true) {
                let result = reg.exec(content);
                if (result) {
                    let key = result[1];
                    let manual = result[2].trim();
                    if (!manual) { //没有注释
                        continue;
                    }
                    else if (key in ManualCodeDefaultComment) {
                        if (ManualCodeDefaultComment[key] == manual) { //类上中下的注释
                            continue;
                        }
                    }
                    else {
                        if (ManualCodeDefaultComment.$handler == manual) { //函数注释
                            continue;
                        }
                    }
                    dict[key] = manual;
                }
                else {
                    break;
                }
            }
        }
        return dict;
    }
});
//# sourceMappingURL=app.js.map