define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    var fs = nodeRequire("fs");
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
         * 处理函数提示
         */
        $decode: "//这里填写方法中的手写内容",
    };
    exports.ManualCodeDefaultComment = ManualCodeDefaultComment;
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
                throw Error(`错误的区域标识${key}`);
            }
        }
        return `/*-*begin ${key}*-*/
${manual}
/*-*end ${key}*-*/`;
    }
    exports.genManualAreaCode = genManualAreaCode;
    /**
     * 获取手动写的代码信息
     */
    function getManualCodeInfo(file) {
        let dict = {};
        if (fs.existsSync(file)) {
            //读取文件内容
            let content = fs.readFileSync(file, "utf8");
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
                    dict[key] = manual;
                }
                else {
                    break;
                }
            }
        }
        return dict;
    }
    exports.getManualCodeInfo = getManualCodeInfo;
});
//# sourceMappingURL=MenualCodeHelper.js.map