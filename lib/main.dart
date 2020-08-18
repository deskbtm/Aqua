import 'dart:async';
import 'dart:io';
import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:lan_express/lan_express.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'constant/constant.dart';

void main() {
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
      // 重定向到runZone中处理
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  if (Platform.isAndroid) {
    // 沉浸式
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  runZoned<Future<void>>(() async {
    await Future.wait(
        [MixUtils.checkPermissionAndRequest(PermissionGroup.storage)]);

    runApp(LanExpress());
    // Catcher(LanExpress(),
    //     debugConfig: debugOptions, releaseConfig: releaseOptions);
  }, onError: (error, stackTrace) async {
    FLog.error(
      methodName: "main",
      text: "$error",
    );
  });
}
