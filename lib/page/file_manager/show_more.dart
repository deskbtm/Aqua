import 'dart:io';
import 'dart:ui';
import 'package:aqua/common/theme.dart';
import 'package:aqua/page/file_editor/editor_theme.dart';
import 'package:aqua/page/file_editor/file_editor.dart';
import 'package:aqua/plugin/storage/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';

import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/utils/webdav.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'file_utils.dart';

Future<dynamic> showMoreModal(
  BuildContext context, {
  required SelfFileEntity file,
}) async {
  MixUtils.safePop(context);
  WebDavUtils utils = WebDavUtils();

  CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  AquaTheme theme = themeModel.themeData;
  String? filesPath = await ExtraStorage.getFilesDir;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return SplitSelectionModal(
        // onDispose: () {},
        leftChildren: [
          ActionButton(
            content: AppLocalizations.of(context)!.copyToSandbox,
            onTap: () async {
              Directory sandbox = Directory('$filesPath/rootfs/root');
              if (sandbox.existsSync()) {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.wait,
                );
                await FsUtils.copy(file, sandbox.path);
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.setSuccess,
                );
              } else {
                Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.sandboxNotExist,
                );
              }
            },
          ),
          ActionButton(
            content: AppLocalizations.of(context)!.uploadToWebDAV,
            onTap: () async {
              if (commonModel.webDavAddr == null ||
                  commonModel.webDavPwd == null ||
                  commonModel.webDavUsername == null) {
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.uploadToWebDAV);
                return;
              }
              LocalNotification.showNotification(
                index: 1,
                name: 'WEBDAV_UPLOAD',
                title: AppLocalizations.of(context)!.uploading,
                onlyAlertOnce: true,
                showProgress: true,
                indeterminate: true,
              );
              await utils.uploadToWebDAV(file).catchError((err) {
                LocalNotification.plugin?.cancel(1);
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.setFail);
              });
              LocalNotification.plugin?.cancel(1);
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.setSuccess);
            },
          ),
        ],
        rightChildren: <Widget>[
          ActionButton(
            content: AppLocalizations.of(context)!.openEditor,
            onTap: () async {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(builder: (BuildContext context) {
                  return FileEditorPage(
                    path: file.entity.path,
                    language: file.ext.replaceFirst(RegExp(r'.'), ''),
                    bottomNavColor: theme.bottomNavColor,
                    // dialogBgColor: theme.dialogBgColor,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    fontColor: theme.itemFontColor,
                    selectItemColor: theme.itemColor,
                    popMenuColor: theme.menuItemColor,
                    highlightTheme: setEditorTheme(
                      themeModel.isDark,
                      TextStyle(
                        color: theme.itemFontColor,
                        backgroundColor: theme.scaffoldBackgroundColor,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          ActionButton(
            content: AppLocalizations.of(context)!.openWith,
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
