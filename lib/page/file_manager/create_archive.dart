import 'dart:io';
import 'dart:ui';
import 'package:android_mix/android_mix.dart';
import 'package:android_mix/archive/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/external/menu/menu.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:path/path.dart' as pathLib;

Future<void> createArchiveModal(
  BuildContext context, {
  @required CommonModel commonProvider,
  @required ThemeModel themeProvider,
  @required Directory currentDir,
  @required Function(BuildContext) onSuccessUpdate,
}) async {
  MixUtils.safePop(context);
  if (commonProvider.selectedFiles.isNotEmpty) {
    dynamic themeData = themeProvider.themeData;
    bool popAble = true;
    String archiveType = 'zip';
    String archiveText = 'zip';
    bool preDisplay = false;
    String pwd;

    void showText(String content) {
      BotToast.showText(text: content);
    }

    Future<void> runAfterArchive(BuildContext context, bool result) async {
      if (result) {
        showText('归档成功');
      } else {
        showText('归档失败');
      }
      await onSuccessUpdate(context);
    }

    showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) changeState) {
            return WillPopScope(
              onWillPop: () async {
                return popAble;
              },
              child: LanDialog(
                display: preDisplay,
                fontColor: themeData?.itemFontColor,
                bgColor: themeData?.dialogBgColor,
                title: NoResizeText('归档'),
                action: true,
                children: <Widget>[
                  SizedBox(height: 10),
                  popAble
                      ? FocusedMenuHolder(
                          menuWidth: MediaQuery.of(context).size.width * 0.4,
                          blurSize: 5.0,
                          menuItemExtent: 45,
                          duration: Duration(milliseconds: 100),
                          animateMenuItems: true,
                          maskColor: Color(0x00FFFFFF),
                          menuOffset: 10.0,
                          bottomOffsetHeight: 80.0,
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('zip'),
                              onPressed: () {
                                changeState(() {
                                  archiveText = 'zip';
                                  archiveType = 'zip';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('zip 加密'),
                              onPressed: () async {
                                changeState(() {
                                  preDisplay = true;
                                });

                                await showSingleTextFieldModal(
                                  context,
                                  themeProvider,
                                  title: '输入密码',
                                  transparent: true,
                                  onOk: (val) async {
                                    changeState(() {
                                      archiveText = 'zip 加密';
                                      archiveType = 'zip';
                                      pwd = val;
                                      preDisplay = false;
                                    });
                                  },
                                  onCancel: () {
                                    MixUtils.safePop(context);
                                  },
                                );
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('tar'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar';
                                  archiveType = 'tar';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('tar.gz'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar.gz';
                                  archiveType = 'tar.gz';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('tar.bz2'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar.bz2';
                                  archiveType = 'tar.bz2';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('tar.xz'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar.xz';
                                  archiveType = 'tar.xz';
                                });
                              },
                            ),
                            // FocusedMenuItem(
                            //   backgroundColor: themeData?.menuItemColor,
                            //   title: LanText('7z'),
                            //   onPressed: () async {
                            //     changeState(() {
                            //       archiveText = '7z';
                            //       archiveType = '7z';
                            //     });
                            //   },
                            // ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText('jar'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'jar';
                                  archiveType = 'jar';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData?.menuItemColor,
                              title: LanText(
                                '取消',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              trailingIcon: Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              onPressed: () {
                                MixUtils.safePop(context);
                              },
                            ),
                          ],
                          child: Container(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                NoResizeText(
                                  archiveText,
                                  style: TextStyle(color: Color(0xFF007AFF)),
                                ),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        )
                      : loadingIndicator(context, themeProvider),
                  SizedBox(height: 10),
                ],
                defaultOkText: '确定',
                defaultCancelText: popAble ? '取消' : '后台',
                onOk: () async {
                  if (!popAble) {
                    return;
                  }
                  changeState(() {
                    popAble = false;
                  });
                  await Future.delayed(Duration(milliseconds: 50));
                  List<String> paths = commonProvider.selectedFiles
                      .map((e) => e.entity.path)
                      .toList();

                  String generatedArchivePath = FileAction.newPathWhenExists(
                      pathLib.join(
                        currentDir.path,
                        FileAction.getArchiveName(paths, currentDir.path),
                      ),
                      '.' + archiveType);

                  if (archiveType == 'zip') {
                    bool result = await AndroidMix.archive
                        .zip(paths, generatedArchivePath,
                            pwd: pwd?.trim(), encrypt: ZipEncryptionMethod.aes)
                        .catchError((err) {
                      recordError(
                        text: '',
                        exception: err,
                        methodName: 'archiveModal',
                      );
                    });
                    await runAfterArchive(context, result);
                  } else {
                    ArchiveFormat type;
                    CompressionType cType;

                    switch (archiveType) {
                      case 'tar':
                        type = ArchiveFormat.tar;
                        cType = null;
                        break;
                      case 'tar.gz':
                        type = ArchiveFormat.tar;
                        cType = CompressionType.gzip;
                        break;
                      case 'tar.bz2':
                        type = ArchiveFormat.tar;
                        cType = CompressionType.bzip2;
                        break;
                      case 'tar.xz':
                        type = ArchiveFormat.tar;
                        cType = CompressionType.xz;
                        break;
                      case 'jar':
                        type = ArchiveFormat.jar;
                        cType = null;
                        break;
                    }

                    try {
                      bool result = await AndroidMix.archive
                          .createArchive(
                        paths,
                        currentDir.path,
                        FileAction.getName(generatedArchivePath),
                        type,
                        compressionType: cType,
                      )
                          .catchError((err) {
                        recordError(
                            text: '',
                            exception: err,
                            methodName: 'archiveModal');
                      });

                      await runAfterArchive(context, result);
                    } catch (err) {}
                  }
                },
                onCancel: () {
                  MixUtils.safePop(context);
                },
                actionPos: MainAxisAlignment.end,
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> showWaitForArchiveNotification(String val) async {
  await LocalNotification.showNotification(
    id: ARCHIVE_CHANNEL,
    index: 0,
    name: 'extract_archive',
    title: val,
    onlyAlertOnce: true,
    ongoing: true,
    showProgress: true,
    indeterminate: true,
  );
}
