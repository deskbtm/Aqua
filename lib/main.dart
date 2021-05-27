import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:aqua/aqua.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'constant/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  runApp(Aqua());
  // if (await Permission.storage.request().isGranted) {
  //   await SentryFlutter.init(
  //     (options) {
  //       options.dsn = SENTRY_DNS;
  //     },
  //     appRunner: () => runApp(Aqua()),
  //   );
  // }
}
