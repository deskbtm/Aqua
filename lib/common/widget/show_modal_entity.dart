import 'package:flutter/cupertino.dart';
import 'package:joystick_editor/no_resize_text.dart';
import 'package:lan_file_more/common/widget/checkbox.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/store.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:intent/intent.dart' as intent;
import 'package:intent/action.dart' as action;

Future<void> showUpdateModal(
    BuildContext context, ThemeModel provider, Map data,
    {bool tipRemember = true}) async {
  if (data.isEmpty) {
    return;
  }

  PackageInfo pkgInfo = await PackageInfo.fromPlatform();
  String packageName = pkgInfo.packageName;
  String remoteVersion = data['mobile']['latest']['version'];
  List desc = data['mobile']['latest']['desc'];
  String url = data['mobile']['latest']['url'];
  bool forceUpdate = data['mobile']['latest']['forceUpdate'];

  bool isNotTip = await Store.getBool(REMEMBER_NO_UPDATE_TIP) ?? false;

  if (isNotTip) {
    if (!forceUpdate) {
      /// 强制更新 不显示
      return;
    } else {
      await Store.setBool(REMEMBER_NO_UPDATE_TIP, false);
    }
  }

  String descMsg = desc.map((e) => e + '\n').toList().join('');
  if (Version.parse(remoteVersion) > Version.parse(pkgInfo.version)) {
    bool checked = false;
    await showTipTextModal(
      context,
      provider,
      tip: '发现新版本 v$remoteVersion\n$descMsg',
      title: '更新',
      defaultOkText: '下载',
      defaultCancelText: '应用市场',
      additionList: [
        if (tipRemember)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              StatefulBuilder(builder: (context, changeState) {
                return SizedBox(
                  height: 30,
                  child: LanCheckBox(
                    value: checked,
                    borderColor: provider.themeData.itemFontColor,
                    onChanged: (val) async {
                      await Store.setBool(REMEMBER_NO_UPDATE_TIP, val);
                      changeState(() {
                        checked = val;
                      });
                    },
                  ),
                );
              }),
              NoResizeText(
                '不再提示, 遇到强制更新则提示',
                style: TextStyle(
                  color: provider.themeData.itemFontColor,
                ),
              )
            ],
          ),
      ],
      onCancel: () async {
        intent.Intent()
          ..setAction(action.Action.ACTION_VIEW)
          ..setData(Uri.parse('market://details?id=' + packageName))
          ..startActivity().catchError((e) => print(e));
      },
      onOk: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          BotToast.showText(
            text: '链接打开失败',
          );
        }
      },
    );
  }
}
