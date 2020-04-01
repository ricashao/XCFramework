define(["require", "exports", "./PluginErrorType", "./asyncFileLoad"], function (require, exports, PluginErrorType_1, asyncFileLoad_1) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    class PluginLoader {
        constructor(pluginPath, m, callback) {
            this.callback = callback;
            var code = asyncFileLoad_1.default(pluginPath, (err, data) => {
                if (err) {
                    this.sendError(PluginErrorType_1.PluginErrorType.LoadFailed, err);
                    return;
                }
                var vm = nodeRequire("vm");
                let str = data.toString();
                let plugin = vm.createContext({ require: nodeRequire, console: console });
                try {
                    vm.runInContext(str, plugin);
                }
                catch (err) {
                    this.sendError(PluginErrorType_1.PluginErrorType.InitFailed, err);
                    return;
                }
                this.plugin = plugin;
                this.execute(m);
            });
        }
        sendError(code, err) {
            // 插件代码有误
            this.callback({ type: "error", error: code, err: err });
        }
        execute(m) {
            try {
                this.plugin.execute(m, (err, output, sdatas, cdatas) => {
                    if (err) {
                        this.sendError(PluginErrorType_1.PluginErrorType.ExecuteFailed, err);
                        return;
                    }
                    this.callback({ type: "success", output: output, sdatas: sdatas, cdatas: cdatas });
                });
            }
            catch (err) {
                this.sendError(PluginErrorType_1.PluginErrorType.ExecuteFailed, err);
                return;
            }
        }
    }
    exports.default = PluginLoader;
});
//# sourceMappingURL=PluginLoader.js.map