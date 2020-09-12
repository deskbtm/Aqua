import 'dart:io';
import 'dart:ui';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_express/common/widget/dialog.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/external/system_info/system_info.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'code_server/utils.dart';

Future<void> createProotEnv(
  BuildContext context, {
  @required ThemeProvider themeProvider,
  @required CommonProvider commonProvider,
  @required Function onSuccess,
}) async {
  MixUtils.safePop(context);
  dynamic themeData = themeProvider.themeData;
  bool isInstall = false;
  void showText(String content, {int duration = 4}) {
    BotToast.showText(
        text: content,
        contentColor: themeData?.toastColor,
        duration: Duration(seconds: duration));
  }

  showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return WillPopScope(
            onWillPop: () async {
              return !isInstall;
            },
            child: LanDialog(
              fontColor: themeData.itemFontColor,
              bgColor: themeData.dialogBgColor,
              title: NoResizeText('资源下载'),
              action: true,
              children: <Widget>[
                isInstall
                    ? loadingWithText(context, themeProvider,
                        text: '资源下载中, 请耐心等待')
                    : NoResizeText('未检测收到资源, 是否下载?'),
                SizedBox(height: 10),
              ],
              onOk: () async {
                CodeSrvUtils cutils = await CodeSrvUtils().init();
                if (isInstall) {
                  return;
                }
                changeState(() {
                  isInstall = true;
                });

                String resourceUrl;
                String busyBoxUrl;
                String arch;

                switch (SysInfo.kernelArchitecture) {
                  case 'aarch64':
                    arch = 'aarch64';
                    break;
                  case 'armv71':
                    arch = 'armv7';
                    break;
                  case 'armv51':
                    arch = 'armv7';
                    break;
                  default:
                }

                String resourceName = 'lan-file-more-$arch.tar.gz';
                String busyboxName = 'busybox-$arch';

                if (MixUtils.isDev) {
                  resourceUrl = '$DEV_CODE_SERVER_URL/$resourceName';
                  busyBoxUrl = '$DEV_CODE_SERVER_URL/$busyboxName';
                } else {
                  Map s = commonProvider.gWebData['sandbox'];
                  Map b = commonProvider.gWebData['busybox'];
                  if (s != null && b != null) {
                    resourceUrl = s[resourceName]['url'];
                    busyBoxUrl = b[resourceName]['url'];
                  }
                }

                bool prepared = await cutils
                    .prepareResource(
                        resourceUrl: resourceUrl, busyboxUrl: busyBoxUrl)
                    .catchError((err) {
                  showText('资源安装出现错误 $err');
                  FLog.error(
                    methodName: 'prepareResource',
                    text: 'resource',
                  );
                  // MixUtils.safePop(context);
                });

                if (prepared != true) {
                  await cutils.rmAllResource().catchError((err) {
                    FLog.error(text: 'rm all resource');
                  });
                  showText('资源安装失败 已删除');
                  MixUtils.safePop(context);
                  return;
                }

                ProcessResult ir =
                    await cutils.installNodeJs().catchError((err) {
                  showText('node 安装失败');
                  FLog.error(text: '$err', methodName: 'installNodeJs');
                });

                if (MixUtils.isDev) {
                  print(ir.stdout.toString());
                  print(ir.stderr.toString());
                }

                changeState(() {
                  isInstall = false;
                });
                onSuccess();
                MixUtils.safePop(context);
              },
              onCancel: () {
                MixUtils.safePop(context);
              },
            ),
          );
        },
      );
    },
  );
}
