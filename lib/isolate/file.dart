import 'dart:isolate';
import 'package:android_mix/android_mix.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_express/page/file_manager/file_action.dart';

void isolateArchive(List msg) async {
  // WidgetsFlutterBinding.ensureInitialized();
  SendPort sendPort = msg[0];
  Map data = msg[1];
  String type = data['type'];
  List<String> paths = data['paths'];
  String targetDir = data['targetDir'];
  String pwd = data['pwd'];

  try {
    String archivePath = FileAction.genPathWhenExists(targetDir, '.' + type);

    switch (type) {
      case 'zip':
        AndroidMix.archive.zip(
          paths,
          archivePath,
          pwd: pwd?.trim(),
          onZip: (data) {},
          onZipSuccess: () async {
            sendPort.send('done');
          },
        );
        break;
    }
  } catch (err) {
    sendPort.send('fail');
  }
}
