/*
 * Created by chenru on 2019/08/27.
 * Copyright 2015－2020 Sensors Data Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.sensorsdata.analytics;


import android.text.TextUtils;
import android.util.Log;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableNativeMap;
import com.sensorsdata.analytics.android.sdk.SensorsDataAPI;
import com.sensorsdata.analytics.android.sdk.SALog;
import com.sensorsdata.analytics.RNAgent;
import com.sensorsdata.analytics.utils.RNUtils;
import com.sensorsdata.analytics.utils.RNViewUtils;

import org.json.JSONObject;

import java.util.HashSet;


/**
 * Created by yang on 2017/4/5
 * <p>
 * 参数类型在@ReactMethod注明的方法中，会被直接映射到它们对应的JavaScript类型
 * String -> String
 * ReadableMap -> Object
 * Boolean -> Bool
 * Integer -> Number
 * Double -> Number
 * Float -> Number
 * Callback -> function
 * ReadableArray -> Array
 */

public class RNSensorsDataModule extends ReactContextBaseJavaModule {

    public RNSensorsDataModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    private static final String MODULE_NAME = "RNSensorsDataModule";
    private static final String TAG = "SA.RNSensorsDataModule";

    /**
     * 返回一个字符串名字，这个名字在 JavaScript (RN)端标记这个模块。
     */
    @Override
    public String getName() {
        return MODULE_NAME;
    }

    @ReactMethod
    public void trackViewClick(int viewId) {
        RNAgent.trackViewClick(viewId);
    }

    @ReactMethod
    public void trackPageView(ReadableMap params) {
        try{
            if (params != null) {
                JSONObject jsonParams = RNUtils.convertToJSONObject(params);
                if(jsonParams.optBoolean("sensorsDataIgnore",false)){
                    return;
                }
                JSONObject properties = null;
                if(jsonParams.has("SAProperties")){
                    properties = jsonParams.optJSONObject("SAProperties");
                }
                if(properties == null){
                    properties = new JSONObject();
                }
                String url = null;
                if(jsonParams.has("sensorsDataUrl")){
                    url = jsonParams.getString("sensorsDataUrl");
                }
                if(url == null){
                    return;
                }
                String title = null;
                if(properties.has("title")){
                    title = properties.getString("title");
                    properties.put("$title",title);
                    properties.remove("title");
                }else{
                    properties.put("$title",url);
                }
                properties.put("$screen_name",url);
                RNViewUtils.saveUrlAndTitle(url,title);
                RNAgent.trackPageView(url, properties);
            }   
        }catch(Exception e){
            SALog.printStackTrace(e);
        }
}

    // @ReactMethod
    // public void trackPageView(String title) {
    //      SALog.i("SA.RN----------title->",title);
    //     if (title != null) {
    //         RNAgent.trackPageView(title, null,null);
    //     }
    // }
}
