import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/constant/constant.dart';
import 'package:lan_file_more/page/file_manager/file_utils.dart';
import 'package:lan_file_more/page/lan/share/create_proot_env.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/web/body_parser/src/shelf_body_parser.dart';
import 'package:provider/provider.dart';
import 'package:lan_file_more/common/socket/socket.dart';
import 'package:lan_file_more/common/widget/images.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/switch.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/page/file_manager/file_item.dart';
import 'package:lan_file_more/page/lan/code_server/utils.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/web/web_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:wakelock/wakelock.dart';

class LanSharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanSharePageState();
  }
}

class _LanSharePageState extends State<LanSharePage>
    with AutomaticKeepAliveClientMixin {
  ThemeModel _themeModel;

  CommonModel _commonModel;
  HttpServer _server;
  bool _shareSwitch;
  bool _vscodeSwitch;

  @override
  void initState() {
    super.initState();
    _shareSwitch = false;
    _vscodeSwitch = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
  }

  Future<void> showDownloadResourceModal(BuildContext context) async {
    await createProotEnv(
      context,
      themeProvider: _themeModel,
      commonProvider: _commonModel,
      onSuccess: () {
        showText('安装完成');
        MixUtils.safePop(context);
      },
    );
  }

  void _uploadNotification(bool result) {
    result
        ? LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: '文件接收成功',
            autoCancel: true,
          )
        : LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: '文件接收失败',
            autoCancel: true,
          );
  }

  Future<void> createStaticServer() async {
    try {
      String ip = _commonModel.internalIp ?? LOOPBACK_ADDR;

      int port = int.parse(_commonModel?.filePort ?? FILE_DEFAULT_PORT);
      String savePath = _commonModel?.staticUploadSavePath;
      FutureOr<Response> Function(Request) handlerFunc;
      String addr = '$ip:$port';

      if (_commonModel.selectedFiles.isNotEmpty) {
        SelfFileEntity first = _commonModel.selectedFiles.first;

        if (first.isDir) {
          handlerFunc = createWebHandler(
            first.entity.path,
            isDark: _themeModel.isDark,
            uploadSavePath: savePath,
            serverUrl: addr,
            onUploadResult: _uploadNotification,
          );
        } else {
          handlerFunc = createFilesHandler(
            _commonModel.selectedFiles.map((e) => e.entity.path).toList(),
            isDark: _themeModel.isDark,
            serverUrl: addr,
            uploadSavePath: savePath,
            onUploadResult: _uploadNotification,
          );
        }
      } else {
        handlerFunc = createWebHandler(
          _commonModel.storageRootPath,
          isDark: _themeModel.isDark,
          serverUrl: addr,
          uploadSavePath: savePath,
          onUploadResult: _uploadNotification,
        );
      }

      var handler =
          const Pipeline().addMiddleware(bodyParser()).addHandler(handlerFunc);

      if (_shareSwitch) {
        _server = await shelf.serve(handler, ip, port, shared: true);
        LocalNotification.showNotification(
          index: 0,
          name: 'STATIC_SHARING',
          title: '静态文件共享中.....',
          ongoing: true,
          autoCancel: true,
        );
        debugPrint('Serving at http://${_server.address.host}:${_server.port}');

        // 保持唤醒状态
        bool isWakeEnabled = await Wakelock.enabled;

        if (!isWakeEnabled) {
          Wakelock.enable();
        }

        await showQrcodeModal(context, 'http://$addr');
      } else {
        _server?.close();
        showText('共享关闭');
        LocalNotification.plugin?.cancel(0);
        Wakelock.disable();
      }
    } catch (err) {
      throw Exception(err);
    }
  }

  void showText(String content) {
    BotToast.showText(text: content);
  }

  Future<void> _openCodeServer(BuildContext context, bool val,
      {String codeAddr}) async {
    if (!_commonModel.isPurchased) {
      showText('请先购买 "IOS管理器" for developer');
      return;
    }
    CodeSrvUtils utils = await CodeSrvUtils().init();
    bool outLocker = true;
    bool errLocker = true;

    if (await utils.existsAllResource()) {
      setState(() {
        _vscodeSwitch = !_vscodeSwitch;
      });
      if (val) {
        LocalNotification.showNotification(
          index: 1,
          name: 'VSCODE_SHARING',
          title: 'vscode server 开启中.....',
          onlyAlertOnce: true,
          showProgress: true,
          indeterminate: true,
        );

        Process result = await utils
            .runServer(
          codeAddr,
          pwd: _commonModel.codeSrvPwd,
        )
            .catchError((err) {
          showText('开启出现错误');
        });

        result.stdout.transform(utf8.decoder).listen((data) async {
          if (outLocker) {
            LocalNotification.plugin?.cancel(1);
            LocalNotification.showNotification(
              index: 2,
              name: 'VSCODE_RUNNING',
              title: 'vscode server 运行中',
              ongoing: true,
              autoCancel: true,
            );
            bool isWakeEnabled = await Wakelock.enabled;
            if (!isWakeEnabled) {
              Wakelock.enable();
            }
            outLocker = false;
          }
          debugPrint(data);
        });
        result.stderr.transform(utf8.decoder).listen((data) {
          if (data != '') {
            if (errLocker) {
              errLocker = false;
              showText('错误 $data');
              LocalNotification.plugin?.cancel(1);
              Wakelock.disable();
            }
          }
          debugPrint(data);
        });

        await showQrcodeModal(context, 'http://$codeAddr');
      } else {
        await utils.killNodeServer();
        LocalNotification.plugin?.cancel(2);
        showText('vscode 服务已关闭');
        Wakelock.disable();
      }
    } else {
      await showDownloadResourceModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    String internalIp = _commonModel.internalIp;
    String filePort = _commonModel.filePort ?? FILE_DEFAULT_PORT;
    String codeSrvPort = _commonModel.codeSrvPort ?? CODE_SERVER_DEFAULT_PORT;
    String fileAddr = '$internalIp:$filePort';
    String codeAddr = '$internalIp:$codeSrvPort';

    String firstAliveIp =
        // ignore: null_aware_in_logical_operator
        _commonModel.currentConnectIp != null &&
                (_commonModel.socket?.connected != null ||
                    _commonModel.socket?.connected == true)
            ? '${_commonModel.currentConnectIp}:${_commonModel.filePort}'
            : '未连接';

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
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
                          subtitle: LanText(fileAddr, small: true),
                          contentPadding: EdgeInsets.only(left: 15, right: 10),
                          trailing: LanSwitch(
                            value: _shareSwitch,
                            onChanged: (val) async {
                              if (mounted) {
                                setState(() {
                                  _shareSwitch = !_shareSwitch;
                                });
                              }
                              await createStaticServer().catchError(
                                (err) {
                                  recordError(
                                    text: '静态服务出错',
                                    methodName: 'createStaticServer',
                                    exception: err,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        ListTile(
                          title: LanText('Vscode Server'),
                          subtitle: LanText(codeAddr, small: true),
                          contentPadding: EdgeInsets.only(left: 15, right: 10),
                          trailing: LanSwitch(
                            value: _vscodeSwitch,
                            onChanged: (val) async {
                              _openCodeServer(context, val, codeAddr: codeAddr);
                            },
                          ),
                        ),
                        ListTile(
                          title: LanText('内网快递'),
                          subtitle: LanText('$firstAliveIp', small: true),
                          contentPadding: EdgeInsets.only(left: 15, right: 10),
                          trailing: (_commonModel.socket?.connected != null &&
                                  _commonModel.socket.connected == true)
                              ? Container(width: 1, height: 1)
                              : Wrap(
                                  children: [
                                    CupertinoButton(
                                      child: NoResizeText('手动'),
                                      onPressed: () async {
                                        showSingleTextFieldModal(
                                          context,
                                          title: '手动设置IP',
                                          onOk: (val) async {
                                            await _commonModel
                                                .setCurrentConnectIp(val);

                                            SocketConnecter(_commonModel)
                                                .createClient(
                                                    _commonModel
                                                        .currentConnectIp,
                                                    onNotExpected: (val) {
                                              showText(val);
                                            }, onConnected: () {
                                              _commonModel.addToCommonIps(
                                                  _commonModel
                                                      .currentConnectIp);
                                            });
                                          },
                                          onCancel: () {},
                                        );
                                      },
                                    ),
                                    CupertinoButton(
                                      child: NoResizeText('搜索'),
                                      onPressed: () async {
                                        LocalNotification.showNotification(
                                          name: 'SEARCH_DEVICE',
                                          title: '搜寻设备中...',
                                        );

                                        await SocketConnecter
                                            .searchDevicesAndConnect(
                                          context,
                                          themeModel: _themeModel,
                                          initiativeConnect: false,
                                          commonModel: _commonModel,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                        ),
                        // ...[
                        //   CupertinoButton(
                        //     child: Text('测试按钮'),
                        //     onPressed: () async {},
                        //   )
                        // ]
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _commonModel.selectedFiles.isEmpty
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
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _commonModel.selectedFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        SelfFileEntity file =
                            _commonModel.selectedFiles.elementAt(index);

                        Widget previewIcon = getPreviewIcon(context, file);
                        return Dismissible(
                          key: ObjectKey(file),
                          onDismissed: (direction) {
                            _commonModel.removeSelectedFile(file,
                                update: false);
                            if (_commonModel.selectedFiles.isEmpty) {
                              setState(() {});
                            }
                          },
                          child: FileItem(
                            isDir: file.isDir,
                            leading: previewIcon,
                            withAnimation: index < 15,
                            index: index,
                            justDisplay: true,
                            file: file,
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
