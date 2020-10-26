import 'dart:async';
import 'dart:io';
import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:lan_file_more/lan_file_more.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more_umeng/lan_file_more_umeng.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constant/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CatcherOptions debugOptions = CatcherOptions(DialogReportMode(), [
    // ConsoleHandler(),
    EmailManualHandler([EMAIL])
  ]);

  CatcherOptions releaseOptions = CatcherOptions(DialogReportMode(), [
    EmailManualHandler([EMAIL])
  ]);

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

  LanFileMoreUmeng.init(
    androidAppKey: UMENG_APP_KEY,
    channel: 'dev',
    enableLog: MixUtils.isDev,
    enableReportError: true,
  );

  if (Platform.isAndroid) {
    // 沉浸式
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  runZoned<Future<void>>(
    () async {
      await Future.wait([
        MixUtils.checkPermissionAndRequest(PermissionGroup.storage),
      ]);

      runApp(LanFileMore());
      // Catcher(LanFileMore(),
      //     debugConfig: debugOptions, releaseConfig: releaseOptions);
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
