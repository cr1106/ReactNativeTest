//
//  SensorsDataModule.m
//  RNSensorsAnalyticsModule
//
//  Created by 彭远洋 on 2020/4/3.
//  Copyright © 2020 ziven.mac. All rights reserved.
//

#import "SensorsDataModule.h"
#import <React/RCTBridge.h>

@implementation SensorsDataModule

RCT_EXPORT_MODULE(SensorsDataModule)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

RCT_EXPORT_METHOD(trackViewClick:(NSInteger)reactTag) {
    @try {
        Class sa = NSClassFromString(@"SensorsAnalyticsSDK");
        SEL shared = NSSelectorFromString(@"sharedInstance");
        if (![sa respondsToSelector:shared]) {
            return;
        }
        id sdk = [sa performSelector:shared];
        SEL click = NSSelectorFromString(@"trackViewClick:");
        if (![sdk respondsToSelector:click]) {
            return;
        }
        NSNumber *tag = [NSNumber numberWithInteger:reactTag];
        [sdk performSelector:click withObject:tag];
    } @catch (NSException *exception) {
        NSLog(@"[RNSensorsAnalytics] error:%@",exception);
    }
}

RCT_EXPORT_METHOD(prepareView:(NSInteger)reactTag enableClick:(BOOL)enableClick properties:(NSDictionary *)properties) {
  @try {
      Class sa = NSClassFromString(@"SensorsAnalyticsSDK");
      SEL shared = NSSelectorFromString(@"sharedInstance");
      if (![sa respondsToSelector:shared]) {
          return;
      }
      id sdk = [sa performSelector:shared];
      SEL prepareView = NSSelectorFromString(@"prepareView:properties:");
      if (![sdk respondsToSelector:prepareView]) {
          return;
      }
      NSDictionary *object = @{@"reactTag":@(reactTag), @"enableClick":@(enableClick)};
      [sdk performSelector:prepareView withObject:object withObject:properties];
  } @catch (NSException *exception) {
      NSLog(@"[RNSensorsAnalytics] error:%@",exception);
  }
}

#pragma clang diagnostic pop

@end
