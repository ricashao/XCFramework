const ConfigKeyReg = /interface\s*IConfigKey\s*[{]([^]+)[}]/g;
const ConfigItem = /([/][*][^]+?[*][/])?\s+([a-zA-Z_0-9]+)\s*?:\s*string;/g;
// 查找是否有ConfigKey.${key}
const regValue = /ConfigKey[.]([a-zA-Z_0-9]+)\s*=\s*"([a-zA-Z_0-9]+)";/g;
const regCfg = /DataLocator[.]regCommonParser[(]ConfigKey[.]([a-zA-Z_0-9]+)\s*,\s*jrequire[(]"([a-zA-Z_0-9]+)"[)](?:\s*,\s*("[a-zA-Z_0-9.]+"))?[)];/g;
const extCfg = /DataLocator[.]regExtra[(]ConfigKey[.]([a-zA-Z_0-9]+)[)];/g
var fs = nodeRequire("fs");

export default class ServerRegTemplate {
    /**
     * 添加数据到文件
     * 
     * @param {string} file (description)
     * @param {string} key (description)
     * @return [{string} 错误描述,{string} 生成的代码]
     */
    public addToFile(file: string, key: string, hasExtra: boolean) {
        let interfaceDic: Map<string, string> = new Map();
        let valueDic: Map<string, string> = new Map();
        let regDic: Map<string, any[]> = new Map();
        let extlist: string[] = [];
        if (!fs.existsSync(file) || !fs.statSync(file).isFile()) {
            return ["SERVER无法找到文件", this.addContent(key, interfaceDic, valueDic, regDic, extlist, hasExtra)];
        }
        let content = fs.readFileSync(file, "utf8");
        ConfigKeyReg.lastIndex = 0;
        let resCK = ConfigKeyReg.exec(content);
        // 检查ConfigKey常量
        if (resCK) {
            let cfgs = resCK[1];
            ConfigItem.lastIndex = 0;
            while (true) {
                let res = ConfigItem.exec(cfgs);
                if (res) {
                    interfaceDic.set(res[2], res[0].trim());
                } else {
                    break;
                }
            }
        }

        regValue.lastIndex = 0;
        while (true) {
            let res = regValue.exec(content);
            if (res) {
                valueDic.set(res[1], res[2]);
            } else {
                break;
            }
        }
        regCfg.lastIndex = 0;
        while (true) {
            let res = regCfg.exec(content);
            if (res) {
                regDic.set(res[1], [res[2], res[3]]);
            } else {
                break;
            }
        }
        extCfg.lastIndex = 0;
        while (true) {
            let res = extCfg.exec(content);
            if (res) {
                extlist.push(res[1]);
            } else {
                break;
            }
        }
        return [null, this.addContent(key, interfaceDic, valueDic, regDic, extlist, hasExtra)];
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
    private addContent(key: string, interfaceDic: Map<string, string>, valueDic: Map<string, string>, regDic: Map<string, any[]>, extlist: string[], hasExtra: boolean) {
        let added = false;
        let code = `var DataLocator = jrequire("DataLocator");

interface IConfigKey {
`;
        for (let k of interfaceDic.keys()) {
            if (k == key) {
                added = true;
            }
            code += `\t${interfaceDic.get(k)}\n`;
        }
        if (!added) {
            code += `\t${key}: string;\n`;
        }
        code += "}\n";
        added = false;

        for (let k of valueDic.keys()) {
            if (k == key) {
                added = true;
            }
            code += `ConfigKey.${k} = "${valueDic.get(k)}";\n`;
        }
        if (!added) {
            code += `ConfigKey.${key} = "${key}";\n`;
        }

        added = false;
        for (let k of regDic.keys()) {
            if (k == key) {
                added = true;
            }
            let arr = regDic.get(k);
            let idKey = arr[1] !== undefined ? ", " + arr[1] : "";
            code += `DataLocator.regCommonParser(ConfigKey.${k}, jrequire("${arr[0]}")${idKey});\n`;
        }
        if (!added) {
            code += `DataLocator.regCommonParser(ConfigKey.${key}, jrequire("${key}Cfg"));\n`;
        }

        code += "\n";
        added = false;
        //附加数据
        for (let k of extlist) {
            if (k == key) {
                added = true;
            }
            code += `DataLocator.regExtra(ConfigKey.${k});\n`;
        }
        if (!added && hasExtra) {
            code += `DataLocator.regExtra(ConfigKey.${key});\n`;
        }
        return code;
    }
}