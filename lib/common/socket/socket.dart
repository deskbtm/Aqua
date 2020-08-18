import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket createSocketClient(String url,
    {Function(dynamic) onConnect, Function(dynamic) onDisconnect}) {
  IO.Socket socket = IO.io(url, {
    'transports': ['websocket'],
    'autoConnect': true
  });

  socket.on('connect', onConnect ?? (_) {});
  socket.on('disconnect', onDisconnect ?? (_) {});
  return socket;
}

IO.Socket createMySocketClient({
  @required String ip,
  @required String port,
  @required String internalIp,
  Function(IO.Socket) onInitSocket,
  Function(IO.Socket) onConnect,
  Function(dynamic) onDisconnect,
  Function(String) onReceiveClipboard,
  Function(String) onReceiveFile,
  bool isInit = false,
}) {
  String url = 'http://$ip:$port';

  IO.Socket socket = IO.io(url, {
    'transports': ['websocket'],
    'autoConnect': true
  });

  if (onConnect != null) onInitSocket(socket);

  socket.on('connect', (_) {
    if (isInit) {
      BotToast.showSimpleNotification(
        title: '自动连接至',
        subTitle: url,
        closeIcon: Icon(Icons.close),
        duration: Duration(seconds: 8),
      );
    }

    // 发送本机地址 作为已连接的地址
    socket.emit(CONNECTED_ADDRESS, '$internalIp:$port');
    if (onConnect != null) onConnect(socket);
  });
  socket.on('disconnect', (_) {
    if (onDisconnect != null) onDisconnect(_);
  });

  socket.on('clipboard-to-client', (_) {
    if (onReceiveClipboard != null) onReceiveClipboard(_);
  });

  // socket.on('clipboard-to-client', (_) {
  //   if (onReceiveFile != null) onReceiveFile(_);
  // });

  socket.on('connect_error', (error) {
    FLog.error(text: error.toString(), methodName: 'createSocketIOClient');
  });

  return socket;
}
