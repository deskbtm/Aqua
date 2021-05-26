import 'dart:io';
import 'dart:ui';

import 'package:aqua/common/widget/aqua_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:aqua/common/widget/dialog.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'file_utils.dart';

Future<void> createRenameModal(
  BuildContext context,
  SelfFileEntity file, {
  required VoidCallback onExists,
  required Function(String) onSuccess,
  required Function(dynamic) onError,
}) async {
  MixUtils.safePop(context);
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  AquaTheme themeData = themeModel.themeData;
  TextEditingController textEditingController = TextEditingController();

  showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return AquaDialog(
        fontColor: themeData.itemFontColor,
        bgColor: themeData.dialogBgColor,
        title: NoResizeText(AppLocalizations.of(context)!.rename),
        action: true,
        children: <Widget>[
          AquaTextField(
            style: TextStyle(textBaseline: TextBaseline.alphabetic),
            controller: textEditingController,
            placeholder: '${file.filename}',
          ),
          SizedBox(height: 10),
        ],
        onOk: () async {
          String newPath = FsUtils.renameNewPath(
              file.entity.path, textEditingController.text);
          if (await File(newPath).exists() ||
              await Directory(newPath).exists()) {
            onExists();
            return;
          }

          await file.entity.rename(newPath).then((value) async {
            onSuccess(textEditingController.text);
            MixUtils.safePop(context);
          }).catchError((err) {
            onError(err);
          });
        },
        onCancel: () {
          MixUtils.safePop(context);
        },
      );
    },
  );
}
