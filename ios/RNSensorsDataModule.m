//
//  RNSensorsDataModule.m
//  RNSensorsAnalyticsModule
//
//  Created by 彭远洋 on 2020/4/3.
//  Copyright © 2020 ziven.mac. All rights reserved.
//

#import "RNSensorsDataModule.h"
#import <React/RCTBridge.h>
#import "SAReactNativeManager.h"

@implementation RNSensorsDataModule

RCT_EXPORT_MODULE(RNSensorsDataModule)

RCT_EXPORT_METHOD(trackViewClick:(NSInteger)reactTag) {
    [SAReactNativeManager trackViewClick:@(reactTag)];
}

RCT_EXPORT_METHOD(trackPageView:(NSDictionary *)properties) {
    [SAReactNativeManager trackPageView:nil properties:properties];
}

@end
