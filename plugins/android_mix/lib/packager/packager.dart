import 'package:flutter/services.dart';

class Packager {
  MethodChannel _channel;

  Packager(MethodChannel mc) {
    _channel = mc;
  }

  Future<Map> getApkInfo(String path) async {
    final Map info = await _channel.invokeMethod('getApkInfo', {'path': path});
    return info;
  }
}
