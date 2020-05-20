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

#import "SAReactNativeswizzler.h"

static NSString *CLICKABLE_VIEWS_KEY = @"com.sensorsdata.reactnative.clickableviews";

@interface SAReactNativeManager ()

@property (nonatomic, copy) NSString *currentScreenName;
@property (nonatomic, copy) NSString *currentTitle;
@property (nonatomic, strong) NSSet *ignoreClasses;
@property (nonatomic, assign) BOOL isRootViewVisible;

@end

@implementation UIViewController (SAReactNative)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController sarn_swizzleMethod:@selector(viewDidAppear:)
                                         withMethod:@selector(sa_reactnative_viewDidAppear:)
                                              error:NULL];

        [UIViewController sarn_swizzleMethod:@selector(viewDidDisappear:)
                                         withMethod:@selector(sa_reactnative_viewDidDisappear:)
                                              error:NULL];
    });
}

- (void)sa_reactnative_viewDidAppear:(BOOL)animated {
    [self sa_reactnative_viewDidAppear:animated];

    // 此处有一个已知问题，当从一个模态原生页面返回时，不会触发此方法。
    // 为了暂时解决这个问题，在触发 RN 页面浏览或 RN 点击时，会重置 isRootViewVisible 状态
    // 此问题只会影响可视化全埋点功能
    if (![self.view isReactRootView]) {
        return;
    }
    if ([self isIgnoreAppViewScreen]) {
        return;
    }
    [[SAReactNativeManager sharedInstance] setIsRootViewVisible:YES];
}

- (void)sa_reactnative_viewDidDisappear:(BOOL)animated {
    [self sa_reactnative_viewDidDisappear:animated];
    if (![self.view isReactRootView]) {
        return;
    }
    if ([self isIgnoreAppViewScreen]) {
        return;
    }
    [[SAReactNativeManager sharedInstance] setIsRootViewVisible:NO];
}

- (BOOL)isIgnoreAppViewScreen {
    if (![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
        return YES;
    }
    // 忽略 $AppClick 事件
    if ([[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppViewScreen]) {
        return YES;
    }
    return NO;
}

@end

@implementation SAReactNativeManager

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static SAReactNativeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SAReactNativeManager alloc] init];

    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSSet *ignoreClasses = [NSSet setWithObjects:@"RCTSwitch", @"RCTSlider", @"RCTSegmentedControl", @"RNGestureHandlerButton", nil];
        for (NSString *className in ignoreClasses) {
            [[SensorsAnalyticsSDK sharedInstance] ignoreViewType:NSClassFromString(className)];
        }
        _ignoreClasses = [NSSet setWithObjects:@"RCTScrollView", nil];
        _isRootViewVisible = NO;

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:CLICKABLE_VIEWS_KEY];
    }
    return self;
}

#pragma mark - visualize
- (NSDictionary *)visualizeProperties {
    return _isRootViewVisible ? [self screenProperties] : nil;
}

- (BOOL)clickableForView:(UIView *)view {
    if ([_ignoreClasses containsObject:NSStringFromClass(view.class)]) {
        return NO;
    }
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:CLICKABLE_VIEWS_KEY];
    if (!array) {
        return NO;
    }
    return [array containsObject:view.reactTag];
}

- (BOOL)prepareView:(NSNumber *)reactTag clickable:(BOOL)clickable paramters:(NSDictionary *)paramters {
    if (!clickable) {
        return NO;
    }
    [self addClickableViewReactTag:reactTag];
    return YES;
}

- (void)addClickableViewReactTag:(NSNumber *)reactTag {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:CLICKABLE_VIEWS_KEY];
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
    [mArray addObject:reactTag];
    [defaults setObject:[mArray copy] forKey:CLICKABLE_VIEWS_KEY];
    [defaults synchronize];
}

