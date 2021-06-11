import 'dart:io';

import 'package:aqua/plugin/storage/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:device_info/device_info.dart';
import 'package:path/path.dart' as pathLib;

class MixUtils {
  /// 判断开发环境
  static bool get isDev {
    bool flag = false;
    assert(flag = true);
    return flag;
  }

  static String humanStorageSize(double value, {bool useDouble = false}) {
    // ignore: unnecessary_null_comparison
    if (value == null) {
      return "0B";
    }
    List<String> unitArr = []..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return useDouble ? size : size + unitArr[index];
  }

  static String formatFileTime(DateTime time) {
    return '${time.year}/${time.month}/${time.day} ${time.hour}:${time.minute}:${time.second}';
  }

  static safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static String webMessage(dynamic data) {
    String msg;
    if (data is List) {
      msg = data.join(',');
    } else {
      msg = data;
    }
    return '$msg';
  }

  static Future<String> getAndroidId() async {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    return info.androidId;
  }

  static Future<Map> deviceInfo() async {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;

    return {
      'android_id': info.androidId,
      'release_version': info.version.release,
      'sdk_version': info.version.sdkInt,
      'brand': info.brand,
      'model': info.model,
      'name': info.product
    };
  }

  static Future<bool> isSDKOverAndroidN() async {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt >= 25;
  }

  static bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  static bool isPassword(String input) {
    RegExp mobile = new RegExp(r'(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$');
    return mobile.hasMatch(input);
  }

  static bool isHttpUrl(String input) {
    RegExp url = RegExp(r'^((https|http)?:\/\/)[^\s]+');
    return url.hasMatch(input);
  }

  static Future<String> getPrimaryStaticUploadSavePath(String root) async {
    String tmp = pathLib.join(root, 'aqua/upload');
    if (!(await Directory(tmp).exists())) {
      await Directory(tmp).create(recursive: true);
    }
    return tmp;
  }

  static Future<String> getExternalRootPath() async {
    late String? path;

    /// android 会把 外存路径挂到环境变量中
    path = await ExtraStorage.getExternalStorageDirectory;
    if (path == null) {
      try {
        path = Platform.environment['EXTERNAL_STORAGE']!;
        // 触发检查权限
        Directory(path).list();
      } catch (err) {
        path = '/sdcard';
        if (!Directory(path).existsSync()) {
          path = '/storage/self/primary';
        }
      }
    }

    return path;
  }

  static Future<List<Directory>> getValidExternalStoragePath() async {
    List<Directory> storages = [];
    String? secondaryStorage = Platform.environment['SECONDARY_STORAGE'];
    String? externalStorage = Platform.environment['EXTERNAL_STORAGE'];
    String? emulatedStorage = Platform.environment['EMULATED_STORAGE_TARGET'];

    if (emulatedStorage == null) {
      if (externalStorage != null) {
        storages.add(Directory(externalStorage));
      } else {
        String? path = await ExtraStorage.getExternalStorageDirectory;
        
      }
    } else {}

    return storages;
  }

  // RFC1918私有网络地址分配
  static Future<String?> getIntenalIp() async {
    String? ip;

    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.type.name == 'IPv4') {
          String pureAddr = addr.address.replaceAll(RegExp(r"\/\d+"), '');

          List block = pureAddr.split(RegExp(r"\."));

          if (block.length == 4) {
            if (block[0] == '192' &&
                block[1] == '168' &&
                int.parse(block[2]) >= 0 &&
                int.parse(block[2]) <= 255 &&
                int.parse(block[3]) >= 0 &&
                int.parse(block[3]) <= 255) {
              ip = addr.address;
            }

            if (block[0] == '172' &&
                int.parse(block[1]) >= 16 &&
                int.parse(block[1]) <= 33 &&
                int.parse(block[2]) >= 0 &&
                int.parse(block[2]) <= 255 &&
                int.parse(block[3]) >= 0 &&
                int.parse(block[3]) <= 255) {
              ip = addr.address;
            }

            if (block[0] == '10' &&
                int.parse(block[1]) >= 0 &&
                int.parse(block[1]) <= 255 &&
                int.parse(block[2]) >= 0 &&
                int.parse(block[2]) <= 255 &&
                int.parse(block[3]) >= 0 &&
                int.parse(block[3]) <= 255) {
              ip = addr.address;
            }
          }
        }
      }
    }
    return ip;
  }
}
