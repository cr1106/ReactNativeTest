# 1.使用 npm 方式 install  SDK 模块

对于 React Native 开发的应用，可以使用 npm 方式集成 SDK RN 模块。

## 1.1 npm 安装 chenru-react-native-test 模块

```sh
npm install chenru-react-native-test
```

## 1.2 `link` chenru-react-native-test 模块

<span style="color:red">注意：React Native 0.60 及以上版本会 autolinking，不需要执行下边的 react-native link 命令</span>
```sh
react-native link chenru-react-native-test
```

# 2.执行 hook.js
```sh
node node_modules/chenru-react-native-test/hook.js -run
```
<span style="color:red">注意：每次 npm install 后都需要重新调用，可在 package.json 中配置，保存后调用 npm install</span>
```sh
"scripts": {
	  "postinstall": "node node_modules/chenru-react-native-test/hook.js -run"
}
```