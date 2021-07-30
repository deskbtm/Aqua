import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:aqua/aqua.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  if (await Permission.storage.request().isGranted) {
    runApp(Aqua());
    // await SentryFlutter.init(
    //   (options) {
    //     options.dsn = SENTRY_DNS;
    //   },
    //   appRunner: () => runApp(Aqua()),
    // );
  }
}
