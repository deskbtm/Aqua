import 'dart:io';
import 'dart:ui';

import 'package:android_mix/android_mix.dart';
import 'package:aqua/page/file_editor/editor_theme.dart';
import 'package:aqua/page/file_editor/file_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/show_modal.dart';
import 'package:aqua/external/bot_toast/src/toast.dart';
import 'package:aqua/external/webdav/webdav.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/utils/webdav.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'file_utils.dart';

Future<void> uploadToWebDAV(SelfFileEntity file) async {
  Client client = (await WebDavUtils().init()).client;
  String path = file.entity.path;
  await client.mkdir('/lan-file-more');
  await Future.delayed(Duration(milliseconds: 500));
  return client.uploadFile(path, '/lan-file-more/${pathLib.basename(path)}');
}

Future<dynamic> showMoreModal(
  BuildContext context, {
  @required SelfFileEntity file,
}) async {
  MixUtils.safePop(context);
  void showText(String content) {
    BotToast.showText(
      text: content,
    );
  }

  CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  String filesPath = await AndroidMix.storage.getFilesDir;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return SplitSelectionModal(
        // onDispose: () {},
        leftChildren: [
          ActionButton(
            content: AppLocalizations.of(context).copyToSandbox,
            onTap: () async {
              Directory sandbox = Directory('$filesPath/rootfs/root');
              if (sandbox.existsSync()) {
                showText(AppLocalizations.of(context).wait);
                await LanFileUtils.copy(file, sandbox.path);
                showText(AppLocalizations.of(context).setSuccess);
              } else {
                showText(AppLocalizations.of(context).sandboxNotExist);
              }
            },
          ),
          ActionButton(
            content: AppLocalizations.of(context).uploadToWebDAV,
            onTap: () async {
              if (commonModel.webDavAddr == null ||
                  commonModel.webDavPwd == null ||
                  commonModel.webDavUsername == null) {
                showText(AppLocalizations.of(context).uploadToWebDAV);
                return;
              }
              LocalNotification.showNotification(
                index: 1,
                name: 'WEBDAV_UPLOAD',
                title: AppLocalizations.of(context).uploading,
                onlyAlertOnce: true,
                showProgress: true,
                indeterminate: true,
              );
              await uploadToWebDAV(file).catchError((err) {
                LocalNotification.plugin?.cancel(1);
                showText(AppLocalizations.of(context).setFail);
              });
              LocalNotification.plugin?.cancel(1);
              showText(AppLocalizations.of(context).setSuccess);
            },
          ),
        ],
        rightChildren: <Widget>[
          ActionButton(
            content: AppLocalizations.of(context).openEditor,
            onTap: () async {
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
            content:AppLocalizations.of(context).openWith,
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
