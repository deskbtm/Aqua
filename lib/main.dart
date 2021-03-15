import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:aqua/aqua.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) async {
    if (MixUtils.isDev) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      FLog.error(
        methodName: "FlutterError",
        text: details.toString(),
        stacktrace: details.stack,
      );
      // 重定向到runZone中处理
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  runZoned<Future<void>>(
    () async {
      await Future.wait([
        MixUtils.checkPermissionAndRequest(PermissionGroup.storage),
      ]);

      runApp(Aqua());
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        FLog.error(
          methodName: "zoneSpecification",
          text: "line",
        );
      },
    ),
  );
}
