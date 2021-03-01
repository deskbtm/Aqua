import 'package:flutter/services.dart';

class Activity {
  MethodChannel _channel;

  Activity(MethodChannel mc) {
    _channel = mc;
  }

  Future<void> moveTaskToBack({bool nonRoot = true}) async {
    await _channel.invokeMethod('moveTaskToBack', {'nonRoot': nonRoot});
  }
}
