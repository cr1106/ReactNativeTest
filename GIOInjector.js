var fs = require("fs");
var common = require("./GIOCommon");

/*
 * filePath: ReactNative的文件夹地址
 */
function injectReactNative(dirPath, reset = false) {
  if (!dirPath.endsWith("/")) {
    dirPath += "/";
  }
  var touchableJsFilePath = `${dirPath}Libraries/Components/Touchable/Touchable.js`;

  if (reset) {
    console.log(`reset render.js: ${touchableJsFilePath}`);
    common.resetFile(touchableJsFilePath);
  } else {
    console.log(`found and modify Touchable.js: ${touchableJsFilePath}`);

    injectOnPressScript(touchableJsFilePath);
  }
}

function injectOnPressScript(filePath) {
  common.modifyFile(filePath, onPressTransformer);
}

function onPressTransformer(content) {
  var index = content.indexOf("this.touchableHandlePress(");
  if (index == -1) throw "Can't not hook onPress function";
  var injectScript =
    "var ReactNative = require('react-native');\n" +
    "this.props.onPress&&ReactNative.NativeModules.SensorsDataModule.trackViewClick(ReactNative.findNodeHandle(this));";
  injectScript = common.anonymousJsFunctionCall(injectScript);
  var result = `${content.substring(
    0,
    index
  )}\n${injectScript}\n${content.substring(index)}`;
  return result;
}

module.exports = {
  injectOnPressScript: injectOnPressScript,
  injectReactNative: injectReactNative
};
