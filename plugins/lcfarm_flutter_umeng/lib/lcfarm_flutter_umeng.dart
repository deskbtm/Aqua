import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class LcfarmFlutterUmeng {
  static const MethodChannel _channel =
      const MethodChannel('lcfarm_flutter_umeng');

  ///初始化友盟所有组件产品
  static Future<bool> init({
    String iOSAppKey,
    String androidAppKey,
    String channel, //渠道标识

    bool logEnable, //设置是否在console输出sdk的log信息.

    bool encrypt, //设置是否对日志信息进行加密, 默认NO(不加密).设置为YES, umeng SDK 会将日志信息做加密处理
  }) async {
    assert((Platform.isAndroid && androidAppKey != null) ||
        (Platform.isIOS && iOSAppKey != null));
    Map<String, dynamic> args = {
      "appKey": Platform.isAndroid ? androidAppKey : iOSAppKey
    };

    if (channel != null) {
      args["channel"] = channel;
    }
    if (logEnable != null) args["logEnable"] = logEnable;
    if (encrypt != null) args["encrypt"] = encrypt;

    await _channel.invokeMethod("init", args);
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
}
