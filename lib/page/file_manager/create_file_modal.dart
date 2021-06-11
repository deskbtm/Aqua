import 'dart:io';
import 'dart:ui';
import 'package:aqua/common/widget/aqua_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/dialog.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'fs_utils.dart';

Future<void> createFileModal(
  BuildContext context, {
  required String willCreateDir,
  required Function onExists,
  required Function(String) onSuccess,
  required Function(dynamic) onError,
}) async {
  MixUtils.safePop(context);
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  AquaTheme themeData = themeModel.themeData;
  TextEditingController textEditingController = TextEditingController();

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return AquaDialog(
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: AquaDialogTitle(
                title: AppLocalizations.of(context)!.create,
                subTitle: '${pathLib.basename(willCreateDir)}'),
            action: true,
            children: <Widget>[
              AquaTextField(
                style: TextStyle(textBaseline: TextBaseline.alphabetic),
                controller: textEditingController,
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 30,
                child: Row(children: <Widget>[
                  NoResizeText(
                    AppLocalizations.of(context)!.recursiveCreateFile,
                    style: TextStyle(
                      color: themeData.itemFontColor,
                    ),
                  )
                ]),
              )
            ],
            defaultCancelText: AppLocalizations.of(context)!.createFile,
            defaultOkText: AppLocalizations.of(context)!.createDir,
            onOk: () async {
              Directory newDir = Directory(pathLib.join(willCreateDir,
                  FsUtils.trimSlash(textEditingController.text)));
              if (await newDir.exists()) {
                onExists();
                return;
              }

              await newDir.create(recursive: true).then((value) {
                onSuccess(textEditingController.text);
                MixUtils.safePop(context);
              }).catchError((err) {
                onError(err);
              });
            },
            onCancel: () async {
              File newFile = File(pathLib.join(willCreateDir,
                  FsUtils.trimSlash(textEditingController.text)));
              if (await newFile.exists()) {
                onExists();
                return;
              }

              await newFile.create(recursive: true).then((value) {
                onSuccess(textEditingController.text);
                MixUtils.safePop(context);
              }).catchError((err) {
                onError(err);
              });
            },
          );
        },
      );
    },
  );
}
