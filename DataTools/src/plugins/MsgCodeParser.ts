function writeJSONData(fname: string, directory: string, data: any): string {
    const path = require("path");
    const fs = require("fs");
    if (fs.existsSync(directory)) {
        let stat = fs.statSync(directory);
        if (stat.isDirectory()) {
            let outpath = path.join(directory + "", fname + ".json");
            fs.writeFileSync(outpath, JSON.stringify(data));
            return outpath;
        }
    }
    return null;
}

function execute(data: IPluginData, callback: IPluginCallback) {
    let list = data.rawData;
    // 检查第一行
    let cfg = {
        code: 1,//默认第一列
        msg: 2//默认第二列
    }
    let title: any[] = list[data.rowCfg["nameRow"]];
    let KeyFlag = 0;
    for (let col = 0, len = title.length; col <= len; col++) {
        let cell = title[col];
        if (cell) {
            cell = cell.trim();
        }
        if (cell == "code") {
            cfg.code = col;
            KeyFlag |= 0b1;
        } else if (cell == "msg") {
            cfg.msg = col;
            KeyFlag |= 0b10;
        }
    }
    if (KeyFlag != 0b11) {
        callback(Error(`code码表中第一列必须有抬头"code"和"msg"`));
        return;
    }
    let msgDict = {};
    // 去掉第一行说明
    for (let i = data.dataRowStart, len = list.length; i < len; i++) {
        let rowData = list[i];
        msgDict[rowData[cfg.code]] = rowData[cfg.msg];
    }
    // 存储文件
    let output = "";
    let fname = data.filename;
    let cpath = writeJSONData(fname, data.gcfg.clientPath, msgDict);
    if (cpath) {
        output = `处理code码文件${fname}，将客户端数据保存至：${cpath}`;
    } else {
        output = `文件code码文件${fname}，未将客户端数据保存到${cpath}，请检查`;
    }
    callback(null, output);
}