# clipboard_listener
[![pub package](https://img.shields.io/pub/v/clipboard_listener.svg)](https://pub.dartlang.org/packages/clipboard_listener)  
Flutter 粘贴板监听器，在粘贴板内容改变时通知您  
**注意：由于Android10改变了监听器策略，因此，当您的APP在后台运行时，将不会通知您**  
**注意：由于IOS系统监听器策略，因此，当您的APP在后台运行时，将不会通知您**  
````
如果您有能够解决后台无法监听的办法，请联系我，我将集成在该插件内.
````

## Getting Started
Android 基于： `ClipboardManager.OnPrimaryClipChangedListener`  
IOS 基于：`UIPasteboardChangedNotification`

### 集成
```
clipboard_listener: ^[最新版本号]
```

### 使用方法
通过 `ClipboardListener.addListener` 和 `ClipboardListener.removeListener` 可进行事件监听  
````dart
@override
vodi initState(){
  super.initState();
  ClipboardListener.addListener(_messageListener);
}
@override
void dispose() {
  super.dispose();
  ClipboardListener.removeListener(_messageListener);
}

 _messageListener() {
  // you code
};
````
注意：addListener 后，请注意在必要时进行 removeListener

## 其它插件
````
我同时维护的还有以下插件，如果您感兴趣与我一起进行维护，请通过Github联系我，欢迎 issues 和 PR。
````
| 平台 | 插件  |  描述  |  版本  |
| ---- | ----  | ---- |  ---- | 
| Flutter | [FlutterTencentImPlugin](https://github.com/JiangJuHong/FlutterTencentImPlugin)  | 腾讯云IM插件 | [![pub package](https://img.shields.io/pub/v/tencent_im_plugin.svg)](https://pub.dartlang.org/packages/tencent_im_plugin) | 
| Flutter | [FlutterTencentRtcPlugin](https://github.com/JiangJuHong/FlutterTencentRtcPlugin)  | 腾讯云Rtc插件 | [![pub package](https://img.shields.io/pub/v/tencent_rtc_plugin.svg)](https://pub.dartlang.org/packages/tencent_rtc_plugin) | 
| Flutter | [FlutterXiaoMiPushPlugin](https://github.com/JiangJuHong/FlutterXiaoMiPushPlugin)  | 小米推送SDK插件 | [![pub package](https://img.shields.io/pub/v/xiao_mi_push_plugin.svg)](https://pub.dartlang.org/packages/xiao_mi_push_plugin) | 
| Flutter | [FlutterHuaWeiPushPlugin](https://github.com/JiangJuHong/FlutterHuaWeiPushPlugin)  | 华为推送(HMS Push)插件 | [![pub package](https://img.shields.io/pub/v/hua_wei_push_plugin.svg)](https://pub.dartlang.org/packages/hua_wei_push_plugin) | 
| Flutter | [FlutterTextSpanField](https://github.com/JiangJuHong/FlutterTextSpanField)  | 自定义文本样式输入框 | [![pub package](https://img.shields.io/pub/v/text_span_field.svg)](https://pub.dartlang.org/packages/text_span_field) | 
| Flutter | [FlutterClipboardListener](https://github.com/JiangJuHong/FlutterClipboardListener)  | 粘贴板监听器 | [![pub package](https://img.shields.io/pub/v/clipboard_listener.svg)](https://pub.dartlang.org/packages/clipboard_listener) | 
| Flutter | [FlutterQiniucloudLivePlugin](https://github.com/JiangJuHong/FlutterQiniucloudLivePlugin)  | Flutter 七牛云直播云插件 | 暂未发布，通过 git 集成 | 
