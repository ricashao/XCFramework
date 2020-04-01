/**
 * 向文件写入JSON数据
 * 
 * @export
 * @param {File} file 拖入的文件
 * @param {string} directory 要存储的文件路径
 * @param {*} data 数据
 * @returns {string}   存储成功返回文件路径<br/>
 *                     存储失败返回null
 */
function writeJSONData(fname: string, directory: string, data: any): string {
    const path = nodeRequire("path");
    const fs = nodeRequire("fs");
    if (fs.existsSync(directory)) {
        let stat = fs.statSync(directory);
        if (stat.isDirectory()) {
            let outpath = path.join(directory, fname + ".json");
            fs.writeFileSync(outpath, JSON.stringify(data));
            return outpath;
        }
    }
    return null;
}


function writeCfgJSONData(fname: string, cfgpath: string, data: any): string {
    const path = nodeRequire("path");
    const fs = nodeRequire("fs");
    if (fs.existsSync(cfgpath)) {
        let datas = fs.readFileSync(cfgpath, "utf8");
        let cfgs = JSON.parse(datas);
        cfgs[fname] = data
        fs.writeFileSync(cfgpath, JSON.stringify(cfgs));
        return cfgpath;
    }
    return null;
}

function writeStringData(fname: string, directory: string, data: any, suffix: string): string {
    const path = nodeRequire("path");
    const fs = nodeRequire("fs");
    if (fs.existsSync(directory)) {
        let stat = fs.statSync(directory);
        if (stat.isDirectory()) {
            let outpath = path.join(directory, fname + suffix);
            fs.writeFileSync(outpath, data);
            return outpath;
        }
    }
    return null;
}

function writeByteArray(fname: string, directory: string, data: any, suffix: string): string {
    const path = nodeRequire("path");
    const fs = nodeRequire("fs");
    if (fs.existsSync(directory)) {
        let stat = fs.statSync(directory);
        if (stat.isDirectory()) {
            let outpath = path.join(directory, '/jat', fname + suffix);
            let jsonPath = path.join(directory, '/jat', fname + ".json");
            var exec = nodeRequire('child_process').exec;
            var xx = JSON.stringify(data);
            //let cc = xx.replace(/\"/g, '\\"');
            console.log(xx.length);
            fs.writeFileSync(jsonPath, xx);
            exec(`java -jar d:\\exportJat.jar ${jsonPath} ${outpath}`, function (err, stdout, stderr) {
                console.log(err);
                console.log(stdout);
                console.log(stderr);
                // var data = fs.readFileSync(outpath, "utf-8");
                // if (fs.existsSync(remoteDirectory)) {
                //     let stat = fs.statSync(remoteDirectory);
                //     if (stat.isDirectory()) {
                //         outpath = path.join(remoteDirectory, "/jat", fname + suffix);
                //         fs.writeFileSync(outpath, data);
                //     }
                //}
            });
            //fs.writeFileSync(outpath, JSON.stringify(data));
            return outpath;
        }
    }

    return null;
}

function svnCommit(fname: string, directory: string, data: any, suffix: string) : string{
    const path = nodeRequire("path");
    const fs = nodeRequire("fs");
    const exec = nodeRequire('child_process').exec;
    if (fs.existsSync(directory)) {
        let stat = fs.statSync(path.dirname(directory));
        if (stat.isDirectory()) {
            let outpath = path.join(directory,'../../../data/CN',fname + suffix);
            fs.exists(outpath, function(exists){
                if(exists){
                    exec(`svn update ${outpath}`, function callback(error, stdout, stderr){
                        console.log(`svn update ${outpath}`);
                        console.log("update"+error);
                        console.log("update"+stdout);
                        fs.writeFileSync(outpath, data);
                        commit(outpath, fname);
                    });
                }else{
                    fs.writeFileSync(outpath, data);
                    commit(outpath, fname);
                }
            });
            return outpath;
        }
    }
    return null;
}

function commit(outpath : string, fname: string){
     var exec = nodeRequire('child_process').exec;
    exec(`svn status ${outpath}`,function callback(error, stdout, stderr) {
                console.log("status"+error);
                console.log("status"+stdout);
                    if(stdout){
                        if(stdout.substring(0,1)=='?'){
                            exec(`svn add ${outpath}`,function callback(error, stdout, stderr) {
                                 console.log("add"+error);
                                 console.log("add"+stdout);
                                 exec(`svn commit ${outpath} -m ${fname}`);
                             });
                        }
                        else if(stdout.substring(0,1)=='M'){
                            exec(`svn commit ${outpath} -m ${fname}`);
                        }
                    }
            });
}
export {writeJSONData,writeCfgJSONData, writeStringData, svnCommit, writeByteArray};