import 'package:flutter/widgets.dart';
import 'package:io/io.dart';
import 'package:lan_express/provider/common.dart';
import 'package:open_file/open_file.dart';
  import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as pathLib;
import 'package:ping_discover_network/ping_discover_network.dart';

class MixUtils {
  /// 判断开发环境
  static bool get isDev {
    bool flag = false;
    assert(flag = true);
    return flag;
  }

  static Future<void> checkPermissionAndRequest(PermissionGroup p) async {
    // PermissionStatus status = await Permission.storage.status;
    // if (!status.isGranted) {
    //   await Permission.contacts.request();
    //   PermissionStatus newStatus = await Permission.storage.status;
    //   if (newStatus.isDenied) {
    //     await checkPermissionAndRequest();
    //   }
    // }

    PermissionStatus status =
        await PermissionHandler().checkPermissionStatus(p);
    if (PermissionStatus.granted != status) {
      await PermissionHandler().requestPermissions(<PermissionGroup>[p]);
      PermissionStatus status =
          await PermissionHandler().checkPermissionStatus(p);
      if (PermissionStatus.granted != status) {
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

  static String openFile(BuildContext context, String path) {
    String ext = pathLib.extension(path);
    switch (ext) {
      case '.txt':
      case '.md':

      default:
        OpenFile.open(path);
    }
  }

  static Future scanSubnet(CommonProvider settingProvider) async {
    String port = settingProvider?.expressPort;
    String internalIp = settingProvider?.internalIp;
    String subnet =
        internalIp?.substring(0, internalIp?.lastIndexOf('.')) ?? '';
    final stream = NetworkAnalyzer.discover2(subnet, int.parse(port));
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        settingProvider.pushAliveIps(addr.ip, notify: false);
      }
    });
  }

  static safePop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

final c = new ProcessManager();
