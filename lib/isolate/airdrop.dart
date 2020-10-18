import 'dart:io';
import 'dart:isolate';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    FLog.error(text: error.toString(), methodName: 'isolateAirDrop');
    sendPort.send('fail');
  });
}

// Future sendReceive(SendPort port, dynamic msg) {
//   ReceivePort response = new ReceivePort();
//   port.send([msg, response.sendPort]);
//   return response.first;
// }
