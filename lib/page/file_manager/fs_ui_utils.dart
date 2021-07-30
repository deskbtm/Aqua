import 'dart:io';

import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/model/select_file_model.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FsUIUtils {
  static handlePermissionErrorOnAndroid(
      BuildContext context, dynamic err) async {
    bool overAndroid11 =
        int.parse((await DeviceInfoPlugin().androidInfo).version.release) >= 11;
    String errorString = err.toString().toLowerCase();
    if (errorString.contains('permission') || errorString.contains('denied')) {
      showTipTextModal(
        context,
        title: S.of(context)!.error,
        tip: (overAndroid11)
            ? S.of(context)!.noPermissionO
            : S.of(context)!.noPermission,
        onCancel: null,
      );
    }
  }

  static Future<List<SelfFileEntity>> readdir(
    context,
    Directory dir,
  ) async {
    FileManagerModel model =
        Provider.of<FileManagerModel>(context, listen: false);
    Directory? entryDir = model.entryDir;
    if (entryDir != null &&
        !pathLib.equals(entryDir.path, dir.path) &&
        !pathLib.isWithin(entryDir.path, dir.path)) {
      return [];
    }

    SelfFileList? result = await FsUtils.readdir(
      dir,
      sortType: model.sortType,
      showHidden: model.isDisplayHidden,
      reversed: model.sortReversed,
    ).catchError((err) {
      handlePermissionErrorOnAndroid(context, err);
      throw Exception(err);
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

  static handleHozDragItem(
      BuildContext context, SelfFileEntity file, double dir) async {
    SelectFileModel model =
        Provider.of<SelectFileModel>(context, listen: false);

    if (dir == 1) {
      await model.addSelectedFile(file, update: true);
    } else if (dir == -1) {
      await model.removeSelectedFile(file, update: true);
    }
  }
}
