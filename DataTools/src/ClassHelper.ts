
var fs = nodeRequire("fs");
var path = nodeRequire("path");
/**
 * 用于辅助加载模块
 * @author 3tion
 */
export default class ClassHelper {
    /**
     * 类的字典
     * Key      {string}    类名
     * Value    {string}    类的相对路径
     */
    private _classPathDict: { [index: string]: string };

    /**
     * 基础地址
     */
    public get base(): string {
        return this._base;
    }

    private _base: string;

    private walkDirSync(dir: string, dict: { [index: string]: string }, excludeReg?: RegExp) {
        var dirList = fs.readdirSync(dir);
        dirList.forEach((item) => {
            var lowerItem = item.toLowerCase();
            var tpath = path.join(dir, item);
            if (!excludeReg || tpath.search(excludeReg) == -1) {
                if (fs.statSync(tpath).isDirectory()) {
                    this.walkDirSync(tpath, dict, excludeReg);
                } else {
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
    public initClassHelper(base: string) {
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
    public getRelativePath(className: string, base: string) {
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
    public getJavaPackage(className: string, base: string) {
        let tpath = this._classPathDict[className];
        if (!tpath) {
            return null;
        }
        tpath = path.relative(base, tpath).replace(/\\|\//g, ".");
        return tpath;
    }
}