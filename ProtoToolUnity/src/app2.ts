"use strict";
import * as pbjs from "protobuf";
//import { } from "Extend";
const fs = nodeRequire("fs");
const path = nodeRequire("path");
const http = nodeRequire("http");
const process = nodeRequire('child_process');
const clipboard = nodeRequire('electron').clipboard;

const $g = (id) => { return <HTMLInputElement>document.getElementById(id) };
/**
 * 输出日志
 */
function log(msg: string) {
	let txtLog = $g("txtLog");
	if (txtLog) {
		txtLog.innerHTML += `[${new Date().format("HH:mm:ss")}] ${msg} <br/>`;
	}
}

/**
 * 输出错误
 */
function error(msg: string) {
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
	 * Lua路径，和前缀路径拼接得到文件生成路径地址
	 */
	LuaPath: "(luapath)",
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
	BrocastType: "(btype)",

	/**
	 * 服务端生成的proto文件名
	 */
	Proto: "(proto)",

	/**
	 * 服务端生成的proto文件名
	 */
	DependProto: "(dependproto)"
}

interface GlobalCfg {

	/**
	 * 客户端项目路径
	 * 
	 * @type {string}
	 */
	cprefix: string;
	/**
	 * 服务端项目生成路径
	 * 
	 * @type {string}
	 */
	sprefix?: string;
	/**
	 * 
	 * ServiceName常量文件的文件相对路径
	 * @type {string}
	 */
	sServiceName?: string;
	/**
	 * 生成时，使用的wiki地址
	 * 
	 * @type {string}
	 */
	url?: string;

	/**
	 * 
	 * PB消息字典的文件相对路径
	 * @type {string}
	 */
	PBMsgDictName?: string;
}


const TYPE_DOUBLE: number = 1;
const TYPE_FLOAT: number = 2;
const TYPE_INT64: number = 3;
const TYPE_UINT64: number = 4;
const TYPE_INT32: number = 5;
const TYPE_FIXED64: number = 6;
const TYPE_FIXED32: number = 7;
const TYPE_BOOL: number = 8;
const TYPE_STRING: number = 9;
const TYPE_GROUP: number = 10;
const TYPE_MESSAGE: number = 11;
const TYPE_BYTES: number = 12;
const TYPE_UINT32: number = 13;
const TYPE_ENUM: number = 14;
const TYPE_SFIXED32: number = 15;
const TYPE_SFIXED64: number = 16;
const TYPE_SINT32: number = 17;
const TYPE_SINT64: number = 18;

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

const Type_Null = 0;
const Type_Boolean = 1;
const Type_String = 2;
const Type_Bytes = 4;
const Type_Double = 5;
const Type_Int32 = 6;
const Type_Uint32 = 7;

function field2type(field: pbjs.ProtoField): [string, boolean, string | number, boolean] {
	let type = field.type;
	let isMsg = false;
	let ttype: string | number;
	switch (type) {
		case "int32":
		case "sint32":
		case "sfixed32":
			type = "number";
			ttype = Type_Int32;
			break;
		case "enum":
		case "fixed32":
		case "uint32":
			type = "number";
			ttype = Type_Uint32;
		case "int64":
		case "uint64":
		case "sint64":
		case "double":
		case "float":
			type = "number";
			ttype = Type_Double;
			break;
		case "bool":
			type = "boolean";
			ttype = Type_Boolean;
			break;
		case "bytes":
			type = "ByteArray";
			ttype = Type_Bytes;
			break;
		case "fixed64":
		case "sfixed64":
			// 项目理论上不使用
			type = "Int64";
			break;
		case "message":
			type = field.type;
			isMsg = true;
			ttype = `"${type}"`;
			break;
		case "string":
			type = "string";
			ttype = Type_String;
			break;
		default:
			type = field.type;
			ttype = `"${type}"`;
			break;
	}
	if (field.rule == "repeated") { // 数组赋值
		return [type + "[]", isMsg, ttype, true];
	}
	return [type, isMsg, ttype, false];
}

