import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:aqua/common/theme.dart';
import 'package:aqua/model/file_model.dart';
import 'package:aqua/page/lan/static_fs/web_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
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

import 'static_fs/body_parser/src/shelf_body_parser.dart';

class LanSharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanSharePageState();
  }
}

class _LanSharePageState extends State<LanSharePage>
    with AutomaticKeepAliveClientMixin {
  late ThemeModel _themeModel;
  late GlobalModel _globalModel;
  late FileModel _fileModel;
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
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);
    _fileModel = Provider.of<FileModel>(context);
  }

  Future<void> showDownloadResourceModal(BuildContext context) async {
    await createProotEnv(
      context,
      themeProvider: _themeModel,
      commonProvider: _globalModel,
      onSuccess: () {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.installSuccess);
        MixUtils.safePop(context);
      },
    );
  }

  void _uploadNotification(bool result) {
    result
        ? LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: AppLocalizations.of(context)!.receiveFileSuccess,
            autoCancel: true,
          )
        : LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: AppLocalizations.of(context)!.receiveFileFail,
            autoCancel: true,
          );
  }

  Future<void> createStaticServer() async {
    try {
      String ip = _globalModel.internalIp ?? LOOPBACK_ADDR;

      int port = int.parse(_globalModel.filePort ?? FILE_DEFAULT_PORT);
      String? savePath = _globalModel.staticUploadSavePath;
      FutureOr<Response> Function(Request) handlerFunc;
      String addr = '$ip:$port';

      if (_fileModel.selectedFiles.isNotEmpty) {
        SelfFileEntity first = _fileModel.selectedFiles.first;

        if (first.isDir) {
          handlerFunc = createDirHandler(
            first.entity.path,
            isDark: _themeModel.isDark,
            uploadSavePath: savePath,
            serverUrl: addr,
            onUploadResult: _uploadNotification,
          );
        } else {
          handlerFunc = createFilesHandler(
            _fileModel.selectedFiles.map((e) => e.entity.path).toList(),
            isDark: _themeModel.isDark,
            serverUrl: addr,
            uploadSavePath: savePath,
            onUploadResult: _uploadNotification,
          );
        }
      } else {
        handlerFunc = createDirHandler(
          _globalModel.storageRootPath,
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
          title: AppLocalizations.of(context)!.shareFile,
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
            title: AppLocalizations.of(context)!.searchQr);
      } else {
        _server?.close();
        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.shareClose);
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
          title: 'vscode server ${AppLocalizations.of(context)!.starting}',
          onlyAlertOnce: true,
          showProgress: true,
          indeterminate: true,
        );

        Process result = await utils
            .runServer(
          codeAddr,
          pwd: _globalModel.codeSrvPwd,
        )
            .catchError((err) {
          Fluttertoast.showToast(msg: AppLocalizations.of(context)!.setFail);
        });

        result.stdout.transform(utf8.decoder).listen((data) async {
          if (outLocker) {
            LocalNotification.plugin?.cancel(1);
            LocalNotification.showNotification(
              index: 2,
              name: 'VSCODE_RUNNING',
              title: 'vscode server ${AppLocalizations.of(context)!.running}',
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
              Fluttertoast.showToast(
                  msg: '${AppLocalizations.of(context)!.setFail} $data');
              LocalNotification.plugin?.cancel(1);
              Wakelock.disable();
            }
          }
          debugPrint(data);
        });

        await showQrcodeModal(context, 'http://$codeAddr',
            title: AppLocalizations.of(context)!.searchQr);
      } else {
        await utils.killNodeServer();
        LocalNotification.plugin?.cancel(2);
        Fluttertoast.showToast(
            msg: 'vscode ${AppLocalizations.of(context)!.closed}');
        Wakelock.disable();
      }
    } else {
      await showDownloadResourceModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    AquaTheme themeData = _themeModel.themeData;

    String? internalIp = _globalModel.internalIp;
    String filePort = _globalModel.filePort ?? FILE_DEFAULT_PORT;
    String codeSrvPort = _globalModel.codeSrvPort ?? CODE_SERVER_DEFAULT_PORT;
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
                    title:
                        ThemedText(AppLocalizations.of(context)!.staticServer),
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
              child: _fileModel.selectedFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share,
                            size: 57,
                          ),
                          SizedBox(height: 20),
                          ThemedText(AppLocalizations.of(context)!.shareTip,
                              alignX: 0, fontSize: 14)
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _fileModel.selectedFiles.length,
                      itemBuilder: (BuildContext context, int index) {
                        SelfFileEntity file =
                            _fileModel.selectedFiles.elementAt(index);

                        Widget previewIcon = getPreviewIcon(context, file);
                        return Dismissible(
                          key: ObjectKey(file),
                          onDismissed: (direction) async {
                            await _fileModel.removeSelectedFile(file,
                                update: true);
                            if (_fileModel.selectedFiles.isEmpty) {
                              setState(() {});
                            }
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
