//
// SAReactNativeManager.m
// SensorsAnalyticsSDK
//
// Created by 彭远洋 on 2020/3/16.
// Copyright © 2020 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SAReactNativeManager.h"
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import <React/RCTUIManager.h>

#if __has_include("SensorsAnalyticsSDK.h")
#import "SensorsAnalyticsSDK.h"
#else
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#endif

@interface SAReactNativeManager ()

@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *referrer;

@end

@implementation SAReactNativeManager

#pragma mark - public
+ (void)trackViewClick:(NSNumber *)reactTag {
    if (![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
        return;
    }
    // 忽略 $AppClick 事件
    if ([[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppClick]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[SAReactNativeManager sharedInstance] viewForTag:reactTag];
        NSDictionary *properties = [[SAReactNativeManager sharedInstance] viewClickPorperties];
        [[SensorsAnalyticsSDK sharedInstance] trackViewAppClick:view withProperties:properties];
    });
}

+ (void)trackViewScreen:(NSString *)pageName properties:(nullable NSDictionary *)properties {
    if (![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
        return;
    }
    // 忽略 $AppViewScreen 事件
    if ([[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppViewScreen]) {
        return;
    }
    if (!pageName.length) {
        pageName = properties[@"sensorsdataurl"];
    }
    if (!pageName || ![pageName isKindOfClass:NSString.class]) {
        NSLog(@"[RNSensorsAnalytics] error: page name is not valid！！！");
        return;
    }
    NSMutableDictionary *customProps = [properties[@"sensorsdataparams"] mutableCopy];
    NSString *title = [customProps[@"title"] copy];
    // 移除字典中 title 字段，使用 $title 字段代替
    [customProps removeObjectForKey:@"title"];

    NSDictionary *pageProps = [[SAReactNativeManager sharedInstance] viewScreenProperties:pageName title:title];
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props addEntriesFromDictionary:pageProps];
    [props addEntriesFromDictionary:customProps];

    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *tempCaller = [UIViewController new];
        [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:tempCaller properties:props];
    });
}

#pragma mark - private
+ (instancetype)sharedInstance {
    static SAReactNativeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SAReactNativeManager alloc] init];
    });
    return manager;
}

- (UIView *)viewForTag:(NSNumber *)reactTag {
    UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *view = [root view];
    if (![view isKindOfClass:NSClassFromString(@"RCTRootView")]) {
        return nil;;
    }
    RCTRootView *rootView = (RCTRootView *)view;
    RCTUIManager *manager = rootView.bridge.uiManager;
    return [manager viewForReactTag:reactTag];
}

- (NSDictionary *)viewScreenProperties:(NSString *)pageName title:(NSString *)title {
    _referrer = _pageName;
    _pageName = pageName;
    _title = title ?: pageName;
    return [self viewClickPorperties];
}

- (NSDictionary *)viewClickPorperties {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[@"$screen_name"] = _pageName;
    properties[@"$url"] = _pageName;
    properties[@"$title"] = _title;
    properties[@"$referrer"] = _referrer;
    return [properties copy];
}

@end