function getVariable(field: pbjs.ProtoField, variables: string[]): FieldData {
	let comment = field.comment;// 调整protobuf.js代码 让其记录注释
	let fname = field.name;
	// let def = field.options.default; // 获取默认值
	// def = def !== undefined ? ` = ${def}` : "";
	let def = "";//改成不赋值默认值，这样typescript->js能减少字符串输出，将默认值记入mMessageEncode，也方便传输时做判断
	let [fieldType, isMsg, tType, repeated] = field2type(field);
	// 不再初始化数组
	// if (field.rule == "repeated") {
	// 	ttype = ftype + " = []";
	// }
	if (field.rule == "required") { // 可选参数
		// public get hasXXX():{
		//		return this.has(fieldnumber);
		// }
		variables.push(`/**`);
		variables.push(` * ${comment}`);
		variables.push(` */`);
		variables.push(`${fname}: ${fieldType};`);
	} else {
		variables.push(`/**`);
		variables.push(` * 可选参数 ${comment}`);
		variables.push(` */`);
		variables.push(`${fname}?: ${fieldType};`);
	}
	return { fieldName: fname, fieldType: fieldType, isMsg: isMsg, tType: tType, repeated: repeated };
}

declare type FieldData = {
	/**
	 * 
	 * 字段名称
	 * @type {string}
	 */
	fieldName: string;
	/**
	 * 
	 * 字段类型
	 * @type {string}
	 */
	fieldType: string;
	/**
	 * 
	 * 是否为消息类型
	 * @type {boolean}
	 */
	isMsg: boolean;
	/**
	 * 
	 * 用于注册typeScript的类型
	 * @type {(number | string)}
	 */
	tType: number | string;
	/**
	 * 
	 * 是否为repeated
	 * @type {boolean}
	 */
	repeated: boolean;
}

declare type SFieldData = {
	/**
	 * 
	 * 字段名称
	 * @type {string}
	 */
	fieldName: string;
	/**
	 * 
	 * 字段类型
	 * @type {string}
	 */
	fieldType: string;
	/**
	 * 
	 * 是否为消息类型
	 * @type {boolean}
	 */
	isMsg: boolean;
	/**
	 * 
	 * 用于注册typeScript的类型
	 * @type {(number | string)}
	 */
	tType: number | string;


	/**
	 * 
	 * 是否为repeated
	 * @type {boolean}
	 */
	repeated: boolean;

	/**
	 * 
	 * 是否为required java用
	 * @type {boolean}
	 */
	required: boolean;
}

