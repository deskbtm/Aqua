import 'package:android_mix/activity/activity.dart';
import 'package:android_mix/archive/archive.dart';
import 'package:android_mix/storage/storage.dart';
import 'package:android_mix/packager/packager.dart';
import 'package:android_mix/wifi/wifi.dart';
import 'package:flutter/services.dart';

class AndroidMix {
  static const MethodChannel _channel = const MethodChannel('android_mix');
  static Storage get storage {
    return Storage(_channel);
  }

  static MixPackageManager get packager {
    return MixPackageManager(_channel);
  }

  static Archive get archive {
    return Archive(_channel);
  }

  // static WiFi get wifi {
  //   return WiFi(_channel);
  // }

  static Activity get activity {
    return Activity(_channel);
  }

  // static Command get command {
  //   return Command(_channel);
  // }
}
