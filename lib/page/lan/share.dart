import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:lan_express/common/socket/socket.dart';
import 'package:lan_express/common/widget/images.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_item.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/page/lan/create_download_res.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/share.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/notification.dart';
import 'package:lan_express/web/web_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_body_parser/shelf_body_parser.dart';
import 'package:storage_mount_listener/storage_mount_listener.dart';

class StaticSharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StaticSharePageState();
  }
}

class _StaticSharePageState extends State<StaticSharePage> {
  ThemeProvider _themeProvider;
  ShareProvider _shareProvider;

  CommonProvider _commonProvider;
  HttpServer _server;
  bool _shareSwitch;
  bool _vscdeSwitch;
  bool _mutex;

  @override
  void initState() {
    super.initState();
    StorageMountListener.onMediaMounted(() {
      print("demo");
    });

    StorageMountListener.onMediaRemove(() {
      print("demo");
    });

    StorageMountListener.onMediaEject(() {
      print("demo");
    });
    _mutex = true;
    _shareSwitch = false;
    _vscdeSwitch = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _shareProvider = Provider.of<ShareProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);

    if (mounted) {
      setState(() {});
    }
    if (_mutex) {
      _mutex = false;
    }
  }

  Future<void> showDownloadResourceModal(BuildContext context) async {
    await createProotEnv(
      context,
      themeProvider: _themeProvider,
      commonProvider: _commonProvider,
      onSuccess: () {
        showText('安装完成');
        MixUtils.safePop(context);
      },
    );
  }

  Future<void> createStaticServer() async {
    try {
      String ip = _commonProvider?.internalIp;
      int port = int.parse(_commonProvider?.filePort ?? '20201');
      String savePath = _commonProvider?.staticUploadSavePath;
      FutureOr<Response> Function(Request) handlerFunc;

      if (_shareProvider.selectedFiles.isNotEmpty) {
        SelfFileEntity first = _shareProvider.selectedFiles.first;

        if (first.isDir) {
          handlerFunc = createWebHandler(
            first.entity.path,
            isDark: _themeProvider.isDark,
            uploadSavePath: savePath,
            serverUrl: '$ip:$port',
          );
        } else {
          handlerFunc = createFilesHandler(
            _shareProvider.selectedFiles.map((e) => e.entity.path).toList(),
            isDark: _themeProvider.isDark,
            serverUrl: '$ip:$port',
            uploadSavePath: savePath,
          );
        }
      } else {
        handlerFunc = createWebHandler(
          _commonProvider.storageRootPath,
          isDark: _themeProvider.isDark,
          serverUrl: '$ip:$port',
          uploadSavePath: savePath,
        );
      }

      var handler = const Pipeline()
          .addMiddleware(bodyParser(storeOriginalBuffer: false))
          .addHandler(handlerFunc);

      if (_shareSwitch) {
        LocalNotification.showNotification(
          index: 0,
          name: 'STATIC_SHARING',
          title: '静态文件共享中.....',
          ongoing: true,
        );
        _server = await shelf.serve(
          handler,
          ip,
          port,
          shared: true,
        );
        debugPrint('Serving at http://${_server.address.host}:${_server.port}');
      } else {
        _server?.close();
        showText('共享关闭');
        LocalNotification.plugin?.cancel(0);
      }
    } catch (err) {
      throw Exception(err);
    }
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    String internalIp = _commonProvider.internalIp;
    String filePort = _commonProvider.filePort;
    String codeSrvPort = _commonProvider.codeSrvPort;
    // String codeSrvIp = _commonProvider.codeSrvIp;

    String firstAliveIp =
        // ignore: null_aware_in_logical_operator
        _commonProvider.aliveIps.isNotEmpty &&
                (_commonProvider.socket?.connected != null ||
                    _commonProvider.socket?.connected == true)
            ? '${_commonProvider.aliveIps.first}:${_commonProvider.filePort}'
            : '暂未连接';

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            flex: 1,
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ListTile(
                        title: LanText('静态文件服务'),
                        subtitle: LanText('$internalIp:$filePort', small: true),
                        contentPadding: EdgeInsets.only(left: 15, right: 10),
                        trailing: LanSwitch(
                          value: _shareSwitch,
                          onChanged: (val) async {
                            if (mounted) {
                              setState(() {
                                _shareSwitch = !_shareSwitch;
                              });
                            }
                            await createStaticServer().catchError((err) {
                              FLog.error(
                                  text: 'create static server error',
                                  methodName: 'createStaticServer',
                                  exception: err);
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: LanText('VScode Server'),
                        subtitle:
                            LanText('$internalIp:$codeSrvPort', small: true),
                        contentPadding: EdgeInsets.only(left: 15, right: 10),
                        trailing: LanSwitch(
                          value: _vscdeSwitch,
                          onChanged: (val) async {
                            CodeSrvUtils utils = await CodeSrvUtils().init();
                            bool outLocker = true;
                            bool errLocker = true;
                            if (!_commonProvider.isPurchased) {
                              showText('此功能为付费功能');
                              return;
                            }
                            if (await utils.existsAllResource()) {
                              setState(() {
                                _vscdeSwitch = !_vscdeSwitch;
                              });
                              if (val) {
                                String srvUrl = '$internalIp:$codeSrvPort';

                                LocalNotification.showNotification(
                                  index: 1,
                                  name: 'VSCODE_SHARING',
                                  title: 'vscode server 开启中.....',
                                  onlyAlertOnce: true,
                                  showProgress: true,
                                  indeterminate: true,
                                );

                                Process result = await utils.runServer(
                                  srvUrl,
                                  pwd: _commonProvider.codeSrvPwd,
                                );

                                result.stdout
                                    .transform(utf8.decoder)
                                    .listen((data) {
                                  if (outLocker) {
                                    LocalNotification.plugin?.cancel(1);
                                    LocalNotification.showNotification(
                                      index: 2,
                                      name: 'VSCODE_RUNNING',
                                      title: 'vscode server 运行中',
                                      ongoing: true,
                                    );
                                    outLocker = false;
                                  }
                                  debugPrint(data);
                                });
                                result.stderr
                                    .transform(utf8.decoder)
                                    .listen((data) {
                                  if (data != '') {
                                    if (errLocker) {
                                      errLocker = false;
                                      showText('错误 $data');
                                      LocalNotification.plugin?.cancel(1);
                                    }
                                  }
                                  debugPrint(data);
                                });
                              } else {
                                await utils.killNodeServer();
                                LocalNotification.plugin?.cancel(2);
                                showText('vscode 服务已关闭');
                              }
                            } else {
                              await showDownloadResourceModal(context);
                            }
                          },
                        ),
                      ),
                      ListTile(
                        title: LanText('内网快递'),
                        subtitle: LanText('$firstAliveIp', small: true),
                        contentPadding: EdgeInsets.only(left: 15, right: 10),
                        // ignore: null_aware_in_condition
                        trailing: (_commonProvider.socket?.connected != null &&
                                _commonProvider.socket.connected == true)
                            ? Container(width: 1, height: 1)
                            : CupertinoButton(
                                child: NoResizeText('连接'),
                                onPressed: () async {
                                  LocalNotification.showNotification(
                                      name: 'SEARCH_DEVICE', title: '搜寻设备中...');
                                  await SocketConnecter(_commonProvider)
                                      .searchDeviceAndConnect();
                                },
                              ),
                      ),
                      CupertinoButton(
                        child: Text('click'),
                        onPressed: () async {
                          CodeSrvUtils cutils = await CodeSrvUtils().init();
                          ProcessResult a = await Process.run(
                              '${cutils.filesPath}/busybox', []);

                          print(a.stdout.toString());
                          print(a.stderr.toString());
                          // ProcessResult a = await cutils.installNodeJs();
                          // print(a.stdout.toString());
                          // print(a.stderr.toString());
                          // showScopeModal(
                          //   context,
                          //   _themeProvider,
                          //   title: '请仔细阅读教程',
                          //   tip: '该界面无返返回, 需前往教程, 后方可消失',
                          //   withCancel: false,
                          //   defaultOkText: '前往教程',
                          //   onOk: () async {
                          //     if (await canLaunch(TUTORIAL_URL)) {
                          //       await launch(TUTORIAL_URL);
                          //     }
                          //   },
                          // );
                        },
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _shareProvider.selectedFiles.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        size: 57,
                      ),
                      SizedBox(height: 20),
                      LanText('默认分享根目录', alignX: 0, fontSize: 14)
                    ],
                  ))
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: _shareProvider.selectedFiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      SelfFileEntity file =
                          _shareProvider.selectedFiles.elementAt(index);

                      Widget previewIcon = getPreViewIcon(file);

                      return Dismissible(
                        key: ObjectKey(file),
                        onDismissed: (direction) {
                          _shareProvider.selectedFiles.remove(file);
                        },
                        child: FileItem(
                          type: FileItemType.file,
                          leading: previewIcon,
                          withAnimation: index < 15,
                          index: index,
                          subTitle: MixUtils.formatFileTime(file.modified),
                          justDisplay: true,
                          filename: file.filename,
                          path: file.entity.path,
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}
