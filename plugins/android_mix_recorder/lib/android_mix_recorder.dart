import 'dart:async';

import 'package:flutter/services.dart';

class AndroidMixRecorder {
  static const MethodChannel _channel =
      const MethodChannel('android_mix_recorder');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
