
import 'dart:async';

import 'package:flutter/services.dart';

class ScreenCapturer {
  static const MethodChannel _channel =
      const MethodChannel('screen_capturer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
