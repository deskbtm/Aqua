#import "PureVideoPlayerPlugin.h"
#if __has_include(<pure_video_player/pure_video_player-Swift.h>)
#import <pure_video_player/pure_video_player-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pure_video_player-Swift.h"
#endif

@implementation PureVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPureVideoPlayerPlugin registerWithRegistrar:registrar];
}
@end
