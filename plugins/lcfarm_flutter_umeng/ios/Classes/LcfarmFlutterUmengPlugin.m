#import "LcfarmFlutterUmengPlugin.h"
#import <UMCommon/MobClick.h>
#import <UMCommon/UMCommon.h>

@implementation LcfarmFlutterUmengPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"lcfarm_flutter_umeng"
                                     binaryMessenger:[registrar messenger]];
    LcfarmFlutterUmengPlugin* instance = [[LcfarmFlutterUmengPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    //初始化
    if ([@"init" isEqualToString:call.method]) {
        [self init:call result:result];
        result(nil);
    }
    //事件埋点
    else if ([@"event" isEqualToString:call.method]) {
        [self event:call result:result];
        result(nil);
    }
    //统计页面时间-开始
    else if ([@"beginLogPageView" isEqualToString:call.method]){
        [self beginLogPageView:call result:result];
        result(nil);
    }
    //统计页面时间-结束
    else if ([@"endLogPageView" isEqualToString:call.method]){
        [self endLogPageView:call result:result];
        result(nil);
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)init:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSNumber* logEnable = call.arguments[@"logEnable"];
    if (logEnable) {
        [UMConfigure setLogEnabled:[logEnable boolValue]];
    }
    NSNumber* encrypt = call.arguments[@"encrypt"];
    if (encrypt) {
        [UMConfigure setEncryptEnabled:[encrypt boolValue]];
    }
    
    NSString* channel = call.arguments[@"channel"] ?: @"App Store";
    
    NSString* appKey = call.arguments[@"appKey"] ?: @"";
    
    [UMConfigure initWithAppkey:appKey channel:channel];
    
}

- (void)event:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if (call.arguments[@"label"]){
        [MobClick event:call.arguments[@"eventId"] label:call.arguments[@"label"]];
    }else{
        [MobClick event:call.arguments[@"eventId"]];
    }
}

- (void)beginLogPageView:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    [MobClick beginLogPageView:call.arguments[@"pageName"] ?: @""];
}

- (void)endLogPageView:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    [MobClick endLogPageView:call.arguments[@"pageName"] ?: @""];
    
}

@end