function parseProto(proto: string, gcfg?: GlobalCfg) {
	let url: string = gcfg ? gcfg.url : "";
	url = url || "[文本框中，复制粘贴]";
	let cprefix = gcfg ? gcfg.cprefix : null;
	cprefix = cprefix || "";
	let p = pbjs.DotProto.Parser.parse(proto);
	let options = p.options;
	// 处理文件级的Option
	let service: string = options[Options.ServiceName];
	let protoname: string = options[Options.Proto];
	let dependproto: string = options[Options.DependProto];
	let luapath: string = options[Options.LuaPath];

	let now = new Date().format("yyyy-MM-dd HH:mm:ss");
	let idx = 0;
	let hasService = false;
	let msgEncDict: { [index: string]: string } = {};
	let msgTypeCode: string[] = [];
	// var msgTypeNameMap = {};
	// 客户端和服务端的Service收发数组
	let cSends: string[] = [], cRecvs: string[] = [], cRegs: string[] = [], sSends: string[] = [], sRecvs: string[] = [], sRegs: string[] = [];//, simports: string[] = [];
	//存放当前模块的message s->s
	let sproto: string[] = [];
	//记录前后端通讯的协议
	let luaMsgId: string[] = [];
	for (let msg of p.messages) {
		// 所有的变量
		// 一行一个
		let variables: string[] = [];
		let messageEncodes: string[] = [];
		// 如果有消息体的同名 Option，覆盖
		let options = msg.options;
		let cmddata: any = options[Options.CMD];
		var comment = msg.comment;
		var commentText = '';
		let cmds: number[] = Array.isArray(cmddata) ? cmddata : [cmddata];


		//if(comment == ''){
		//	log(msg.name+' 上面加下cmd注释');
		//	continue;
		//}
		if (comment.indexOf('|') > 0) {
			commentText = comment.split('|')[1];
		}
		if (comment.indexOf('=') > 0) {
			if (comment.indexOf('|') > 0) {
				cmds = [comment.split('|')[0].split('=')[1]];
			}
			else {
				cmds = [comment.split('=')[1]];
			}

		}
		//let cmds = [comment.split('=')[1]];
		let requireds: FieldData[] = [];
		let repeateds: FieldData[] = [];
		let optionals: FieldData[] = [];

		for (let field of msg.fields) {
			let rule: string = field.rule;
			let fnumber = type2number[field.type];
			let MType = "";
			let def = field.options.default;
			if (def !== undefined) {
				let t = typeof def;
				if (t === "string") {
					def = `"${def}"`;
				} else if (t === "object") {//不支持对象类型默认值
					def = undefined;
				}
			}
			if (fnumber == undefined) {// message类型不支持默认值
				fnumber = 11;// message
				MType = `, "${field.type}"`;
			} else if (def !== undefined) {
				MType = `, , ${def}`;
			}
			messageEncodes.push(`${field.id}: ["${field.name}", ${rule2number[rule]}, ${fnumber}${MType}]`);
			let data = getVariable(field, variables);
			if (rule == "required") {
				requireds.push(data);
			} else if (rule == "repeated") {
				repeateds.push(data);
			} else {
				optionals.push(data);
			}
		}
		// 根据CMD 生成通信代码
		// 生成代码
		let className: string = msg.name;
		// msgEncDict[className] = `{ ${messageEncodes.join(", ")} }`;
		var typeVar = '';
		if (className.indexOf('S2C') > 0 || className.indexOf('C2S') > 0) {
			typeVar = className.substr(-7, 3);
		}
		let type = typeVar;
		if (type != "") {
			//c->s的message 获取方法名
			let handlerName = className.substring(0, className.length - 4);
			if (type == "C2S") { // client to server
				hasService = true;
				luaMsgId.push(className)
				makeCSendFunction(className, handlerName, cSends, cmds[0]);
			} else if (type == "S2C") { // server to client
				hasService = true;
				luaMsgId.push(className);
				makeReciveFunc(className, handlerName, cRegs, cRecvs, cmds);
			}
		}


		//存在则保存
		if (cmds[0]) {
			msgTypeCode.push(getMsgTypeCode(className, cmds[0]));
		}

		sproto.push(getMsgStruct(msg))
	}



	if (service && hasService && luapath) {
		//预处理Service
		//检查是否有客户端Service文件
		let cdir = path.join(cprefix, luapath);
		let cfileName = service + ".lua";
		let cpath = path.join(cdir, cfileName);

		let ccode = getCServiceCode(now, url, service, cSends, cRecvs, cRegs, getManualCodeInfo(cpath));
		// 创建客户端Service
		if (cprefix) {

			let out = writeFile(cfileName, cdir, ccode);
			if (out) {
				log(`<font color="#0c0">生成客户端Service代码成功，${out}</font>`);
			}

			createContent($g("code"), service, idx++, ccode, "");

		}

		if (luaMsgId.length > 0 && protoname) {
			//生成MsgIDMap
			let ctemp = new MapIDMapTemplate();
			let cnPath = path.join(cprefix, "Assets/LuaScripts/Net/Config/MsgIDMap.lua");
			let code = ctemp.addToFile(cnPath, protoname, luaMsgId);
			let out = writeFile("Assets/LuaScripts/Net/Config/MsgIDMap.lua", cprefix, code);
			if (out) {
				log(`<font color="#0c0">生成客户端MapIDMap代码成功，${out}</font>`);
			}
			createContent($g("code"), "MsgIDMap", idx++, code, "");
		}
	}

	//客户端根目录存在
	if (cprefix) {
		//生成对应的proto文件
		if (sproto.length > 0 && protoname) {
			let messageGameProtoOut = writeFile(protoname + '.proto', path.join(cprefix, 'ProtoFile'), makeLuaProtoCode(sproto, dependproto));

			if (messageGameProtoOut) {
				log(`<font color="#0c0">生成客户端proto文件成功，${messageGameProtoOut}</font>`);
				//开始生成proto类
				execLuaBat("protoc.exe ", path.join(cprefix, "ProtoFile"), path.join(cprefix, "/Assets/LuaScripts/Net/Protol"), protoname);
			}
		}
	}

}


