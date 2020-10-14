import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';
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
import 'package:lan_express/model/common_model.dart';
import 'package:lan_express/model/theme_model.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/notification.dart';
import 'package:lan_express/web/web_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:shelf_body_parser/shelf_body_parser.dart';

class StaticSharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StaticSharePageState();
  }
}

void isolateAirDrop(List msg) async {
  // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
  // ReceivePort recPort = ReceivePort();
  SendPort sendPort = msg[0];

  // String port = data['port'],
  // ip = data['ip'],
  // filename = data['filename'],
  // filepath = data['filepath'];

  Timer(Duration(seconds: 1), () {
    sendPort.send("demo");
  });
  Timer(Duration(seconds: 2), () {
    sendPort.send("demo1");
  });
  Timer(Duration(seconds: 3), () {
    sendPort.send("demo2");
  });
}

class _StaticSharePageState extends State<StaticSharePage> {
  ThemeModel _themeModel;

  CommonModel _commonModel;
  HttpServer _server;
  bool _shareSwitch;
  bool _vscdeSwitch;
  bool _mutex;

  @override
  void initState() {
    super.initState();
    _mutex = true;
    _shareSwitch = false;
    _vscdeSwitch = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);

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
      String ip = _commonModel?.internalIp;

      if (ip == null) {
        showText('请先连接局域网(wifi)');
        return;
      }

      int port = int.parse(_commonModel?.filePort ?? '20201');
      String savePath = _commonModel?.staticUploadSavePath;
      FutureOr<Response> Function(Request) handlerFunc;

      if (_commonModel.selectedFiles.isNotEmpty) {
        SelfFileEntity first = _commonModel.selectedFiles.first;

        if (first.isDir) {
          handlerFunc = createWebHandler(
            first.entity.path,
            isDark: _themeModel.isDark,
            uploadSavePath: savePath,
            serverUrl: '$ip:$port',
            onUploadResult: _uploadNotification,
          );
        } else {
          handlerFunc = createFilesHandler(
            _commonModel.selectedFiles.map((e) => e.entity.path).toList(),
            isDark: _themeModel.isDark,
            serverUrl: '$ip:$port',
            uploadSavePath: savePath,
            onUploadResult: _uploadNotification,
          );
        }
      } else {
        handlerFunc = createWebHandler(
          _commonModel.storageRootPath,
          isDark: _themeModel.isDark,
          serverUrl: '$ip:$port',
          uploadSavePath: savePath,
          onUploadResult: _uploadNotification,
        );
      }

      var handler = const Pipeline()
          .addMiddleware(bodyParser(storeOriginalBuffer: false))
          .addHandler(handlerFunc);

      if (_shareSwitch) {
        _server = await shelf.serve(handler, ip, port, shared: true);
        LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_SHARING',
            title: '静态文件共享中.....',
            ongoing: true);
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
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    String internalIp = _commonModel.internalIp;
    String filePort = _commonModel.filePort;
    String codeSrvPort = _commonModel.codeSrvPort;
    String fileAddr = internalIp == null ? '未连接局域网' : '$internalIp:$filePort';
    String codeAddr =
        internalIp == null ? '未连接局域网' : '$internalIp:$codeSrvPort';
    // String codeSrvIp = _commonModel.codeSrvIp;

    String firstAliveIp =
        // ignore: null_aware_in_logical_operator
        _commonModel.currentConnectIp != null &&
                (_commonModel.socket?.connected != null ||
                    _commonModel.socket?.connected == true)
            ? '${_commonModel.currentConnectIp}:${_commonModel.filePort}'
            : '暂未连接';

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
                              await createStaticServer().catchError((err) {
                                FLog.error(
                                  text: '静态服务出错',
                                  methodName: 'createStaticServer',
                                  exception: err,
                                );
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: LanText('Vscode Server'),
                          subtitle: LanText(codeAddr, small: true),
                          contentPadding: EdgeInsets.only(left: 15, right: 10),
                          trailing: LanSwitch(
                            value: _vscdeSwitch,
                            onChanged: (val) async {
                              CodeSrvUtils utils = await CodeSrvUtils().init();
                              bool outLocker = true;
                              bool errLocker = true;
                              if (!_commonModel.isPurchased) {
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
                                    pwd: _commonModel.codeSrvPwd,
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
                          trailing: (_commonModel.socket?.connected != null &&
                                  _commonModel.socket.connected == true)
                              ? Container(width: 1, height: 1)
                              : CupertinoButton(
                                  child: NoResizeText('连接'),
                                  onPressed: () async {
                                    LocalNotification.showNotification(
                                        name: 'SEARCH_DEVICE',
                                        title: '搜寻设备中...');
                                    await SocketConnecter(_commonModel)
                                        .searchDevicesAndConnect(
                                      context,
                                      themeProvider: _themeModel,
                                      initiativeConnect: false,
                                    );
                                  },
                                ),
                        ),
                        CupertinoButton(
                          child: Text('click'),
                          onPressed: () async {
                            // final List<AssetEntity> assets =
                            //     await AssetPicker.pickAssets(context);
                            // print(assets);
                            // String a = await (Connectivity().getWifiIP());
                            // print(a);
                            // Uint8List a = await PhotoManager.getThumbnailByPath(
                            //   width: 100,
                            //   height: 100,
                            //   path: '/sdcard/1.png',
                            //   quality: 60,
                            // );

                            // print(a.length);
                            // setState(() {
                            //   img = a;
                            // });
                            // List<AssetPathEntity> list =
                            //     await PhotoManager.getAssetPathList();
                            // print(list);
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            if (img != null)
              Expanded(
                child: Container(
                  color: Colors.red,
                  child: Image.memory(
                    img,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
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

                        Widget previewIcon =
                            getPreviewIconSync(context, _themeModel, file);
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
          ],
        ),
      ),
    );
  }

  Uint8List img;
}
