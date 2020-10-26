import 'dart:io';
import 'dart:isolate';
import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// 新建线程发送
/// [port] 目标端口
/// [ip] 目标ip
/// [filename] 文件名
/// [filepath] 文件路径

void isolateAirDrop(List msg) async {
  // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
  // ReceivePort recPort = ReceivePort();
  SendPort sendPort = msg[0];

  Map data = msg[1];
  String port = data['port'],
      ip = data['ip'],
      filename = data['filename'],
      filepath = data['filepath'];

  String url = 'http://$ip:$port';

  IO.Socket socket = IO.io(url, {
    'transports': ['websocket'],
    'autoConnect': true
  });

  socket.on('connect', (_) {
    socket.emit('will-upload-file', {'filename': filename});

    File(filepath).openRead().listen((bytes) {
      socket.emitWithBinary('upload-file', bytes);
    }, onDone: () {
      debugPrint('[isolate]: $filename done');
      socket.emit('upload-file-done');
      sendPort.send('done');
    });
  });

  socket.on('connect_error', (_) {
    sendPort.send('fail');
  });

  socket.on('connect_timeout', (_) {
    sendPort.send('fail');
  });

  socket.on('error', (error) {
    recordError(text: error.toString(), methodName: 'isolateAirDrop');
    sendPort.send('fail');
  });
}
