#import "WifiPlugin.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <NetworkExtension/NEHotspotConfigurationManager.h>

@implementation WifiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.ly.com/wifi"
                                     binaryMessenger:[registrar messenger]];
    WifiPlugin* instance = [[WifiPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"ssid" isEqualToString:call.method]) {
        NSString *wifiName = [self getSSID];
        if ([wifiName isEqualToString: @"Not Found"]) {
            result([FlutterError errorWithCode:@"UNAVAILABLE"
                                       message:@"wifi name unavailable"
                                       details:nil]);
        } else {
            result(wifiName);
        }
    } else if ([@"level" isEqualToString:call.method]) {
        NSNumber *level = @([self getSignalStrength]);
        result(level);
    } else if ([@"ip" isEqualToString:call.method]) {
        NSString *ip = [self getIPAddress];
        if ([ip isEqualToString: @"error"]) {
            result([FlutterError errorWithCode:@"UNAVAILABLE"
                                       message:@"wifi name unavailable"
                                       details:nil]);
        } else {
            result(ip);
        }
    } else if ([@"connection" isEqualToString:call.method]) {
        if (@available(iOS 11.0, *)) {
            NSDictionary* argsMap = call.arguments;
            NSString *ssid = argsMap[@"ssid"];
            NSString *password = argsMap[@"password"];
            NEHotspotConfiguration * hotspotConfig = [[NEHotspotConfiguration alloc] initWithSSID:ssid passphrase:password isWEP:NO];
            [[NEHotspotConfigurationManager sharedManager] applyConfiguration:hotspotConfig completionHandler:^(NSError * _Nullable error) {
                if(error == nil){
                    result(@1);
                }else{
                    if(error.code == 13){
                        result(@2);
                    } else {
                        result(@0);
                    }
                }
            }];
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSString *) getSSID {
    NSString *ssid = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
        }
    }
    return ssid;
}

- (int)getSignalStrength{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    UIView *dataNetworkItemView = nil;
    
    for (UIView * subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    NSLog(@"signal %d", signalStrength);
    return signalStrength;
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]){
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}
@end
