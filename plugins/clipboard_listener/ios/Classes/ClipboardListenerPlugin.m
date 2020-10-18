#import "ClipboardListenerPlugin.h"
#if __has_include(<clipboard_listener/clipboard_listener-Swift.h>)
#import <clipboard_listener/clipboard_listener-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "clipboard_listener-Swift.h"
#endif

@implementation ClipboardListenerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftClipboardListenerPlugin registerWithRegistrar:registrar];
}
@end
