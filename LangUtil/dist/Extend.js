/**
 * 文档是否加载好
 *
 * @param {{ (e?: UIEvent): void }} fn (description)
 */
function ready(fn) {
    if (document.readyState != 'loading') {
        fn();
    }
    else {
        document.addEventListener('DOMContentLoaded', fn);
    }
}
/**
 * 对数字进行补0操作
 * @param value 要补0的数值
 * @param length 要补的总长度
 * @return 补0之后的字符串
 */
function zeroize(value, length = 2) {
    let str = "" + value;
    let zeros = "";
    for (let i = 0, len = length - str.length; i < len; i++) {
        zeros += "0";
    }
    return zeros + str;
}
Object.defineProperties(Object.prototype, {
    "getPropertyDescriptor": {
        value: function (property) {
            var data = Object.getOwnPropertyDescriptor(this, property);
            if (data) {
                return data;
            }
            var prototype = Object.getPrototypeOf(this);
            if (prototype) {
                return prototype.getPropertyDescriptor(property);
            }
            return null;
        },
        enumerable: false
    },
    "copyto": {
        value: function (to) {
            for (let p in this) {
                var data = to.getPropertyDescriptor(p);
                if (data && data.set) {
                    to[p] = this[p];
                }
            }
        },
        enumerable: false
    }
});
Math.clamp = (value, min, max) => {
    if (value < min) {
        value = min;
    }
    if (value > max) {
        value = max;
    }
    return value;
};
Object.defineProperties(Number.prototype, {
    "zeroize": {
        value: function (length) { return zeroize(this, length); },
        enumerable: false
    }
});
Object.defineProperties(String.prototype, {
    "zeroize": {
        value: function (length) { return zeroize(this, length); },
        enumerable: false
    },
    "substitute": {
        value: function () {
            var len = arguments.length;
            if (len > 0) {
                var obj;
                if (len == 1) {
                    obj = arguments[0];
                    if (typeof obj !== "object") {
                        obj = arguments;
                    }
                }
                else {
                    obj = arguments;
                }
                if ((obj instanceof Object) && !(obj instanceof RegExp)) {
                    return this.replace(/\{([^{}]+)\}/g, function (match, key) {
                        var value = obj[key];
                        return (value !== undefined) ? '' + value : '';
                    });
                }
            }
            return this;
        },
        enumerable: false
    }
});
String["zeroize"] = zeroize;
Object.defineProperties(Date.prototype, {
    "format": {
        value: function (mask) {
            let d = this;
            return mask.replace(/"[^"]*"|'[^']*'|(?:d{1,2}|m{1,2}|yy(?:yy)?|([hHMs])\1?)/g, function ($0) {
                switch ($0) {
                    case "d": return d.getDate();
                    case "dd": return zeroize(d.getDate());
                    case "M": return d.getMonth() + 1;
                    case "MM": return zeroize(d.getMonth() + 1);
                    case "yy": return String(d.getFullYear()).substr(2);
                    case "yyyy": return d.getFullYear();
                    case "h": return d.getHours() % 12 || 12;
                    case "hh": return zeroize(d.getHours() % 12 || 12);
                    case "H": return d.getHours();
                    case "HH": return zeroize(d.getHours());
                    case "m": return d.getMinutes();
                    case "mm": return zeroize(d.getMinutes());
                    case "s": return d.getSeconds();
                    case "ss": return zeroize(d.getSeconds());
                    default: return $0.substr(1, $0.length - 2);
                }
            });
        },
        enumerable: false
    }
});
//# sourceMappingURL=Extend.js.map