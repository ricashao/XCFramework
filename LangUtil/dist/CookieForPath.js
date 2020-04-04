define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    const $g = (id) => { return document.getElementById(id); };
    const fs = nodeRequire("fs");
    class CookieForPath {
        constructor(key) {
            this._key = key;
        }
        getPathCookie(id) {
            let sPath = cookie.getCookie(this._key + id);
            if (sPath) {
                $g(id).value = sPath;
            }
        }
        setPathCookie(id, checkExists = true, checkDirectory = true) {
            let v = $g(id).value;
            v = v.trim();
            $g(id).value = v;
            let flag = false;
            if (v) {
                if (checkExists) {
                    if (fs.existsSync(v)) {
                        let re = fs.statSync(v);
                        if (checkDirectory) {
                            if (re.isDirectory()) {
                                flag = true;
                            }
                        }
                        else {
                            flag = true;
                        }
                    }
                }
                else {
                    flag = true;
                }
                if (flag) {
                    cookie.setCookie(this._key + id, v);
                    return v;
                }
            }
            return undefined;
        }
    }
    exports.default = CookieForPath;
});
//# sourceMappingURL=CookieForPath.js.map