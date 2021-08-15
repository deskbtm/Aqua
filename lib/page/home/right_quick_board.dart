import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:aqua/common/theme.dart';
import 'package:aqua/model/select_file_model.dart';
import 'package:aqua/page/lan/static_fs/body_parser/src/shelf_body_parser.dart';
import 'package:aqua/page/lan/static_fs/web_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/page/lan/create_proot_env.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:aqua/common/widget/images.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/switch.dart';

import 'package:aqua/page/file_manager/file_list_tile.dart';
import 'package:aqua/page/lan/code_server/utils.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:wakelock/wakelock.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RightQuickBoard extends StatefulWidget {
  RightQuickBoard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RightQuickBoardState();
  }
}

class RightQuickBoardState extends State<RightQuickBoard>
    with AutomaticKeepAliveClientMixin {
  late ThemeModel _tm;
  late GlobalModel _gm;
  late SelectFileModel _sfm;

  HttpServer? _server;
  late bool _shareSwitch;
  late bool _vscodeSwitch;

  @override
  void initState() {
    super.initState();
    _shareSwitch = false;
    _vscodeSwitch = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _gm = Provider.of<GlobalModel>(context);
    _sfm = Provider.of<SelectFileModel>(context);
  }

  Future<void> showDownloadResourceModal(BuildContext context) async {
    await createProotEnv(
      context,
      themeProvider: _tm,
      commonProvider: _gm,
      onSuccess: () {
        Fluttertoast.showToast(msg: S.of(context)!.installSuccess);
        MixUtils.safePop(context);
      },
    );
  }

  void _uploadNotification(bool result) {
    result
        ? LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: S.of(context)!.receiveFileSuccess,
            autoCancel: true,
          )
        : LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: S.of(context)!.receiveFileFail,
            autoCancel: true,
          );
  }

  Future<void> createStaticServer() async {
    try {
      String ip = _gm.internalIp ?? LOOPBACK_ADDR;

      int port = int.parse(_gm.filePort ?? FILE_DEFAULT_PORT);
      String? savePath = _gm.staticUploadSavePath;
      FutureOr<Response> Function(Request) handlerFunc;
      String addr = '$ip:$port';

      if (_sfm.selectedFiles.isNotEmpty) {
        SelfFileEntity first = _sfm.selectedFiles.first;

        if (first.isDir) {
          handlerFunc = createDirHandler(
            first.entity.path,
            isDark: _tm.isDark,
            uploadSavePath: '/',
            serverUrl: addr,
            onUploadResult: _uploadNotification,
          );
        } else {
          handlerFunc = createFilesHandler(
            _sfm.selectedFiles.map((e) => e.entity.path).toList(),
            isDark: _tm.isDark,
            serverUrl: addr,
            uploadSavePath: '/',
            onUploadResult: _uploadNotification,
          );
        }
      } else {
        handlerFunc = createDirHandler(
          _gm.storageRootPath,
          isDark: _tm.isDark,
          serverUrl: addr,
          uploadSavePath: '/',
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
          title: S.of(context)!.shareFile,
          ongoing: true,
          autoCancel: true,
        );
        debugPrint(
            'Serving at http://${_server?.address.host}:${_server?.port}');

        // 保持唤醒状态
        bool isWakeEnabled = await Wakelock.enabled;

        if (!isWakeEnabled) {
          Wakelock.enable();
        }

        await showQrcodeModal(context, 'http://$addr',
            title: S.of(context)!.searchQr);
      } else {
        _server?.close();
        Fluttertoast.showToast(msg: S.of(context)!.shareClose);
        LocalNotification.plugin?.cancel(0);
        Wakelock.disable();
      }
    } catch (err) {
      throw Exception(err);
    }
  }

  Future<void> _openCodeServer(
      BuildContext context, bool switchValue, String codeAddr) async {
    CodeSrvUtils utils = await CodeSrvUtils().init();
    bool outLocker = true;
    bool errLocker = true;

    if (await utils.existsAllResource()) {
      setState(() {
        _vscodeSwitch = !_vscodeSwitch;
      });
      if (switchValue) {
        LocalNotification.showNotification(
          index: 1,
          name: 'VSCODE_SHARING',
          title: 'vscode server ${S.of(context)!.starting}',
          onlyAlertOnce: true,
          showProgress: true,
          indeterminate: true,
        );

        Process result = await utils
            .runServer(
          codeAddr,
          pwd: _gm.codeSrvPwd,
        )
            .catchError((err) {
          Fluttertoast.showToast(msg: S.of(context)!.setFail);
        });

        result.stdout.transform(utf8.decoder).listen((data) async {
          if (outLocker) {
            LocalNotification.plugin?.cancel(1);
            LocalNotification.showNotification(
              index: 2,
              name: 'VSCODE_RUNNING',
              title: 'vscode server ${S.of(context)!.running}',
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
              Fluttertoast.showToast(msg: '${S.of(context)!.setFail} $data');
              LocalNotification.plugin?.cancel(1);
              Wakelock.disable();
            }
          }
          debugPrint(data);
        });

        await showQrcodeModal(context, 'http://$codeAddr',
            title: S.of(context)!.searchQr);
      } else {
        await utils.killNodeServer();
        LocalNotification.plugin?.cancel(2);
        Fluttertoast.showToast(msg: 'vscode ${S.of(context)!.closed}');
        Wakelock.disable();
      }
    } else {
      await showDownloadResourceModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    log('right quick board painting', name: 'Paint');

    AquaTheme themeData = _tm.themeData;

    String? internalIp = _gm.internalIp;
    String filePort = _gm.filePort ?? FILE_DEFAULT_PORT;
    String codeSrvPort = _gm.codeSrvPort ?? CODE_SERVER_DEFAULT_PORT;
    String fileAddr = '$internalIp:$filePort';
    String codeAddr = '$internalIp:$codeSrvPort';

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    title: ThemedText(S.of(context)!.staticServer),
                    subtitle: ThemedText(fileAddr, small: true),
                    contentPadding: EdgeInsets.only(left: 15, right: 10),
                    trailing: AquaSwitch(
                      value: _shareSwitch,
                      onChanged: (val) async {
                        if (mounted) {
                          setState(() {
                            _shareSwitch = !_shareSwitch;
                          });
                        }
                        await createStaticServer().catchError(
                          (err) {},
                        );
                      },
                      thumbColor: null,
                    ),
                  ),
                  ListTile(
                    title: ThemedText('Vscode Server'),
                    subtitle: ThemedText(codeAddr, small: true),
                    contentPadding: EdgeInsets.only(left: 15, right: 10),
                    trailing: AquaSwitch(
                      value: _vscodeSwitch,
                      onChanged: (val) async {
                        _openCodeServer(context, val, codeAddr);
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _sfm.selectedFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share,
                            size: 57,
                          ),
                          SizedBox(height: 20),
                          ThemedText(S.of(context)!.shareTip,
                              alignX: 0, fontSize: 14)
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _sfm.selectedFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        SelfFileEntity file =
                            _sfm.selectedFiles.elementAt(index);

                        Widget previewIcon = getPreviewIcon(context, file);
                        return Dismissible(
                          key: ObjectKey(file),
                          onDismissed: (direction) async {
                            await _sfm.removeSelectedFile(file, update: true);
                          },
                          child: SimpleFileListTile(
                            title: file.filename,
                            subTitle: file.humanModified,
                            leadingTitle: file.humanSize,
                            leading: previewIcon,
                            justDisplay: true,
                            backgroundColor: themeData.listTileColor,
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
