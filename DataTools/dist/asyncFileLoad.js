define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    function asyncFileLoad(url, callback) {
        if (/^http:\/\//.test(url)) {
            var http = nodeRequire("http");
            http.get(url, res => {
                let chunks = [];
                res.on("data", chunk => {
                    chunks.push(chunk);
                });
                res.on("end", () => {
                    callback(null, Buffer.concat(chunks));
                });
            }).on("error", (e) => {
                callback(e);
            });
        }
        else {
            var fs = nodeRequire("fs");
            fs.exists(url, exists => {
                if (exists) {
                    fs.readFile(url, callback);
                }
                else {
                    callback(Error(`无法找到指定文件${url}`));
                }
            });
        }
    }
    exports.default = asyncFileLoad;
});
//# sourceMappingURL=asyncFileLoad.js.map