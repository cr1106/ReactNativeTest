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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface SAReactNativeManager ()

@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *referrer;

@end

@implementation SAReactNativeManager

#pragma mark - public
+ (void)trackViewClick:(NSNumber *)reactTag {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[SAReactNativeManager sharedInstance] viewForTag:reactTag];
        NSDictionary *properties = [[SAReactNativeManager sharedInstance] viewClickPorperties];
        [SAReactNativeManager trackViewAppClick:view properties:properties];
    });
}

+ (void)trackPageView:(nullable NSString *)pageName properties:(nullable NSDictionary *)properties {
    BOOL isIgnore = [properties[@"sensorsdataignore"] boolValue];
    if (isIgnore) {
        return;
    }
    pageName = pageName ?: properties[@"sensorsdataurl"];

    if (!pageName) {
        NSLog(@"page view did not empty！！！");
        return;
    }

    NSMutableDictionary *customProps = [properties[@"sensorsdataparams"] mutableCopy];
    NSString *title = customProps[@"title"];
    [customProps removeObjectForKey:@"title"];

    NSDictionary *pageProps = [[SAReactNativeManager sharedInstance] pageViewProperties:pageName title:title];
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props addEntriesFromDictionary:customProps];
    [props addEntriesFromDictionary:pageProps];
    [SAReactNativeManager track:@"$AppViewScreen" properties:props];
}

#pragma mark - hook SensorsAnalytics SDK method
+ (void)trackViewAppClick:(UIView *)view properties:(NSDictionary *)properties {
    Class sa = NSClassFromString(@"SensorsAnalyticsSDK");
    SEL sharedSEL = NSSelectorFromString(@"sharedInstance");
    if (![sa respondsToSelector:sharedSEL]) {
        return;
    }
    id sdk = [sa performSelector:sharedSEL];
    SEL trackSEL = NSSelectorFromString(@"trackViewAppClick:withProperties:");
    if (![sdk respondsToSelector:trackSEL]) {
        return;
    }
    [sdk performSelector:trackSEL withObject:view withObject:properties];
}

+ (void)track:(NSString *)event properties:(NSDictionary *)properties {
    Class sa = NSClassFromString(@"SensorsAnalyticsSDK");
    SEL sharedSEL = NSSelectorFromString(@"sharedInstance");
    if (![sa respondsToSelector:sharedSEL]) {
        return;
    }
    id sdk = [sa performSelector:sharedSEL];
    SEL trackSEL = NSSelectorFromString(@"track:withProperties:");
    if (![sdk respondsToSelector:trackSEL]) {
        return;
    }
    [sdk performSelector:trackSEL withObject:event withObject:properties];
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
    UIView *rootView = [root view];

    SEL bridgeSEL = NSSelectorFromString(@"bridge");
    if (![NSStringFromClass(rootView.class) isEqualToString:@"RCTRootView"] || ![rootView respondsToSelector:bridgeSEL]) {
        return nil;
    }
    id bridge = [rootView performSelector:bridgeSEL];
    SEL uiManagerSEL = NSSelectorFromString(@"uiManager");
    if (![bridge respondsToSelector:uiManagerSEL]) {
        return nil;
    }
    id uiManager = [bridge performSelector:uiManagerSEL];
    SEL tagSEL = NSSelectorFromString(@"viewForReactTag:");
    if (![uiManager respondsToSelector:tagSEL]) {
        return nil;
    }
    UIView *view = [uiManager performSelector:tagSEL withObject:reactTag];
    if (!view) {
        return nil;
    }
    return view;
}

- (NSDictionary *)pageViewProperties:(NSString *)pageName title:(NSString *)title {
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

#pragma clang diagnostic pop
