package com.sensorsdata.analytics.rnsdk;

import android.view.MotionEvent;
import android.view.MotionEvent.*;
import android.view.View;
import android.view.ViewGroup;
import com.facebook.react.bridge.ReadableMap;
import com.sensorsdata.analytics.rnsdk.RNSensorsAnalyticsModule;
import com.sensorsdata.analytics.rnsdk.utils.RNSensorsViewUtils;

import com.facebook.react.uimanager.JSTouchDispatcher;
import com.facebook.react.uimanager.events.EventDispatcher;
import com.sensorsdata.analytics.android.sdk.SALog;
import com.sensorsdata.analytics.android.sdk.SensorsDataAPI;
import com.sensorsdata.analytics.android.sdk.SensorsDataAutoTrackHelper;
import com.sensorsdata.analytics.rnsdk.utils.TouchTargetHelper;

import java.lang.reflect.Field;
import java.util.WeakHashMap;
import java.util.HashMap;
import org.json.JSONObject;

public class RNAgent {
    private static final WeakHashMap jsTouchDispatcherViewGroupWeakHashMap = new WeakHashMap();

    public static void handleTouchEvent(
            JSTouchDispatcher jsTouchDispatcher, MotionEvent event, EventDispatcher eventDispatcher) {

        if (event.getAction() == MotionEvent.ACTION_DOWN) { // ActionDown
            ViewGroup viewGroup = (ViewGroup)jsTouchDispatcherViewGroupWeakHashMap.get(jsTouchDispatcher);
            if (viewGroup == null) {
                try {
                    Field viewGroupField = jsTouchDispatcher.getClass().getDeclaredField("mRootViewGroup");
                    viewGroupField.setAccessible(true);
                    viewGroup = (ViewGroup) viewGroupField.get(jsTouchDispatcher);
                    jsTouchDispatcherViewGroupWeakHashMap.put(jsTouchDispatcher, viewGroup);
                } catch (Exception e) {
                    SALog.printStackTrace(e);
                }
            }
            if (viewGroup != null) {
                View nativeTargetView =
                        TouchTargetHelper.findTouchTargetView(
                                new float[] {event.getX(), event.getY()}, viewGroup);
                if (nativeTargetView != null) {
                    View reactTargetView = TouchTargetHelper.findClosestReactAncestor(nativeTargetView);
                    if (reactTargetView != null) {
                        nativeTargetView = reactTargetView;
                    }
                }
                if (nativeTargetView != null) {
                    RNSensorsViewUtils.setOnTouchView(nativeTargetView);
                }
            }
        }
    }

    public static void tarckViewScreen(String url){
        try{
            SensorsDataAPI.sharedInstance().trackViewScreen(url,null);
        }catch(Exception e){
            SALog.printStackTrace(e);
        }
    }

    public static void trackViewClick(int viewId){
        try {
            View clickView = RNSensorsViewUtils.getTouchViewByTag(viewId);
            if (clickView != null) {
                SensorsDataAutoTrackHelper.trackViewOnClick(clickView, true);
            }
        } catch (Exception e) {
            SALog.printStackTrace(e);
        }
    }
}
