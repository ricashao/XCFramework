define(["require", "exports"], function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    /**
     * 数值类型在解析json的时候，字符串会多两个""，数值更节省
     *
     * @param {*} value (description)
     * @returns (description)
     */
    function tryParseNumber(value) {
        if (typeof value === "boolean") {
            return value ? 1 : 0;
        }
        if (value == +value && value.length == (+value + "").length) { // 数值类型
            // "12132123414.12312312"==+"12132123414.12312312"
            // true
            // "12132123414.12312312".length==(+"12132123414.12312312"+"").length
            // false
            return +value;
        }
        else {
            return value;
        }
    }
    /**
     * 处理 any 类型的数据
     *
     * @class AnyChecker
     * @implements {TypeChecker}
     */
    class AnyChecker {
        get type() {
            return "any";
        }
        get javaType() {
            return "String";
        }
        get idx() {
            return 0;
        }
        check(value) {
            return tryParseNumber(value);
        }
    }
    /**
     * 处理 string 类型的数据
     *
     * @class StringChecker
     * @implements {TypeChecker}
     */
    class StringChecker {
        get type() {
            return "string";
        }
        get javaType() {
            return "String";
        }
        get idx() {
            return 1;
        }
        check(value) {
            return value;
        }
    }
    /**
     * 处理 number 类型的数据
     *
     * @class NumberChekcer
     * @implements {TypeChecker}
     */
    class NumberChekcer {
        get type() {
            return "number";
        }
        get javaType() {
            return "double";
        }
        get idx() {
            return 2;
        }
        check(value) {
            value = value.trim();
            if (!value) {
                return 0;
            }
            if (value.split(".").length <= 2 && (/^-?[0-9.]+e[0-9]+$/i.test(value) || /^-?0b[01]+$/.test(value) || /^-?0x[0-9a-f]+$/i.test(value) || /^-?[0-9.]+$/.test(value))) {
                return +value;
            }
            else {
                throw new ValueTypeError("number", value);
            }
        }
    }
    /**
     * 处理 boolean 类型的数据
     *
     * @class BooleanChecker
     * @implements {TypeChecker}
     */
    class BooleanChecker {
        constructor() {
            this.solveString = `!!{value}`;
        }
        get type() {
            return "boolean";
        }
        get javaType() {
            return "bool";
        }
        get idx() {
            return 3;
        }
        check(value) {
            if (!value || value.toLowerCase() == "false") {
                return 0;
            }
            else {
                return 1;
            }
        }
    }
    /**
     * 处理 | 类型的数据
     *
     * @class ArrayCheker
     * @implements {TypeChecker}
     */
    class ArrayCheker {
        get type() {
            return "any[]";
        }
        get javaType() {
            return "Object[]";
        }
        get idx() {
            return 4;
        }
        check(value) {
            let arr = value.split(":");
            arr.forEach((item, idx) => {
                arr[idx] = tryParseNumber(item);
            });
            return arr;
        }
    }
    /**
     * 处理 |: 类型的二维数组的数据
     *
     * @class Array2DCheker
     * @implements {TypeChecker}
     */
    class Array2DCheker {
        get type() {
            return "any[][]";
        }
        get javaType() {
            return "Object[][]";
        }
        get idx() {
            return 5;
        }
        check(value) {
            let arr = value.split("|");
            arr.forEach((item, idx) => {
                let subArr = item.split(":");
                arr[idx] = subArr;
                subArr.forEach((sitem, idx) => {
                    subArr[idx] = tryParseNumber(sitem);
                });
            });
            return arr;
        }
    }
    function isLeapYear(year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 100 == 0 && year % 400 == 0);
    }
    const nday = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    function checkDate(value) {
        let res = /^(20[1-9][0-9])-(0\d+|1[0,1,2])-(\d+)$/.exec(value);
        if (res) {
            var year = +res[1];
            var month = +res[2];
            var day = +res[3];
        }
        else {
            return false;
        }
        if (day < 1) {
            return false;
        }
        let maxDay;
        if (month == 2 && isLeapYear(year)) {
            maxDay = 29;
        }
        else {
            maxDay = nday[month - 1];
        }
        if (day > maxDay) {
            return false;
        }
        return true;
    }
    function checkTime(value) {
        let res = /^(\d{2}):(\d{2})$/.exec(value);
        if (res) {
            var h = +res[1];
            var m = +res[2];
        }
        else {
            return null;
        }
        if (h < 0 || h >= 24) {
            return null;
        }
        if (m < 0 || m >= 60) {
            return null;
        }
        return { h: h, m: m };
    }
    /**
     * 日期检查器 yyyy-MM-dd
     *
     * @class DateChecker
     * @implements {TypeChecker}
     */
    class DateChecker {
        constructor() {
            this.solveString = `new Date({value}*10000)`;
        }
        get type() {
            return "Date";
        }
        get javaType() {
            return "String";
        }
        get idx() {
            return 6;
        }
        check(value) {
            if (!checkDate(value)) {
                throw new ValueTypeError("yyyy-MM-dd", value);
            }
            // 用8位数字代替 10位字符串（JSON后变成12位）
            return new Date(value + " UTC").getTime() * 0.0001;
        }
    }
    /**
     * 时间检查器 HH:mm
     *
     * @class TimeChecker
     * @implements {TypeChecker}
     */
    class TimeChecker {
        constructor() {
            this.solveString = `new TimeVO({value})`;
        }
        get type() {
            return "TimeVO";
        }
        get javaType() {
            return "String";
        }
        get idx() {
            return 7;
        }
        check(value) {
            let time = checkTime(value);
            if (!time) {
                throw new ValueTypeError("HH:mm", value);
            }
            return value;
        }
    }
    /**
     * 日期时间检查器 yyyy-MM-dd HH:mm
     *
     * @class DateTimeChecker
     * @implements {TypeChecker}
     */
    class DateTimeChecker {
        constructor() {
            this.solveString = `new Date({value}*10000)`;
        }
        get type() {
            return "Date";
        }
        get javaType() {
            return "String";
        }
        get idx() {
            return 8;
        }
        check(value) {
            let t = value.split(" ");
            let date = t[0];
            let time = t[1];
            if (!checkDate(date) || !checkTime(time)) {
                throw new ValueTypeError("yyyy-MM-dd HH:mm", value);
            }
            // 使用UTC时间进行存储，解析的时候，改用服务器时区
            return new Date(value + " UTC").getTime() * 0.0001;
        }
    }
    /**
     * ValueTypeError
     */
    class ValueTypeError extends Error {
        constructor(type, value) {
            super();
            this.message = `数据和类型不匹配，当前类型：${type}，数据：${value}`;
        }
    }
    exports.ValueTypeError = ValueTypeError;
    let checkers = {};
    exports.TypeCheckers = checkers;
    // number	string	boolean	:	|:	yyyy-MM-dd	yyyy-MM-dd HH:mm HH:mm
    checkers[""] = new AnyChecker;
    checkers["number"] = new NumberChekcer;
    checkers["string"] = new StringChecker;
    checkers["boolean"] = new BooleanChecker;
    checkers[":"] = new ArrayCheker;
    checkers["|:"] = new Array2DCheker;
    checkers["yyyy-MM-dd"] = new DateChecker;
    checkers["HH:mm"] = new TimeChecker;
    checkers["yyyy-MM-dd HH:mm"] = new DateTimeChecker;
});
//# sourceMappingURL=TypeCheckers.js.map