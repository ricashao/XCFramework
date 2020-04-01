/**
 * 全局配置
 */
interface GlobalCfg {
    /**
     * 远程的配置路径
     * 
     * @type {string}
     */
    remote?: string;
    /**
     * 项目名称
     * 
     * @type {string}
     */
    project: string;
    /**
     * 客户端配置导出路径
     * 
     * @type {string}
     */
    clientPath: string;

    /**
     * 服务端配置导出路径
     * 
     * @type {string}
     */
    serverPath: string;

    /**
     * 服务端用于注册常量和引用的类
     *  ///ts:import=DataLocator
        import DataLocator = require('./junyou/common/configs/DataLocator'); ///ts:import:generated
     *  ///ts:import=SkillCfg
        import SkillCfg = require('./huaqiangu/battle/skills/SkillCfg'); ///ts:import:generated
        var ConfigKey = {
             /**
             * 技能模板表
             */
    /*      JiNengMoBan: "JiNengMoBan"
       }
       // 注册常规解析器
       DataLocator.regCommonParser(ConfigKey.JiNengMoBan, JiNengMoBanCfg);

       export = ConfigKey;
    * @type {string}
    */
    serverRegClass?: [string, string];

    /**
     * 客户端用于注册常量和引用的类
     * 
     * @type {string}
     */
    clientRegClass?: [string, string];
    /**
     * 
     * 执行完成后调用的脚本
     * @type {string}
     */
    endScript?: string;

    /**
     * 
     * 执行完成后调用的url
     * @type {string}
     */
    endAction?: string;
}

/**
 * 属性定义
 */
interface ProDefine {

    /**
     * 属性名称
     * 
     * @type {string}
     */
    name: string;

    /**
     * 描述
     * 
     * @type {string}
     */
    desc: string;

    /**
     * 默认值
     * 
     * @type {*}
     */
    def: any;

    /**
     * 是否导出客户端数据
     * 0 不解析
     * 1 解析，并在代码生成时，生成类型对应的字段
     * 2 解析，生成代码时，在decode方法中，由临时变量记录数据，不生成方法
     * 
     * @type {number}
     */
    client: number;

    /**
     * 是否导出服务端数据
     * 0 不解析
     * 1 解析，并在代码生成时，生成类型对应的字段
     * 2 解析，生成代码时，在decode方法中，由临时变量记录数据，不生成方法
     * @type {number}
     */
    server: number;

    /**
     * 数据类型检查器
     * 
     * @type {TypeChecker}
     */
    checker: TypeChecker;

    /**
     * 数据类型服务器解析用
     * 
     * @type {string}
     */
    type: String;
}

/**
 * 检查数据是否符合类型，否则抛错
 * 
 * @interface TypeChecker
 */
interface TypeChecker {

    type: string;
    /**
     * java类型
     * 
     * @type {string}
     * @memberOf TypeChecker
     */
    javaType:string;
    /**
     * 
     * 类型索引值
     * @type {number}
     */
    idx: number;
    /**
     * 检查并返回处理后的数据
     * 
     * @param {string} value 待处理的数据
     * @returns {any} 
     * @throw {ValueTypeError}
     */
    check(value: string): any;

    solveString?: string;

    solveJavaString?:string;
}

interface IPluginData {
    gcfg: GlobalCfg;
    /**
     * 文件名
     * @type {string}
     */
    filename: string;
    /**原始数据 */
    rawData: any[];
    /**服务器数据 */
    sdatas: any[];
    /**客户端数据 */
    cdatas: any[];
    /**
     * 
     * 列定义
     * @type {ProDefine[]}
     */
    defines: ProDefine[];
    /**
     * 
     * 数据起始行
     * @type {number}
     */
    dataRowStart: number;

    /**
     * 行配置对应的行数
     * Key  {string}    配置名称     
            "程序配置内容": "cfgRow",
            "前端解析": "clientRow",
            "后端解析": "serverRow",
            "默认值": "defaultRow",
            "数据类型": "typeRow",
            "描述": "desRow",
            "属性名称": "nameRow"

       Value {number}   行号
     * 
     * @type {{ [index: string]: number }}
     */
    rowCfg: { [index: string]: number };
}

/**
 * 
 * 插件回调
 * @interface IPluginCallback
 */
interface IPluginCallback {

    /**
     * 
     * 
     * @param {Error} [err]           错误信息
     * @param {string} [output]     输出的字符串
     * @param {any[]} [sdatas]      处理后的服务端数据
     * @param {any[]} [cdatas]      处理后的客户端数据
     */
    (err: Error, output?: string, sdatas?: any[], cdatas?: any[]): void
}

/**
 * 
 * 插件定义
 * @interface IPlugin
 */
interface IPlugin {

    /**
     * 
     * 运行插件
     * @param {IPluginData} data
     * @param {IPluginCallback} callback
     */
    execute(data: IPluginData, callback: IPluginCallback);
}

interface IPluginLoaderCallback {
    type: string;
    error?: number;
    err?: Error;
    output?: string;
    sdatas?: any[];
    cdatas?: any[];
}