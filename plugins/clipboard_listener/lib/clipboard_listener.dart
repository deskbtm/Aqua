import 'dart:ui';

import 'package:flutter/services.dart';

class ClipboardListener {
  static const MethodChannel _channel =
      const MethodChannel('clipboard_listener');

  /// 监听器对象
  static ClipboardListenerObj _listener;

  /// 添加消息监听
  static void addListener(VoidCallback func) {
    if (_listener == null) {
      _listener = ClipboardListenerObj(_channel);
    }
    _listener.addListener(func);
  }

  /// 移除消息监听
  static void removeListener(VoidCallback func) {
    if (_listener == null) {
      _listener = ClipboardListenerObj(_channel);
    }
    _listener.removeListener(func);
  }
}

/// 监听器对象
class ClipboardListenerObj {
  /// 监听器列表
  static Set<VoidCallback> listeners = Set();

  ClipboardListenerObj(MethodChannel channel) {
    // 绑定监听器
    channel.setMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'onListener':
          for (var lis in listeners) {
            lis();
          }
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  /// 添加消息监听
  void addListener(VoidCallback func) {
    listeners.add(func);
  }

  /// 移除消息监听
  void removeListener(VoidCallback func) {
    listeners.remove(func);
  }
}
