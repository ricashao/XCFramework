define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    var fs = nodeRequire("fs");
    var path = nodeRequire("path");
    /**
     * 用于辅助加载模块
     * @author 3tion
     */
    class ClassHelper {
        /**
         * 基础地址
         */
        get base() {
            return this._base;
        }
        walkDirSync(dir, dict, excludeReg) {
            var dirList = fs.readdirSync(dir);
            dirList.forEach((item) => {
                var lowerItem = item.toLowerCase();
                var tpath = path.join(dir, item);
                if (!excludeReg || tpath.search(excludeReg) == -1) {
                    if (fs.statSync(tpath).isDirectory()) {
                        this.walkDirSync(tpath, dict, excludeReg);
                    }
                    else {
                        let re = path.parse(item);
                        if (re.ext == ".ts") {
                            item = re.name;
                            if (item in dict) {
                                throw Error(`${item}重名`);
                            }
                            dict[item] = tpath;
                        }
                    }
                }
            });
        }
        /**
         * 初始化类辅助
         *
         * @param {string} base 源码路径
         */
        initClassHelper(base) {
            this._base = base;
            this._classPathDict = {};
            if (base) {
                this.walkDirSync(base, this._classPathDict);
            }
        }
        /**
         * 获取相对路径
         *
         * @param {string} className 类名
         */
        getRelativePath(className, base) {
            let tpath = this._classPathDict[className];
            if (!tpath) {
                return null;
            }
            tpath = path.relative(base, tpath).replace(/\\/g, "/");
            if (tpath.split("/").length == 1) {
                tpath = "./" + tpath;
            }
            return tpath;
        }
        /**
         * 获取Java的完整路径名
         *
         * @param {string} className
         * @param {string} base
         * @returns
         *
         * @memberOf ClassHelper
         */
        getJavaPackage(className, base) {
            let tpath = this._classPathDict[className];
            if (!tpath) {
                return null;
            }
            tpath = path.relative(base, tpath).replace(/\\|\//g, ".");
            return tpath;
        }
    }
    exports.default = ClassHelper;
});
//# sourceMappingURL=ClassHelper.js.map