#pragma mark - AppClick
- (void)trackViewClick:(NSNumber *)reactTag {
    if (![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
        return;
    }
    // 忽略 $AppClick 事件
    if ([[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppClick]) {
        return;
    }

    // 暂时解决原生页面返回 RN 页面没有重置状态的问题
    // 从原生页面返回 RN 页面只有触发页面浏览事件后，才能正确返回页面信息
    // 此问题只会出现在可视化全埋点功能中
    _isRootViewVisible = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[SAReactNativeManager sharedInstance] viewForTag:reactTag];
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSDictionary *clickProperties = [self screenProperties];
        [properties addEntriesFromDictionary:clickProperties];
        properties[@"$element_content"] = [view accessibilityLabel];

        [[SensorsAnalyticsSDK sharedInstance] trackViewAppClick:view withProperties:[properties copy]];
    });
}

#pragma mark - AppViewScreen
- (void)trackViewScreen:(nullable NSString *)url properties:(nullable NSDictionary *)properties autoTrack:(BOOL)autoTrack {
    if (url && ![url isKindOfClass:NSString.class]) {
        NSLog(@"[RNSensorsAnalytics] error: url {%@} is not String Class ！！！", url);
        return;
    }
    NSString *screenName = properties[@"$screen_name"] ?: url;
    NSString *title = properties[@"$title"];
    NSDictionary *pageProps = [self viewScreenProperties:screenName title:title];

    if (autoTrack && ![[SensorsAnalyticsSDK sharedInstance] isAutoTrackEnabled]) {
        return;
    }
    // 忽略 $AppViewScreen 事件
    if (autoTrack && [[SensorsAnalyticsSDK sharedInstance] isAutoTrackEventTypeIgnored:SensorsAnalyticsEventTypeAppViewScreen]) {
        return;
    }

    // 暂时解决原生页面返回 RN 页面没有重置状态的问题
    // 从原生页面返回 RN 页面只有触发页面浏览事件后，才能正确返回页面信息
    // 此问题只会出现在可视化全埋点功能中
    _isRootViewVisible = YES;

    NSMutableDictionary *eventProps = [NSMutableDictionary dictionary];
    [eventProps addEntriesFromDictionary:pageProps];
    [eventProps addEntriesFromDictionary:properties];

    [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:url withProperties:[eventProps copy]];
}

#pragma mark - SDK Method
+ (RCTRootView *)rootView {
    // RCTRootView 只能是 UIViewController 的 view，不能作为其他 View 的 SubView 使用
    UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *view = [root view];
    // 不是混编 React Native 项目时直接获取 RootViewController 的 view
    if ([view isKindOfClass:RCTRootView.class]) {
        return (RCTRootView *)view;
    }
    Class utils = NSClassFromString(@"SAAutoTrackUtils");
    if (!utils) {
        return nil;
    }
    SEL currentCallerSEL = NSSelectorFromString(@"currentViewController");
    if (![utils respondsToSelector:currentCallerSEL]) {
        return nil;
    }

    // 混编 React Native 项目时获取当前显示的 UIViewController 的 view
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    UIViewController *caller = [utils performSelector:currentCallerSEL];
#pragma clang diagnostic pop

    if (![caller.view isKindOfClass:RCTRootView.class]) {
        return nil;
    }
    return (RCTRootView *)caller.view;
}

#pragma mark - private
- (UIView *)viewForTag:(NSNumber *)reactTag {
    RCTRootView *rootView = [SAReactNativeManager rootView];
    RCTUIManager *manager = rootView.bridge.uiManager;
    return [manager viewForReactTag:reactTag];
}

- (NSDictionary *)viewScreenProperties:(NSString *)screenName title:(NSString *)title {
    _currentScreenName = screenName;
    _currentTitle = title ?: screenName;
    return [self screenProperties];
}

- (NSDictionary *)screenProperties {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[@"$screen_name"] = _currentScreenName;
    properties[@"$title"] = _currentTitle;
    return [properties copy];
}

@end
