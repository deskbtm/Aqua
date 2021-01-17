import 'dart:io';
import 'dart:ui';

import 'package:android_mix/android_mix.dart';
import 'package:file_editor/editor_theme.dart';
import 'package:file_editor/file_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/external/webdav/webdav.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/utils/webdav.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as pathLib;

Future<void> uploadToWebDAV(SelfFileEntity file) async {
  Client client = (await WebDavUtils().init()).client;
  String path = file.entity.path;
  await client.mkdir('/lan-file-more');
  await Future.delayed(Duration(milliseconds: 500));
  return client.uploadFile(path, '/lan-file-more/${pathLib.basename(path)}');
}

Future<dynamic> showMoreModal(
  BuildContext context, {
  @required ThemeModel themeModel,
  @required CommonModel commonProvider,
  @required SelfFileEntity file,
}) async {
  MixUtils.safePop(context);
  void showText(String content) {
    BotToast.showText(
      text: content,
    );
  }

  String filesPath = await AndroidMix.storage.getFilesDir;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return SplitSelectionModal(
        // onDispose: () {},
        leftChildren: [
          ActionButton(
            content: '复制至沙盒',
            onTap: () async {
              Directory sandbox = Directory('$filesPath/rootfs/root');
              if (sandbox.existsSync()) {
                showText('复制中, 请等待');
                await FileAction.copy(file, sandbox.path);
                showText('复制完成');
              } else {
                showText('沙盒不存在');
              }
            },
          ),
          ActionButton(
            content: '上传WebDAV',
            onTap: () async {
              if (commonProvider.webDavAddr == null ||
                  commonProvider.webDavPwd == null ||
                  commonProvider.webDavUsername == null) {
                showText('请先设置WebDAV');
                return;
              }
              LocalNotification.showNotification(
                index: 1,
                name: 'WEBDAV_UPLOAD',
                title: '文件上传中.....',
                onlyAlertOnce: true,
                showProgress: true,
                indeterminate: true,
              );
              await uploadToWebDAV(file).catchError((err) {
                LocalNotification.plugin?.cancel(1);
                showText('上传失败');
                recordError(text: 'webdav上床失败');
              });
              LocalNotification.plugin?.cancel(1);
              showText('上传成功');
            },
          ),
        ],
        rightChildren: <Widget>[
          ActionButton(
            content: '编辑器打开',
            onTap: () async {
              // MixUtils.safePop(context);
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(builder: (BuildContext context) {
                  return FileEditorPage(
                    path: file.entity.path,
                    language: file.ext.replaceFirst(RegExp(r'.'), ''),
                    bottomNavColor: themeModel.themeData?.bottomNavColor,
                    dialogBgColor: themeModel.themeData?.dialogBgColor,
                    backgroundColor:
                        themeModel.themeData?.scaffoldBackgroundColor,
                    fontColor: themeModel.themeData?.itemFontColor,
                    selectItemColor: themeModel.themeData?.itemColor,
                    popMenuColor: themeModel.themeData?.menuItemColor,
                    highlightTheme: setEditorTheme(
                      themeModel.isDark,
                      TextStyle(
                        color: themeModel.themeData?.itemFontColor,
                        backgroundColor:
                            themeModel.themeData?.scaffoldBackgroundColor,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          ActionButton(
            content: '打开方式',
            onTap: () async {
              try {
                OpenFile.open(file.entity.path);
              } catch (e) {}
            },
          ),
        ],
      );
    },
  );
}
