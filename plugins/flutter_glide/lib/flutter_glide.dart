import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_glide/enum.dart';

class FlutterGlide {
  static const MethodChannel _channel = const MethodChannel('flutter_glide');

  static Future<Uint8List> getLocalThumbnail({
    int width,
    int height,
    String path,
    int quality = 100,
    ThumbFormat format = ThumbFormat.png,
  }) {
    return _channel.invokeMethod('getLocalThumbnail', {
      'width': width,
      'height': height,
      'path': path,
      'format': format.index,
      'quality': quality,
    });
  }
}
