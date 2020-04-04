"use strict";
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

interface GlobalCfg {

	/**
	 * 客户端项目路径
	 * 
	 * @type {string}
	 */
	cprefix: string;
	/**
	 * 生成时，使用的wiki地址
	 * 
	 * @type {string}
	 */
	url?: string;
}

interface CodeCfg {
	head: string;
	content: string;
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
		// console.log(content)
		reg = /[/][*]-[*]begin[ ]([$][^]*?)[*]-[*][/]([^]*?)[/][*]-[*]end[ ]\1[*]-[*][/]/mg;
	}
	let codes: CodeCfg[] = []

	let proto = "";
	while (true) {
		let result = reg.exec(content);
		if (result) {
			proto += result[1] + "\n" + result[2] + "\n";
			codes.push({ head: result[1], content: result[2] })
		} else {
			break;
		}
	}
	$g("txtProto").value = proto;
	parseCode(codes, data.gcfg);
}

function parseCode(codes: CodeCfg[], gcfg: GlobalCfg) {
	let url: string = gcfg ? gcfg.url : "";
	url = url || "[文本框中，复制粘贴]";
	let isMulti = false;
	let kv: { [id: string]: string } = {}
	for (let code of codes) {
		var reg: RegExp = /(.*)=(.*)/g;
		let result = reg.exec(code.head);
		if (result == null) {
			error("检查头" + code.head);
			isMulti = true;
			break;
		}
		let contents = code.content.toString().split("\n");
		for (let body of contents) {
			if (body == "") continue;
			let result = body.split("=");
			if (result == null) {
				error("检查" + body);
				isMulti = true;
				break;
			}
			if (kv[result[0]]) {
				error("id重复" + body);
				isMulti = true;
				break;
			}
			kv[result[0].trim()] = result[1].trim();
		}
		if (isMulti) {
			break;
		}
	}
	if (isMulti) return;
	let code = createCodeFile(kv);
	saveCodeFile(gcfg.cprefix, code, "LangFile.lua")
}

function createCodeFile(kv: { [id: string]: string }) {
	let prefix = `local codefile = {`;
	for (let id in kv) {
		let value = kv[id];
		prefix += `\n\t[${id}] = [["${value}"]],`
	}
	prefix += `
}
return codefile`
	return prefix;
}

/**
 * 存储文件
 * 
 */
function saveCodeFile(dir: string, content: string, fname: string) {
	if (!content) return;
	let file = path.join(dir, fname);
	try {
		fs.writeFileSync(file, content);
	}
	catch (e) {
		error(`写入文件时失败，路径："${file}"，错误信息：${e.message}\n${e.stack}`);
		return;
	}
	log(`<font color="#0c0">生成代码成功，${file}</font>`);
}



const escChars = { "&lt;": "<", "&gt;": ">", "&quot;": "\"", "&apos;": "\'", "&amp;": "&", "&nbsp;": " ", "&#x000A;": "\n" };
function escapeHTML(content: string) {
	return content.replace(/&lt;|&gt;|&quot;|&apos;|&amp;|&nbsp;|&#x000A;/g, substring => {
		return escChars[substring];
	});
}

function getProtoFromHttp(url: string, gcfg?: GlobalCfg) {
	// let commonUrl = url.substring(0, url.indexOf("=") + 1) + '%E9%80%9A%E4%BF%A1dto%E5%AF%B9%E8%B1%A1';
	// let commonPromise = getHttpData(commonUrl, gcfg);
	// commonPromise.then(getUrlProtoData, error).catch(error);

	let promise = getHttpData(url, gcfg);
	promise.then(getProtoData, error).catch(error);
}

import CookieForPath from "CookieForPath";

const cookieForPath = new CookieForPath("unitylangTools_");

ready(() => {
	cookieForPath.getPathCookie("txtClientPath");
	cookieForPath.getPathCookie("txtUrl");
	$g("btnGen").addEventListener("click", (ev) => {
		let cPath = cookieForPath.setPathCookie("txtClientPath");
		// 清理code区
		$g("code").innerHTML = "";
		// 检查url路径
		let url: string = cookieForPath.setPathCookie("txtUrl", false, false);
		url = url.trim();
		let gcfg: GlobalCfg = { cprefix: cPath, url: url };
		if (url) {
			getProtoFromHttp(url, gcfg);
		} else {
			error("没有填写code码wiki地址。")
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