function makeLuaProtoCode(sproto: string[], depend: string) {
	let importproto: string[] = [];
	if (depend) {
		depend.split(";").forEach(proto => {
			importproto.push(`import "${proto}.proto";`);
		});
	}
	return `${importproto.join("\n")}
${sproto.join("\n")}`
}

/**
 * 生成对应的message 结构
 * @param msg message类型
 */
function getMsgStruct(msg: any) {
	let code: string[] = [];
	for (let field of msg.fields) {
		code.push(`	${field.rule} ${field.type} ${field.name} = ${field.id};//${field.comment}`);
	}
	return `message ${msg.name}{
${code.join("\n")}
}`
}

function makeCSendFunction(className: string, handlerName: string, sends: string[], cmd: number) {
	sends.push(`local function ${handlerName}(self, _${className}) `);
	sends.push(`\tself:Send(${cmd}, _${className}, "${className}")`);
	sends.push(`end`)
}


function makeReciveFunc(className: string, handlerName: string, regs: string[], recvs: string[], cmds: number[]) {
	let strCMD = cmds.join(",");
	//console.log(fnames);
	regs.push(`\tself:RegMsg("${className}", ${strCMD});`);
	regs.push(`\tself:RegHandler(self.${handlerName}, ${strCMD});`);
	recvs.push(`local function ${handlerName} (self, data)`);
	recvs.push(`--/*|${handlerName}|*/--`);
	recvs.push(`end`);
}

function execLuaBat(fileName: string, dirName: string, epxortpath: string, protoname: string) {
	let command = `${dirName}/${fileName} --plugin=protoc-gen-lua=${dirName}/plugin/build.bat --proto_path=${dirName} --lua_out=${epxortpath} ${dirName}\\${protoname}.proto`;
	process.exec(command, { cwd: dirName }, function (err, stdout, stderr) {
		if (err) {
			error(" proto exec error " + err);
		} else {
			log(`<font color="#0c0">生成客户端${protoname}代码成功，${epxortpath}</font>`)
		}
	});
}


function writeFile(fname: string, directory: string, data: string, corver = true): string {
	let outpath = path.join(directory, fname);
	try {
		FsExtra.writeFileSync(outpath, data, corver);
	} catch (e) {
		error(`写入文件时失败，路径："${directory}"，文件名："${fname}"，错误信息：${e.message}\n${e.stack}`);
		return null;
	}
	return outpath;
}

function getMsgTypeCode(msgTypeName: string, cmd: number) {
	return `    public static final int ${msgTypeName} = ${cmd};`
}

function getCServiceCode(createTime: string, path: string, className: string, sends: string[], recvs: string[], regs: string[], cinfo: { [index: string]: string }) {
	return `--[[
-- 使用ProtoTools，从 ${path} 生成
-- 生成时间 ${createTime}
--]]

local ${className} = BaseClass("${className}", WsBaseService)
local function OnRegister(self)
	base.onRegister(self);

${regs.join(`\n`)}
${genManualAreaCode("$onRegister", cinfo, `\t`)}
end
${sends.join(`\n`)}
${parseRecvs(recvs, cinfo)}
${genManualAreaCode("$area2", cinfo)}

${className}.OnRegister = OnRegister

return ${className}
`
}


function parseRecvs(recvs: string[], cinfo) {
	return recvs.map(recv => {
		return recv.replace(/[-][-][/][*][|]([$_a-zA-Z0-9]+)[|][*][/][-][-]/, (rep, hander) => {
			return genManualAreaCode(hander, cinfo, `\t`);
		})
	}).join(`\n`);
}

/**
 * 获取http数据
 * 
 * @param {string} url 要获取数据的地址
 * @returns {Promise}
 */
