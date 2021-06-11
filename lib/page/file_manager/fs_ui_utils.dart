import 'dart:io';

import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:device_info/device_info.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FsUIUtils {
  static handlePermissionErrorOnAndroid() async {
    bool overAndroid11 =
        int.parse((await DeviceInfoPlugin().androidInfo).version.release) >= 11;
  }

  static Future<List<SelfFileEntity>> readdirSafely(
      context, Directory dir) async {
    FileManagerModel model =
        Provider.of<FileManagerModel>(context, listen: false);
    Directory? entryDir = model.entryDir;
    if (entryDir == null || !pathLib.isWithin(entryDir.path, dir.path)) {
      return [];
    }

    SelfFileList? result = await FsUtils.readdir(
      dir,
      sortType: model.sortType,
      showHidden: model.isDisplayHidden,
      reversed: model.sortReversed,
    ).catchError((err) async {
      String errorString = err.toString().toLowerCase();
      print(errorString)
      bool overAndroid11 =
          int.parse((await DeviceInfoPlugin().androidInfo).version.release) >=
              11;

      if (errorString.contains('permission') &&
          errorString.contains('denied')) {
        // showTipTextModal(
        //   context,
        //   title: AppLocalizations.of(context).error,
        //   tip: (overAndroid11)
        //       ? AppLocalizations.of(context).noPermissionO
        //       : AppLocalizations.of(context).noPermission,
        //   onCancel: null,
        // );
      }
    });

    switch (model.showOnlyType) {
      case ShowOnlyType.all:
        return result?.allList ?? [];
      case ShowOnlyType.file:
        return result?.fileList ?? [];
      case ShowOnlyType.folder:
        return result?.folderList ?? [];
      case ShowOnlyType.link:
        return result?.linkList ?? [];
      default:
        return result?.allList ?? [];
    }
  }
}
