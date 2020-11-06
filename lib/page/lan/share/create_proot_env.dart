import 'dart:io';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/external/system_info/system_info.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/lan/code_server/utils.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';

Future<void> createProotEnv(
  BuildContext context, {
  @required ThemeModel themeProvider,
  @required CommonModel commonProvider,
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
                  case 'i686':
                    arch = 'x86_64';
                    break;
                  default:
                }

                String resourceName = 'lan-file-more-$arch.tar.gz';
                String busyboxName = 'busybox-$arch';

                if (MixUtils.isDev) {
                  // resourceUrl = '$DEV_CODE_SERVER_URL/$resourceName';
                  // busyBoxUrl = '$DEV_CODE_SERVER_URL/$busyboxName';
                  Map s = commonProvider.gWebData['sandbox'];
                  Map b = commonProvider.gWebData['busybox'];

                  if (s != null && b != null) {
                    resourceUrl = s[resourceName]['url'];
                    busyBoxUrl = b[busyboxName]['url'];
                  }
                } else {
                  Map s = commonProvider.gWebData['sandbox'];
                  Map b = commonProvider.gWebData['busybox'];
                  if (s != null && b != null) {
                    resourceUrl = s[resourceName]['url'];
                    busyBoxUrl = b[busyboxName]['url'];
                  }
                }

                bool prepared = await cutils
                    .prepareResource(
                        resourceUrl: resourceUrl, busyboxUrl: busyBoxUrl)
                    .catchError((err) {
                  // showText('资源安装出现错误 $err');

                  recordError(
                    methodName: 'prepareResource',
                    text: 'resource',
                  );
                  // MixUtils.safePop(context);
                });

                if (prepared != true) {
                  await cutils.rmAllResource().catchError((err) {
                    recordError(text: 'rm all resource');
                  });
                  showText('资源安装失败 已删除');
                  MixUtils.safePop(context);
                  return;
                }

                ProcessResult ir = await cutils.installNodeJs().catchError(
                  (err) {
                    showText('node 安装失败');
                    recordError(
                        text: 'node 安装失败',
                        exception: err,
                        methodName: 'installNodeJs');
                  },
                );

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
