import 'dart:async';

import 'package:flutter/services.dart';

class StorageMountListener {
  static const MethodChannel _channel =
      const MethodChannel('storage_mount_listener');

  static Future<void> onMediaMounted(Function func) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'mediaMounted') {
        func();
      }
    });
  }

  static Future<void> onMediaRemove(Function func) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'mediaRemove') {
        func();
      }
    });
  }

  static Future<void> onBadRemoval(Function func) async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'mediaBadRemoval') {
        func();
      }
    });
  }

  static Future<void> onMediaEject(Function func) async {
    _channel.setMethodCallHandler((call) async {
      print(call.method);
      if (call.method == 'mediaEject') {
        func();
      }
    });
  }
}
