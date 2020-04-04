var nodeRequire = nodeRequire || require;
var FsExtra = (function () {
    const fs = nodeRequire("fs");
    const path = nodeRequire("path");
    function mkdirs(paths) {
        var len = paths.length;
        if (len == 0) {
            throw Error("路径无效" + paths);
        }
        var p = paths[0];
        if (!fs.existsSync(p)) {
            throw Error("没有根目录" + p);
        }
        for (var i = 1, len = paths.length; i < len; i++) {
            p = path.join(p, paths[i]);
            if (fs.existsSync(p)) {
                var ret = fs.statSync(p);
                if (!ret.isDirectory()) {
                    throw Error("无法创建文件夹" + p);
                }
            }
            else {
                fs.mkdirSync(p);
            }
        }
    }
    var xfs = {
        /**
         * 将文件夹拆分
         */
        split: function (filePath) {
            return path.normalize(filePath).split(path.sep);
        },
        /**
         * 同步创建文件夹
         */
        mkdirs: function (filePath) {
            mkdirs(xfs.split(filePath));
        },
        /**
         * 写文件
         */
        writeFileSync: function (filePath, data, isCorver = true, options) {
            var re = path.parse(filePath);
            mkdirs(xfs.split(re.dir));
            if (isCorver || !fs.existsSync(filePath)) {
                fs.writeFileSync(filePath, data, options);
            }
        }
    };
    return xfs;
}());
//# sourceMappingURL=FsExtra.js.map