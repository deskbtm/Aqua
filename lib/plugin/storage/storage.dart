import 'package:flutter/services.dart';

import 'enums.dart';

class ExtraStorage {
  static const MethodChannel _channel = const MethodChannel('aqua_storage');

  static Future<String> get getTemporaryDirectory async {
    final String path = await _channel.invokeMethod('getTemporaryDirectory');
    return path;
  }

  static Future<String> get getApplicationDocumentsDirectory async {
    final String path =
        await _channel.invokeMethod('getApplicationDocumentsDirectory');
    return path;
  }

  static Future<String> get getStorageDirectory async {
    final String path = await _channel.invokeMethod('getStorageDirectory');
    return path;
  }

  static Future<String> get getApplicationSupportDirectory async {
    final String path =
        await _channel.invokeMethod('getApplicationSupportDirectory');
    return path;
  }

  static Future<String> get getExternalStorageDirectory async {
    final String path =
        await _channel.invokeMethod('getExternalStorageDirectory');
    return path;
  }

  Future<List<String>> get getExternalCacheDirectories async {
    final List<String> path =
        await _channel.invokeMethod('getExternalCacheDirectories');
    return path;
  }

  Future<List<String>> getExternalStorageDirectories(
    StorageDirectory type,
  ) async {
    final List<String> path = await _channel
        .invokeMethod('getExternalStorageDirectories', {'type': type});
    return path;
  }

  // /storage/emulated/0/packname/files
  static Future<String> get getFilesDir async {
    final String path = await _channel.invokeMethod('getFilesDir');
    return path;
  }

  static Future<String> get getCacheDir async {
    final String path = await _channel.invokeMethod('getCacheDir');
    return path;
  }

  static Future<String> get getDataDirectory async {
    final String path = await _channel.invokeMethod('getDataDirectory');
    return path;
  }

  static Future<String> get getExternalCacheDir async {
    final String path = await _channel.invokeMethod('getExternalCacheDir');
    return path;
  }

  static Future<double> get getTotalExternalStorageSize async {
    final double size =
        await _channel.invokeMethod('getTotalExternalStorageSize');
    return size;
  }

  static Future<double> get getValidExternalStorageSize async {
    final double size =
        await _channel.invokeMethod('getValidExternalStorageSize');
    return size;
  }
}
