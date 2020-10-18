import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lan_express/common/widget/dialog.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/common/widget/text_field.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/model/theme_model.dart';
import 'package:lan_express/utils/mix_utils.dart';

Future<void> createRenameModal(
  BuildContext context,
  SelfFileEntity file, {
  @required ThemeModel provider,
  @required VoidCallback onExists,
  @required Function(String) onSuccess,
  @required Function(dynamic) onError,
}) async {
  MixUtils.safePop(context);
  dynamic themeData = provider.themeData;
  TextEditingController textEditingController = TextEditingController();

  showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return LanDialog(
        fontColor: themeData.itemFontColor,
        bgColor: themeData.dialogBgColor,
        title: NoResizeText('重命名'),
        action: true,
        children: <Widget>[
          LanTextField(
            controller: textEditingController,
            placeholder: '${file.filename}',
          ),
          SizedBox(height: 10),
        ],
        onOk: () async {
          String newPath = FileAction.renameNewPath(
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
