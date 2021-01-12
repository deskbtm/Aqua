#import "FlutterGlidePlugin.h"
#if __has_include(<flutter_glide/flutter_glide-Swift.h>)
#import <flutter_glide/flutter_glide-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_glide-Swift.h"
#endif

@implementation FlutterGlidePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterGlidePlugin registerWithRegistrar:registrar];
}
@end
