import 'dart:isolate';

import 'package:lan_file_more/constant/constant.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

/// 搜索设备 List 参数0 [SendPort] 参数1 [Map]
/// [limit] 搜索设备尝试次数限制
/// [filePort] String
/// [internalIp] String
Future<void> searchDevice(List msg) async {
  SendPort sendPort = msg[0];
  Map data = msg[1];
  int limit = data['limit'];
  String filePort = data['filePort'];
  String internalIp = data['internalIp'];
  String subnet = internalIp?.substring(0, internalIp?.lastIndexOf('.')) ?? '';
  int _counter = 0;
  Set<String> availIps = Set();

  Future<void> searchDeviceInnerLoop() async {
    if (_counter >= limit) {
      _counter = 0;
      sendPort.send(NOT_FOUND_DEVICES);
    } else {
      _counter++;
      final stream = NetworkAnalyzer.discover2(subnet, int.parse(filePort));
      await for (var addr in stream) {
        if (addr.exists) {
          availIps.add(addr.ip);
        }
      }

      if (availIps.isNotEmpty) {
        sendPort.send(availIps.toList());
      } else {
        await Future.delayed(Duration(milliseconds: 600));
        await searchDeviceInnerLoop();
      }
    }
  }

  // 捕获搜索报错 捕获不处理
  await searchDeviceInnerLoop().catchError((err) {});
}
