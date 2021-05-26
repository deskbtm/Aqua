import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'enum.dart';

class AquaGlide {
  static const MethodChannel _channel = const MethodChannel('aqua_glide');

  static Future<Uint8List> getLocalThumbnail({
    required int width,
    required int height,
    required String path,
    int quality = 100,
    ThumbFormat format = ThumbFormat.png,
  }) {
    return _channel.invokeMethod('getLocalThumbnail', {
      'width': width,
      'height': height,
      'path': path,
      'format': format.index,
      'quality': quality,
    }) as Future<Uint8List>;
  }
}
