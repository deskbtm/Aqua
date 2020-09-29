import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:android_mix/android_mix.dart';
import 'package:device_info/device_info.dart';
import 'package:lan_express/provider/common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:path/path.dart' as pathLib;

class MixUtils {
  /// 判断开发环境
  static bool get isDev {
    bool flag = false;
    assert(flag = true);
    return flag;
  }

  static Future<void> checkPermissionAndRequest(PermissionGroup p,
      {bool recursive = true}) async {
    PermissionStatus status =
        await PermissionHandler().checkPermissionStatus(p);
    if (PermissionStatus.granted != status) {
      await PermissionHandler().requestPermissions(<PermissionGroup>[p]);
      PermissionStatus status =
          await PermissionHandler().checkPermissionStatus(p);
      if (PermissionStatus.granted != status && recursive) {
        await checkPermissionAndRequest(p);
      }
    }
  }

  static String humanStorageSize(double value, {bool useDouble = false}) {
    if (null == value) {
      return "0B";
    }
    List<String> unitArr = List()..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return useDouble ? size : size + unitArr[index];
  }

  static String formatFileTime(dynamic time, {int from = 5, int end = 16}) {
    if (time is String) {
      DateTime dt = DateTime.parse(time);
      return '${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute}:${dt.second}';
    } else {
      return '${time.year}/${time.month}/${time.day} ${time.hour}:${time.minute}:${time.second}';
    }
  }

  // static Future scanSubnet(CommonProvider settingProvider) async {
  //   String port = settingProvider?.filePort;
  //   String internalIp = settingProvider?.internalIp;
  //   String subnet =
  //       internalIp?.substring(0, internalIp?.lastIndexOf('.')) ?? '';
  //   final stream = NetworkAnalyzer.discover2(subnet, int.parse(port));
  //   await for (var addr in stream) {
  //     if (addr.exists) {
  //       settingProvider.pushAliveIps(addr.ip, notify: false);
  //       return;
  //     }
  //   }
  // }

  static safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static Future<String> getAndroidId() async {
    AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    return info.androidId;
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
    return input != null ? url.hasMatch(input) : true;
  }

  static Future<String> getPrimaryStaticUploadSavePath(String root) async {
    String tmp = pathLib.join(root, 'Lan_File_More/upload');
    if (!(await Directory(tmp).exists())) {
      await Directory(tmp).create(recursive: true);
    }
    return tmp;
  }

  static Future<String> getExternalPath() async {
    String path;
    path = Platform.environment['EXTERNAL_STORAGE'];
    if (path == null) {
      try {
        path = await AndroidMix.storage.getExternalStorageDirectory;
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
}
