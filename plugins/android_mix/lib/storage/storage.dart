import 'package:android_mix/storage/enums.dart';
import 'package:flutter/services.dart';

class Storage {
  MethodChannel _channel;

  Storage(MethodChannel mc) {
    _channel = mc;
  }

  Future<String> get getTemporaryDirectory async {
    final String path = await _channel.invokeMethod('getTemporaryDirectory');
    return path;
  }

  Future<String> get getApplicationDocumentsDirectory async {
    final String path =
        await _channel.invokeMethod('getApplicationDocumentsDirectory');
    return path;
  }

  Future<String> get getStorageDirectory async {
    final String path = await _channel.invokeMethod('getStorageDirectory');
    return path;
  }

  Future<String> get getApplicationSupportDirectory async {
    final String path =
        await _channel.invokeMethod('getApplicationSupportDirectory');
    return path;
  }

  Future<String> get getExternalStorageDirectory async {
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
  Future<String> get getFilesDir async {
    final String path = await _channel.invokeMethod('getFilesDir');
    return path;
  }

  Future<String> get getCacheDir async {
    final String path = await _channel.invokeMethod('getCacheDir');
    return path;
  }

  Future<String> get getDataDirectory async {
    final String path = await _channel.invokeMethod('getDataDirectory');
    return path;
  }

  Future<String> get getExternalCacheDir async {
    final String path = await _channel.invokeMethod('getExternalCacheDir');
    return path;
  }

  Future<double> get getTotalExternalStorageSize async {
    final double size =
        await _channel.invokeMethod('getTotalExternalStorageSize');
    return size;
  }

  Future<double> get getValidExternalStorageSize async {
    final double size =
        await _channel.invokeMethod('getValidExternalStorageSize');
    return size;
  }
}
