import Flutter
import UIKit

public class SwiftClipboardListenerPlugin: NSObject, FlutterPlugin {

    /// 方法管道
    private static var channel: FlutterMethodChannel?;

    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftClipboardListenerPlugin.channel = FlutterMethodChannel(name: "clipboard_listener", binaryMessenger: registrar.messenger())
        let instance = SwiftClipboardListenerPlugin()
        registrar.addMethodCallDelegate(instance, channel: SwiftClipboardListenerPlugin.channel!)
        NotificationCenter.default.addObserver(instance, selector: #selector(clipboardChanged), name: UIPasteboard.changedNotification, object: nil);
    }

    /// 粘贴板改变事件
    @objc func clipboardChanged() {
        SwiftClipboardListenerPlugin.channel!.invokeMethod("onListener", arguments: nil);
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented);
    }
}
