import 'dart:typed_data';

import 'package:flutter/services.dart';

class MixPackageManager {
  MethodChannel _channel;

  MixPackageManager(MethodChannel mc) {
    _channel = mc;
  }

  Future<Map> getApkInfo(String path) async {
    final Map info = await _channel.invokeMethod('getApkInfo', {'path': path});
    return info;
  }

  Future<Map> getPackageInfoByName(String packageName) async {
    final Map info = await _channel.invokeMethod('getPackageInfoByName', {'packageName': packageName});
    return info;
  }

  Future<Uint8List> getPackageIconByName(String packageName) async {
    return await _channel.invokeMethod('getPackageIconByName', {'packageName': packageName});
  }
}
