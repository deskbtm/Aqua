import 'package:flutter/services.dart';

class Command {
  MethodChannel _channel;

  Command(MethodChannel mc) {
    _channel = mc;
  }

  Future<Map> exec(String cmd, {List<String> envp, String cwd}) async {
    final Map info = await _channel
        .invokeMethod('exec', {'cmd': cmd, 'envp': envp, 'cwd': cwd});
    return info;
  }
}
