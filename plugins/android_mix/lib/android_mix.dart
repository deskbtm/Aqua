import 'package:android_mix/archive/archive.dart';
import 'package:android_mix/storage/storage.dart';
import 'package:android_mix/packager/packager.dart';
import 'package:flutter/services.dart';

class AndroidMix {
  static const MethodChannel _channel = const MethodChannel('android_mix');
  static Storage get storage {
    return Storage(_channel);
  }

  static Packager get packager {
    return Packager(_channel);
  }

  static Archive get archive {
    return Archive(_channel);
  }
}
