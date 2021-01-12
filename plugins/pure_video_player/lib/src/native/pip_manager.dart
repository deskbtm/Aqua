import 'dart:async';
// import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:get/state_manager.dart';

class PipManager {
  final _channel = MethodChannel("pure_video_player");

  Completer<double> _osVersion = Completer();
  Completer<bool> _pipAvailable = Completer();

  RxBool isInPipMode = false.obs;

  PipManager() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPictureInPictureModeChanged') {
        isInPipMode.value = call.arguments;
      }
    });
  }

  Future<double> get osVersion async {
    return _osVersion.future;
  }

  Future<bool> get pipAvailable async {
    return _pipAvailable.future;
  }

  // Future<void> _getOSVersion() async {
  //   final os = double.parse(await _channel.invokeMethod<String>('osVersion'));
  //   this._osVersion.complete(os);
  // }

  Future<void> enterPip() async {
    await _channel.invokeMethod('enterPip');
  }

  // Future<bool> checkPipAvailable() async {
  //   bool available = false;
  //   if (Platform.isAndroid) {
  //     await this._channel.invokeMethod('initPipConfiguration');
  //     await _getOSVersion();
  //     final osVersion = await _osVersion.future;
  //     // check the OS version
  //     if (osVersion >= 7) {
  //       return true;
  //     }
  //   }
  //   this._pipAvailable.complete(available);
  //   return available;
  // }
}
