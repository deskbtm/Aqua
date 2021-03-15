import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/show_modal.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/page/lan/share/create_proot_env.dart';
import 'package:aqua/web/body_parser/src/shelf_body_parser.dart';
import 'package:provider/provider.dart';
import 'package:aqua/common/widget/images.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/switch.dart';
import 'package:aqua/external/bot_toast/src/toast.dart';
import 'package:aqua/page/file_manager/file_item.dart';
import 'package:aqua/page/lan/code_server/utils.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/web/web_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:wakelock/wakelock.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        showText(AppLocalizations.of(context).installSuccess);
        MixUtils.safePop(context);
      },
    );
  }

  void _uploadNotification(bool result) {
    result
        ? LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: AppLocalizations.of(context).receiveFileSuccess,
            autoCancel: true,
          )
        : LocalNotification.showNotification(
            index: 0,
            name: 'STATIC_UPLOAD',
            title: AppLocalizations.of(context).receiveFileFail,
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
          title: AppLocalizations.of(context).shareFile,
          ongoing: true,
          autoCancel: true,
        );
        debugPrint('Serving at http://${_server.address.host}:${_server.port}');

        // 保持唤醒状态
        bool isWakeEnabled = await Wakelock.enabled;

        if (!isWakeEnabled) {
          Wakelock.enable();
        }

        await showQrcodeModal(context, 'http://$addr',
            title: AppLocalizations.of(context).searchQr);
      } else {
        _server?.close();
        showText(AppLocalizations.of(context).shareClose);
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
          title: 'vscode server ${AppLocalizations.of(context).starting}',
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
          showText(AppLocalizations.of(context).setFail);
        });

        result.stdout.transform(utf8.decoder).listen((data) async {
          if (outLocker) {
            LocalNotification.plugin?.cancel(1);
            LocalNotification.showNotification(
              index: 2,
              name: 'VSCODE_RUNNING',
              title: 'vscode server ${AppLocalizations.of(context).running}',
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
              showText('${AppLocalizations.of(context).setFail} $data');
              LocalNotification.plugin?.cancel(1);
              Wakelock.disable();
            }
          }
          debugPrint(data);
        });

        await showQrcodeModal(context, 'http://$codeAddr',
            title: AppLocalizations.of(context).searchQr);
      } else {
        await utils.killNodeServer();
        LocalNotification.plugin?.cancel(2);
        showText('vscode ${AppLocalizations.of(context).closed}');
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

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Column(
              children: [
                ListTile(
                  title: LanText(AppLocalizations.of(context).staticServer),
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
                        (err) {},
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
                SizedBox(height: 40),
              ],
            ),
            Expanded(
              flex: 1,
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
                          LanText(AppLocalizations.of(context).shareTip,
                              alignX: 0, fontSize: 14)
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
