import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/isolate/search_devices.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketConnecter {
  final CommonModel commonProvider;
  dynamic _cachedClipboard;
  bool _resourceLocker = false;

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
      recordError(text: '', exception: error, methodName: 'createClient');
      if (onNotExpected != null) onNotExpected("连接出现错误");
      socket.destroy();
    });

    socket.on('connect_timeout', (error) {
      if (onNotExpected != null) onNotExpected("连接超时");
    });
  }

  Future<void> searchDevicesAndConnect(
    BuildContext context, {
    int limit = 10,
    ThemeModel themeProvider,
    Function(String) onNotExpected,
    bool initiativeConnect = true,
  }) async {
    if (_resourceLocker) {
      LocalNotification.showNotification(
        name: 'SOCKET_UNCONNECT',
        title: '资源占用中....',
      );
    } else {
      Map data = {
        'limit': limit,
        'filePort': commonProvider.filePort,
        'internalIp': commonProvider.internalIp,
      };

      ReceivePort recPort = ReceivePort();
      SendPort sendPort = recPort.sendPort;
      Isolate isolate = await Isolate.spawn(searchDevice, [sendPort, data]);
      _resourceLocker = true;
      recPort.listen(
        (message) {
          if (message == NOT_FOUND_DEVICES) {
            isolate?.kill();
            _resourceLocker = false;
            LocalNotification.showNotification(
              name: 'SOCKET_UNCONNECT',
              title: '未找到可用设备',
              subTitle: '请在更多中 手动连接',
            );
          }

          if (message is List<String> && message.isNotEmpty) {
            isolate?.kill();
            _resourceLocker = false;
            // message
            //     .addAll(['122.123.123.12', '122.123.123.11', '122.123.123.10']);
            if (message.length > 1) {
              Timer timer;
              showSelectModal(
                context,
                themeProvider,
                options: message,
                title: '选择连接IP',
                onSelected: (index) {
                  // 点击了就取消 2.5s 后自动消失的任务
                  timer?.cancel();
                  MixUtils.safePop(context);
                  createClient(message[index], onNotExpected: onNotExpected,
                      onConnected: () {
                    commonProvider.setCurrentConnectIp(message[index]);
                    commonProvider.addToCommonIps(message[index]);
                  });
                },
                // 不点击自动执行 手动连接 不自动消失
                doAction: (context) {
                  if (initiativeConnect) {
                    if (commonProvider.enableAutoConnectCommonIp) {
                      timer = Timer(
                        Duration(milliseconds: 2500),
                        () {
                          MixUtils.safePop(context);
                          String commonIp = commonProvider.getMostCommonIp();
                          if (commonIp != null) {
                            commonProvider.setCurrentConnectIp(commonIp);
                            createClient(
                              commonIp,
                              onNotExpected: onNotExpected,
                              onConnected: () {
                                commonProvider.addToCommonIps(commonIp);
                              },
                            );
                          }
                        },
                      );
                    }
                  }
                },
              );
            } else {
              createClient(message.first, onNotExpected: onNotExpected,
                  onConnected: () {
                commonProvider.setCurrentConnectIp(message.first);
                commonProvider.addToCommonIps(message.first);
              });
            }
          }
        },
      );
    }
  }
}
