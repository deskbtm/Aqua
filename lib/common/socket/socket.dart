import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/isolate/search_devices.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketConnecter {
  final CommonModel _commonModel;
  dynamic _cachedClipboard;
  static SocketConnecter _connecter;

  SocketConnecter(this._commonModel);

  Future<void> _clipboardListener() async {
    if (_commonModel.enableClipboard) {
      ClipboardData content = await Clipboard.getData(Clipboard.kTextPlain);
      // 防止重复发
      if (_cachedClipboard != content?.text) {
        _cachedClipboard = content.text;
        _commonModel.socket?.emit('clipboard-to-server', content.text);
      }
    }
  }

  void createClient(
    targetIp, {
    Function onConnected,
    Function onDisconnected,
    Function(String) onNotExpected,
  }) {
    String port = _commonModel.filePort;
    String internalIp = _commonModel.internalIp;

    String url = 'http://$targetIp:$port';

    IO.Socket socket = IO.io(url, {
      'transports': ['websocket'],
      'autoConnect': _commonModel.autoConnectExpress,
      'timeout': 20000,
    });

    _commonModel.setSocket(socket);

    socket.on('connect', (_) {
      LocalNotification.showNotification(
        name: 'SOCKET_CONNECT_ID',
        title: '自动连接至',
        subTitle: url,
      );

      // 发送本机地址 作为已连接的地址
      socket.emit('connected-address', {
        'deviceIp': '$internalIp:$port',
        'codeSrvIp': '$internalIp:${_commonModel.codeSrvPort}'
      });
      _commonModel.setSocket(socket);
      ClipboardListener.addListener(_clipboardListener);
      if (onConnected != null) onConnected();
    });

    socket.on('disconnect', (_) {
      LocalNotification.showNotification(
        name: 'SOCKET_DISCONNECT_ID',
        title: '已与设备断开连接',
      );
      _connecter = null;
      ClipboardListener.removeListener(_clipboardListener);
      if (onDisconnected != null) onDisconnected();
    });

    socket.on('clipboard-to-client', (data) async {
      if (_commonModel.enableClipboard) {
        await Clipboard.setData(ClipboardData(text: data));
      }
    });

    socket.on('connect_error', (error) {
      _connecter = null;
      // if (onNotExpected != null) onNotExpected("连接出现错误");
      // socket.destroy();
    });

    socket.on('connect_timeout', (error) {
      _connecter = null;
      if (onNotExpected != null) onNotExpected("连接超时");
    });
  }

  static Future<void> searchDevicesAndConnect(
    context, {
    int limit = 8,
    @required ThemeModel themeModel,
    @required CommonModel commonModel,
    Function(String) onNotExpected,
    bool initiativeConnect = true,
  }) async {
    if (_connecter == null) {
      _connecter = SocketConnecter(commonModel);
      _connecter._searchDevicesAndConnect(
        context,
        limit: limit,
        themeModel: themeModel,
        onNotExpected: onNotExpected,
        initiativeConnect: initiativeConnect,
      );
    } else {
      BotToast.showText(
        text: '搜索设备中....',
      );
    }
  }

  Future<void> _searchDevicesAndConnect(
    BuildContext context, {
    int limit = 8,
    ThemeModel themeModel,
    Function(String) onNotExpected,
    bool initiativeConnect = true,
  }) async {
    Map data = {
      'limit': limit,
      'filePort': _commonModel.filePort,
      'internalIp': _commonModel.internalIp,
    };

    ReceivePort recPort = ReceivePort();
    SendPort sendPort = recPort.sendPort;
    Isolate isolate = await Isolate.spawn(searchDevice, [sendPort, data]);
    recPort.listen(
      (message) {
        if (message == NOT_FOUND_DEVICES) {
          isolate?.kill();

          _connecter = null;

          LocalNotification.showNotification(
            name: 'SOCKET_UNCONNECT',
            title: '未找到可用设备',
            subTitle: '请在更多中 手动连接',
          );
        }

        if (message is List<String> && message.isNotEmpty) {
          isolate?.kill();

          if (message.length > 1) {
            Timer timer;
            showSelectModal(
              context,
              themeModel,
              options: message,
              title: '选择连接IP',
              onSelected: (index) {
                // 点击了就取消 2.5s 后自动消失的任务
                timer?.cancel();
                MixUtils.safePop(context);
                createClient(message[index], onNotExpected: onNotExpected,
                    onConnected: () {
                  _commonModel.setCurrentConnectIp(message[index]);
                  _commonModel.addToCommonIps(message[index]);
                });
              },
              // 不点击自动执行 手动连接 不自动消失
              doAction: (context) {
                if (initiativeConnect) {
                  if (_commonModel.enableAutoConnectCommonIp) {
                    timer = Timer(
                      Duration(milliseconds: 2500),
                      () {
                        MixUtils.safePop(context);
                        String commonIp = _commonModel.getMostCommonIp();
                        if (commonIp != null) {
                          _commonModel.setCurrentConnectIp(commonIp);
                          createClient(
                            commonIp,
                            onNotExpected: onNotExpected,
                            onConnected: () {
                              _commonModel.addToCommonIps(commonIp);
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
              _commonModel.setCurrentConnectIp(message.first);
              _commonModel.addToCommonIps(message.first);
            });
          }
        }
      },
    );
  }
}
