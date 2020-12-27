
import 'dart:async';

import 'package:flutter/services.dart';

class AndroidArchiver {
  static const MethodChannel _channel =
      const MethodChannel('android_archiver');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
