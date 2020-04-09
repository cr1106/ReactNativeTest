#! node option
// 系统变量
var path = require("path"),
    fs = require("fs"),
    dir = path.resolve(__dirname, '..');

// 自定义变量
// RN 控制点击事件 Touchable.js 源码文件
var RNClickFilePath = dir + '/react-native/Libraries/Components/Touchable/Touchable.js';
// 需 hook 的自执行代码
var sensorsdataHookCode = "(function(thatThis){ try {var ReactNative = require('react-native');thatThis.props.onPress && ReactNative.NativeModules.RNSensorsDataModule.trackViewClick(ReactNative.findNodeHandle(thatThis))} catch (error) { throw new Error('SensorsData RN Hook Code 调用异常: ' + error);}})(this); /* SENSORSDATA HOOK */ ";
// hook 代码实现点击事件采集
sensorsdataHookRN = function () {
    // 读取文件内容
    var fileContent = fs.readFileSync(RNClickFilePath, 'utf8');
    // 已经 hook 过了，不需要再次 hook
    if (fileContent.indexOf('SENSORSDATA HOOK') > -1) { 
        return;
    }
    // 获取 hook 的代码插入的位置
    var hookIndex = fileContent.indexOf("this.touchableHandlePress(");
    // 判断文件是否异常，不存在 touchableHandlePress 方法，导致无法 hook 点击事件
    if (hookIndex == -1) {
        throw "Can't not find touchableHandlePress function";
    };
    // 插入 hook 代码
    var hookedContent = `${fileContent.substring(0, hookIndex)}\n${sensorsdataHookCode}\n${fileContent.substring(hookIndex)}`;
    // 备份 Touchable.js 源文件
    fs.renameSync(RNClickFilePath, `${RNClickFilePath}_sensorsdata_backup`);
    // 重写 Touchable.js 文件
    fs.writeFileSync(RNClickFilePath, hookedContent, 'utf8');
};
// 恢复被 hook 过的代码
sensorsdataResetRN = function () {
    // 读取文件内容
    var fileContent = fs.readFileSync(RNClickFilePath, "utf8");
    // 未被 hook 过代码，不需要处理
    if (fileContent.indexOf('SENSORSDATA HOOK') == -1) { 
        return;
    }
    // 检查备份文件是否存在
    var backFilePath = `${RNClickFilePath}_sensorsdata_backup`;
    if (!fs.existsSync(backFilePath)) {
        throw `File: ${backFilePath} not found, Please rm -rf node_modules and npm install again`;
    }
    // 将备份文件重命名恢复 + 自动覆盖被 hook 过的同名 Touchable.js 文件
    fs.renameSync(backFilePath, RNClickFilePath);
};


// 命令行
switch (process.argv[2]) {
    case '-run':
        sensorsdataHookRN();
        break;
    case '-reset':
        sensorsdataResetRN();
        break;
    default:
        console.log('can not find this options: ' + process.argv[2]);
}

