import 'package:flutter/cupertino.dart';
import 'package:android_mix/android_mix.dart';
import 'package:lan_express/constant/constant.dart';

class NativeProvider extends ChangeNotifier {
  String _externalStorageRootPath = '';
  String get externalStorageRootPath => _externalStorageRootPath;

  Future<void> _getExternalStorageDirectory() async {
    _externalStorageRootPath =
        (await AndroidMix.storage.getExternalStorageDirectory) ??
            BAK_EXTERNAL_PATH;
  }

  Future<void> initNative() async {
    await _getExternalStorageDirectory();
  }
}
