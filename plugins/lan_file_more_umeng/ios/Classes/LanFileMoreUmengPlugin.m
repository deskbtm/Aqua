#import "LanFileMoreUmengPlugin.h"
#if __has_include(<lan_file_more_umeng/lan_file_more_umeng-Swift.h>)
#import <lan_file_more_umeng/lan_file_more_umeng-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "lan_file_more_umeng-Swift.h"
#endif

@implementation LanFileMoreUmengPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLanFileMoreUmengPlugin registerWithRegistrar:registrar];
}
@end
