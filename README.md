# chenru-react-native-test

# 1.安装 React Native 模块

## 1.1 npm 安装 chenru-react-native-test 模块

```sh
npm install chenru-react-native-test
```

## 1.2 `link` chenru-react-native-test 模块


```sh
react-native link chenru-react-native-test
```
# 2.开启 React Native 全埋点

## 2.1 开启全埋点
首先在 package.json 中增加如下配置：
```sh
"sensorsdata":{
    "click":"enable",
    "pageview":"enable"
 }
```
<span style="color:red">注意：关闭全埋点后需要调用</span>
```sh
node node_modules/chenru-react-native-test/SensorsdataRNHook.js -reset
```

## 2.2 执行 SensorsdataRNHook.js
```sh
node node_modules/sensorsdata-analytics-react-native/SensorsdataRNHook.js -run
```
<span style="color:red">注意：每次 npm install 后都需要重新调用，可在 package.json 中配置，保存后调用 npm install</span>
```sh
"scripts": {
	  "postinstall": "node node_modules/chenru-react-native-test/SensorsdataRNHook.js -run"
}
```



### 详细文档请参考：[Android & iOS SDK 在 React Native 中使用说明](https://www.sensorsdata.cn/manual/sdk_reactnative.html)