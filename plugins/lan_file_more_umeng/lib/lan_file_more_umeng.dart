import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class LanFileMoreUmeng {
  static const MethodChannel _channel =
      const MethodChannel('lan_file_more_umeng');

  static Future<bool> init({
    String iOSAppKey,
    String androidAppKey,
    //渠道标识
    String channel,
    //设置是否在console输出sdk的log信息.
    bool enableLog = false,
    //设置是否对日志信息进行加密, 默认NO(不加密).设置为YES, umeng SDK 会将日志信息做加密处理
    bool encrypt = false,
    bool enableReportError = false,
  }) async {
    assert((Platform.isAndroid && androidAppKey != null) ||
        (Platform.isIOS && iOSAppKey != null));

    await _channel.invokeMethod("init", {
      "appKey": Platform.isAndroid ? androidAppKey : iOSAppKey,
      "channel": channel,
      "encrypt": encrypt,
      "enableLog": enableLog,
      "enableReportError": enableReportError,
    });
    return true;
  }

  ///事件埋点
  static Future<Null> event(String eventId, {String label}) async {
    Map<String, dynamic> args = {"eventId": eventId};
    if (label != null) args["label"] = label;

    await _channel.invokeMethod("event", args);
  }

  ///统计页面时间-开始
  static Future<Null> beginLogPageView(String pageName) async {
    await _channel.invokeMethod("beginLogPageView", {"pageName": pageName});
  }

  ///统计页面时间-结束
  static Future<Null> endLogPageView(String pageName) async {
    await _channel.invokeMethod("endLogPageView", {"pageName": pageName});
  }

  ///统计时长
  static Future<Null> onResume() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("onResume");
    }
  }

  ///统计时长
  static Future<Null> onPause() async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("onPause");
    }
  }

  static Future<Null> reportError(String error) async {
    await _channel.invokeMethod("reportError", {
      "error": error,
    });
  }
}
