define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const CConfigKeyReg = /export\s*interface\s*IConfigKey\s*[{]([^]+)[}]/g;
    const CConfigItem = /([/][*][^]+?[*][/])?\s+([a-zA-Z_0-9]+)\s*:\s*string;/g;
    const CValueItem = /([a-zA-Z_0-9]+)\s*:\s*"([a-zA-Z_0-9]+)"/g;
    const regCfg = /rP[(]C[.]([a-zA-Z_0-9]+)\s*,\s*([a-zA-Z_0-9.]+)(?:\s*,\s*("[a-zA-Z_0-9.]+"))?[)];/g;
    const extCfg = /rE[(]C[.]([a-zA-Z_0-9]+)[)];/g;
    var fs = nodeRequire("fs");
    class ClientRegTemplate {
        /**
        * 添加数据到文件
        *
        * @param {string} file (description)
        * @param {string} key (description)
        * @return [{string} 错误描述,{string} 生成的代码]
        */
        addToFile(file, key, pak, hasExtra) {
            let interfaceDic = new Map();
            let valueDic = new Map();
            let regDic = new Map();
            let extlist = [];
            if (!fs.existsSync(file) || !fs.statSync(file).isFile()) {
                return ["CLIENT无法找到文件", this.addContent(key, interfaceDic, valueDic, regDic, pak, extlist, hasExtra)];
            }
            let content = fs.readFileSync(file, "utf8");
            CConfigKeyReg.lastIndex = 0;
            let resCK = CConfigKeyReg.exec(content);
            // 检查ConfigKey常量
            if (resCK) {
                let cfgs = resCK[1];
                CConfigItem.lastIndex = 0;
                while (true) {
                    let res = CConfigItem.exec(cfgs);
                    if (res) {
                        interfaceDic.set(res[2], res[0].trim());
                    }
                    else {
                        break;
                    }
                }
            }
            CValueItem.lastIndex = 0;
            while (true) {
                let res = CValueItem.exec(content);
                if (res) {
                    valueDic.set(res[1], res[2]);
                }
                else {
                    break;
                }
            }
            regCfg.lastIndex = 0;
            while (true) {
                let res = regCfg.exec(content);
                if (res) {
                    regDic.set(res[1], [res[2], res[3]]);
                }
                else {
                    break;
                }
            }
            extCfg.lastIndex = 0;
            while (true) {
                let res = extCfg.exec(content);
                if (res) {
                    extlist.push(res[1]);
                }
                else {
                    break;
                }
            }
            return [null, this.addContent(key, interfaceDic, valueDic, regDic, pak, extlist, hasExtra)];
        }
        /**
         * 添加内容
         *
         * @param {string} key (description)
         * @param {Map<string, string>} interfaceDic (description)
         * @param {Map<string, string>} valueDic (description)
         * @param {Map<string, string>} regDic (description)
         * @returns (description)
         */
        addContent(key, interfaceDic, valueDic, regDic, pak, extlist, hasExtra) {
            let added = false;
            let code = `namespace xc.h5g {
\texport interface IConfigKey {
`;
            for (let k of interfaceDic.keys()) {
                if (k == key) {
                    added = true;
                }
                code += `\t\t${interfaceDic.get(k)}\n`;
            }
            if (!added) {
                code += `\t\t${key}: string;\n`;
            }
            code += `\t}
`;
            added = false;
            code += `\tConfigKey = {
`;
            for (let k of valueDic.keys()) {
                if (k == key) {
                    added = true;
                }
                code += `\t\t${k}: "${valueDic.get(k)}",\n`;
            }
            if (!added) {
                code += `\t\t${key}: "${key}",\n`;
            }
            code += `\t}
\tfunction rP(key: string, CfgCreator: { new (): ICfg }, idkey: string = "id") {
\t\tDataLocator.regCommonParser(key, CfgCreator, idkey);
\t}
\tfunction rE(key: string) {
\t\tDataLocator.regExtra(key);
\t}
\texport function initData() {
\t\tvar C = ConfigKey;
\t\tvar P = ${pak};
`;
            added = false;
            for (let k of regDic.keys()) {
                if (k == key) {
                    added = true;
                }
                let arr = regDic.get(k);
                let idKey = arr[1] !== undefined ? ", " + arr[1] : "";
                code += `\t\trP(C.${k}, ${arr[0]}${idKey});\n`;
            }
            if (!added) {
                code += `\t\trP(C.${key}, P.${key}Cfg);\n`;
            }
            code += "\n";
            added = false;
            //附加数据
            for (let k of extlist) {
                if (k == key) {
                    added = true;
                }
                code += `\t\trE(C.${k});\n`;
            }
            if (!added && hasExtra) {
                code += `\t\trE(C.${key});\n`;
            }
            code += `\t}
}`;
            return code;
        }
    }
    exports.default = ClientRegTemplate;
});
//# sourceMappingURL=ClientRegTemplate.js.map