function getHttpData(url: string, gcfg?: GlobalCfg) {
	let promise = new Promise((resolve, reject) => {
		let req = http.get(url, res => {
			let size = 0;
			let chunks: Buffer[] = [];
			res.on("data", (chunk: Buffer) => {
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
function getProtoData(data: { content: string, gcfg?: GlobalCfg, url: string }) {
	let content = escapeHTML(data.content);
	// 从HTML流中截取 message {} 或者 option (xxxx) = "xxxx" 这样的数据
	let reg: RegExp;
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
		} else {
			break;
		}
	}
	$g("txtProto").value = proto;
	parseProto(proto, data.gcfg);
}

const escChars = { "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&apos;": "\'", "&amp;": "&", "&nbsp;": " ", "&#x000A;": "\n" };
function escapeHTML(content: string) {
	return content.replace(/&lt;|&gt;|&quot;|&apos;|&amp;|&nbsp;|&#x000A;/g, substring => {
		return escChars[substring];
	});
}

function getProtoFromHttp(url: string, gcfg?: GlobalCfg) {
	let promise = getHttpData(url, gcfg);
	promise.then(getProtoData, error).catch(error);
}


import CookieForPath from "CookieForPath";
import MapIDMapTemplate from "./MapIDMapTemplate";

const cookieForPath = new CookieForPath("protoToolUnity_");

ready(() => {
	cookieForPath.getPathCookie("txtClientPath");

	$g("btnGen").addEventListener("click", (ev) => {
		let cPath = cookieForPath.setPathCookie("txtClientPath");
		// console.log("sServiceName    "+sServiceName);
		// 清理code区
		$g("code").innerHTML = "";
		// 检查url路径
		let url: string = $g("txtUrl").value;
		url = url.trim();
		let gcfg: GlobalCfg = { cprefix: cPath, url: url };
		if (url) {
			getProtoFromHttp(url, gcfg);
		} else {
			let proto = $g("txtProto").value;
			if (proto) {
				parseProto(proto, gcfg);
			} else {
				error("没有填写wiki地址，也没有在文本框中输入任何proto数据。")
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
function createContent(parent: HTMLElement, filename: string, idx: number, ccode: string, scode: string) {
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

/**
 * 手写代码的默认提示
 */
const ManualCodeDefaultComment = {
	/**
	 * 类上方提示
	 */
	$area1: "-- 这里填写类上方的手写内容",
	/**
	 * 类中提示
	 */
	$area2: "-- 这里填写类里面的手写内容",
	/**
	 * 类下方提示
	 */
	$area3: "-- 这里填写类下发的手写内容",
	/**
	 * onRegister方法中
	 */
	$onRegister: "-- 这里写onRegister中手写内容",
	/**
	 * 处理函数提示
	 */
	$handler: "-- 这里填写方法中的手写内容",
}

/**
 * 生成手动代码区域的文本
 */
function genManualAreaCode(key: string, cinfo: { [index: string]: string }, tab: string = "") {
	let manual = cinfo[key];
	if (!manual) {
		if (key in ManualCodeDefaultComment) {
			manual = ManualCodeDefaultComment[key];
		} else {
			manual = ManualCodeDefaultComment.$handler;
		}
	}
	return `${tab}--/*-*begin ${key}*-*/--
${tab}${manual}
${tab}--/*-*end ${key}*-*/--`
}

/**
 * 获取手动写的代码信息
 */
function getManualCodeInfo(file: string) {
	let dict: { [index: string]: string } = {};
	if (file && fs.existsSync(file)) {
		//读取文件内容
		let content = fs.readFileSync(file, "utf8");
		//找到手写内容
		let reg = /[-][-][/][*]-[*]begin[ ]([$]?[a-zA-Z0-9_]+)[*]-[*][/][-][-]([^]*?)[-][-][/][*]-[*]end[ ]\1[*]-[*][/][-][-]/g
		while (true) {
			let result = reg.exec(content);
			if (result) {
				let key = result[1];
				let manual = result[2].trim();
				if (!manual) {//没有注释
					continue;
				} else if (key in ManualCodeDefaultComment) {
					if (ManualCodeDefaultComment[key] == manual) {//类上中下的注释
						continue;
					}
				} else {
					if (ManualCodeDefaultComment.$handler == manual) {//函数注释
						continue;
					}
				}
				dict[key] = manual;
			} else {
				break;
			}
		}
	}
	return dict;
}