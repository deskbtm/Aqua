import 'dart:typed_data';

import 'package:flutter/services.dart';

class PackageMgmt {
  static const MethodChannel _channel = const MethodChannel('aqua_pkg_mgmt');

  static Future<Map> getApkInfo(String path) async {
    final Map info = await _channel.invokeMethod('getApkInfo', {'path': path});
    return info;
  }

  static Future<Map> getPackageInfoByName(String packageName) async {
    final Map info = await _channel
        .invokeMethod('getPackageInfoByName', {'packageName': packageName});
    return info;
  }

  static Future<Uint8List> getPackageIconByName(String packageName) async {
    return await _channel
        .invokeMethod('getPackageIconByName', {'packageName': packageName});
  }
}
