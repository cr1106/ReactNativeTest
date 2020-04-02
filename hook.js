#!/usr/bin/env node

var path = require("path");
var injector = require("./GIOInjector");

var OPT_RUN = 0;
var OPT_DISCARD = 0;
var OPT_VERSION = 0;
var OPT_HELP = 0;

var OPT_UNKNOWN = 0;

// react-native path
var reactNativePath;
// react-navigation path
var reactNavigationPath;
var reactNavigationPath3X;
// react-native-navigation path
var reactNativeNavigationPath;

switch(process.argv[2]) {
    case '-v':
    case '--version':
        OPT_VERSION = 1;
        break;
    case '-run':
        OPT_RUN = 1;
        break;
    case '-discard':
        OPT_DISCARD = 1;
        break;
    case '-h':
    case '--help':
        OPT_HELP = 1;
        break;
    default:
        OPT_UNKNOWN = 1;
}

if (OPT_UNKNOWN == 1) {
   console.log('');
   if (OPT_RUN == 1) {
       console.log('You need to see the details of the -run command');
   } else if (OPT_DISCARD == 1) {
       console.log('You need to see the details of the -discard command');
   } else {
       console.log('Unknown options: ' +  process.argv[2]);
   }
   console.log('');
   OPT_HELP = 1;
}

if (OPT_HELP == 1) {
   console.log('');
   console.log('usage: hook.js  [[-v | --version] hook.js version]');
   console.log('       hook.js  [[-run] hook react native js]');
   console.log('       hook.js  [[-discard] discard hook]');
   console.log('       hook.js  [-h, --help: this help]');
   return;
}

if (OPT_VERSION == 1) {
    console.log('');
    console.log('hook.js version ' + 1);
    console.log('');
    return;
}

var dir = path.resolve(__dirname,"node_modules");

console.log(dir);
reactNativePath = dir + '/react-native';
reactNavigationPath = dir + "/react-navigation";
reactNavigationPath3X = dir + "/@react-navigation/native";
// react-native-navigation path
reactNativeNavigationPath = dir + "/react-native-navigation";
/**
 * hook config
 */
if (OPT_RUN == 1) {
    injector.injectReactNative(reactNativePath);
    injector.injectReactNavigation(reactNavigationPath);
    injector.injectReactNavigation3(reactNavigationPath3X);
    injector.injectReactNativeNavigation(reactNativeNavigationPath);
    return;
}
if(OPT_DISCARD == 1){
     injector.injectReactNative(reactNativePath,true);
     injector.injectReactNavigation(reactNavigationPath, true);
     injector.injectReactNavigation3(reactNavigationPath3X, true);
     injector.injectReactNativeNavigation(reactNativeNavigationPath, true);
     return;
}