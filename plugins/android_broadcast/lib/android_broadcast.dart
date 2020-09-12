import 'dart:async';

import 'package:flutter/services.dart';

class AndroidBroadcast {
  static const MethodChannel _channel =
      const MethodChannel('android_broadcast');

  static Future<Map> onReceive() async {
    return _channel.invokeMethod('onReceive');
  }
}
