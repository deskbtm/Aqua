import 'package:flutter/services.dart';

import 'enums.dart';

class ExtraStorage {
  static const MethodChannel _channel = const MethodChannel('aqua_fs');

  static Future<String> get getTemporaryDirectory async {
    final String path = await _channel.invokeMethod('getTemporaryDirectory');
    return path;
  }

  static Future<String> get getApplicationDocumentsDirectory async {
    final String path =
        await _channel.invokeMethod('getApplicationDocumentsDirectory');
    return path;
  }

  static Future<String?> get getExternalFilesDir async {
    final String path = await _channel.invokeMethod('getExternalFilesDir');
    return path;
  }

  static Future<String> get getApplicationSupportDirectory async {
    final String path =
        await _channel.invokeMethod('getApplicationSupportDirectory');
    return path;
  }

  static Future<String>? get getExternalStorageDirectory async {
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

  static Future<bool> requestDataObbAccess() async {
    final bool r = await _channel.invokeMethod('requestDataObbAccess');
    return r;
  }

  static Future<List<ValidStorage>> getAllValidStorage() async {
    List<ValidStorage> r = [];
    List<Object?> s = await _channel.invokeMethod('getAllValidStorage');

    for (var item in s) {
      if (item != null) {
        Map mItem = item as Map;

        r.add(
          ValidStorage(
            description: mItem['description'],
            isEmulated: mItem['isEmulated'],
            isPrimary: mItem['isPrimary'],
            path: mItem['path'],
            isRemovable: mItem['isRemovable'],
          ),
        );
      }
    }

    return r;
  }

  static Future<bool> canRead(String path) async {
    final bool readable = await _channel.invokeMethod('canRead', {path});
    return readable;
  }
}

class ValidStorage {
  final String path;
  final String description;
  final bool isRemovable;
  final bool isEmulated;
  final bool isPrimary;

  ValidStorage(
      {required this.path,
      required this.description,
      required this.isRemovable,
      required this.isEmulated,
      required this.isPrimary});
}
