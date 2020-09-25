import 'dart:async';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/notification.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketConnecter {
  final CommonProvider commonProvider;
  dynamic _cachedClipboard;
  int _counter = 0;

  SocketConnecter(this.commonProvider);

  Future<void> _clipboardListener() async {
    if (commonProvider.enableClipboard) {
      ClipboardData content = await Clipboard.getData(Clipboard.kTextPlain);
      // 防止重复发
      if (_cachedClipboard != content.text) {
        _cachedClipboard = content.text;
        commonProvider.socket?.emit('clipboard-to-server', content.text);
      }
    }
  }

  void createClient(
    targetIp, {
    Function onConnected,
    Function onDisconnected,
    Function(String) onNotExpected,
  }) {
    String port = commonProvider.filePort;
    String internalIp = commonProvider.internalIp;

    String url = 'http://$targetIp:$port';

    IO.Socket socket = IO.io(url, {
      'transports': ['websocket'],
      'autoConnect': commonProvider.autoConnectExpress,
    });

    commonProvider.setSocket(socket);

    socket.on('connect', (_) {
      BotToast.showSimpleNotification(
        title: '自动连接至',
        subTitle: url,
        closeIcon: Icon(Icons.close),
        duration: Duration(seconds: 8),
      );
      // 发送本机地址 作为已连接的地址
      socket.emit('connected-address', {
        'deviceIp': '$internalIp:$port',
        'codeSrvIp': '$internalIp:${commonProvider.codeSrvPort}'
      });
      commonProvider.setSocket(socket);
      ClipboardListener.addListener(_clipboardListener);
      if (onConnected != null) onConnected();
    });

    socket.on('disconnect', (_) {
      LocalNotification.showNotification(
        name: 'SOCKET_DISCONNECT_ID',
        title: '已与设备断开连接',
      );
      ClipboardListener.removeListener(_clipboardListener);
      if (onDisconnected != null) onDisconnected();
    });

    socket.on('clipboard-to-client', (data) async {
      if (commonProvider.enableClipboard) {
        await Clipboard.setData(ClipboardData(text: data));
      }
    });

    socket.on('connect_error', (error) {
      FLog.error(text: '$error', methodName: 'createClient');
      if (onNotExpected != null) onNotExpected("连接出现错误");
      socket.destroy();
    });

    socket.on('connect_timeout', (error) {
      FLog.error(text: '$error', methodName: 'createClient');
      if (onNotExpected != null) onNotExpected("连接超时");
    });
  }

  Future<void> searchDeviceAndConnect(
    BuildContext context, {
    int limit = 10,
    ThemeProvider provider,
    Function(String) onNotExpected,
    // Function(String) onSelectedWhenMultiIps,
    bool initiativeConnect = true,
  }) async {
    _counter++;
    if (_counter >= limit) {
      _counter = 0;
      LocalNotification.showNotification(
        name: 'SOCKET_UNCONNECT',
        title: '未找到可用设备',
        subTitle: '请在更多中 手动连接',
      );
    } else {
      await MixUtils.scanSubnet(commonProvider);
      // commonProvider.pushAliveIps('192.168.43.19');
      // commonProvider.pushAliveIps('192.168.43.18');
      // commonProvider.pushAliveIps('192.168.43.20');
      if (commonProvider.aliveIps.isNotEmpty) {
        if (commonProvider.aliveIps.length > 1) {
          List<String> list = commonProvider.aliveIps.toList();
          Timer timer;

          showSelectModal(
            context,
            provider,
            options: list,
            title: '选择连接IP',
            onSelected: (index) {
              timer?.cancel();
              MixUtils.safePop(context);
              createClient(list[index], onNotExpected: onNotExpected,
                  onConnected: () {
                commonProvider.addToCommonIps(list[index]);
              });
            },
            doAction: (context) {
              if (initiativeConnect) {
                if (commonProvider.enableAutoConnectCommonIp) {
                  timer = Timer(
                    Duration(milliseconds: 2500),
                    () {
                      MixUtils.safePop(context);
                      String commonIp = commonProvider.getMostCommonIp();
                      print(commonIp);
                      if (commonIp != null) {
                        createClient(commonIp, onNotExpected: onNotExpected,
                            onConnected: () {
                          commonProvider.addToCommonIps(commonIp);
                        });
                      }
                    },
                  );
                }
              }
            },
          );
        } else {
          createClient(commonProvider.aliveIps.first,
              onNotExpected: onNotExpected, onConnected: () {
            commonProvider.addToCommonIps(commonProvider.aliveIps.first);
          });
        }
      } else {
        await Future.delayed(Duration(milliseconds: 600));
        await searchDeviceAndConnect(context, limit: limit);
      }
    }
  }
}
