import 'dart:io';
import 'dart:ui';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/plugin/archive/archive.dart';
import 'package:aqua/plugin/archive/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/dialog.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';

import 'package:aqua/external/menu/menu.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/common/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'file_utils.dart';

Future<void> createArchiveModal(
  BuildContext context, {
  Directory? currentDir,
  required Function(BuildContext) onSuccessUpdate,
}) async {
  MixUtils.safePop(context);
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  GlobalModel globalModel = Provider.of<GlobalModel>(context, listen: false);

  if (globalModel.selectedFiles.isNotEmpty) {
    AquaTheme themeData = themeModel.themeData;
    bool popAble = true;
    String archiveType = 'zip';
    String archiveText = 'zip';
    bool preDisplay = false;
    late String pwd;

    Future<void> runAfterArchive(BuildContext context, bool result) async {
      if (result) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.setSuccess,
        );
      } else {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.setFail,
        );
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
              child: AquaDialog(
                display: preDisplay,
                fontColor: themeData.itemFontColor,
                bgColor: themeData.dialogBgColor,
                title: NoResizeText(AppLocalizations.of(context)!.archive),
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
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText('zip'),
                              onPressed: () {
                                changeState(() {
                                  archiveText = 'zip';
                                  archiveType = 'zip';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText(
                                  AppLocalizations.of(context)!.zipCrypto),
                              onPressed: () async {
                                changeState(() {
                                  preDisplay = true;
                                });

                                await showSingleTextFieldModal(
                                  context,
                                  title: AppLocalizations.of(context)!.password,
                                  transparent: true,
                                  onOk: (val) async {
                                    changeState(() {
                                      archiveText =
                                          AppLocalizations.of(context)!
                                              .zipCrypto;
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
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText('tar'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar';
                                  archiveType = 'tar';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText('tar.gz'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar.gz';
                                  archiveType = 'tar.gz';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText('tar.bz2'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar.bz2';
                                  archiveType = 'tar.bz2';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText('tar.xz'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'tar.xz';
                                  archiveType = 'tar.xz';
                                });
                              },
                            ),
                            // FocusedMenuItem(
                            //   backgroundColor: themeData.menuItemColor,
                            //   title: ThemedText('7z'),
                            //   onPressed: () async {
                            //     changeState(() {
                            //       archiveText = '7z';
                            //       archiveType = '7z';
                            //     });
                            //   },
                            // ),
                            FocusedMenuItem(
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText('jar'),
                              onPressed: () async {
                                changeState(() {
                                  archiveText = 'jar';
                                  archiveType = 'jar';
                                });
                              },
                            ),
                            FocusedMenuItem(
                              backgroundColor: themeData.menuItemColor,
                              title: ThemedText(
                                AppLocalizations.of(context)!.cancel,
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
                      : loadingIndicator(context, themeModel),
                  SizedBox(height: 10),
                ],
                defaultOkText: AppLocalizations.of(context)!.sure,
                defaultCancelText: popAble
                    ? AppLocalizations.of(context)!.cancel
                    : AppLocalizations.of(context)!.background,
                onOk: () async {
                  if (!popAble && currentDir == null) {
                    return;
                  }
                  changeState(() {
                    popAble = false;
                  });
                  await Future.delayed(Duration(milliseconds: 50));
                  List<String> paths = globalModel.selectedFiles
                      .map((e) => e.entity.path)
                      .toList();

                  String generatedArchivePath = FsUtils.newPathWhenExists(
                      pathLib.join(
                        currentDir!.path,
                        FsUtils.getArchiveName(paths, currentDir.path),
                      ),
                      '.' + archiveType);

                  if (archiveType == 'zip') {
                    bool result = await Archive.zip(paths, generatedArchivePath,
                            pwd: pwd.trim(), encrypt: ZipEncryptionMethod.aes)
                        .catchError((err) {});
                    await runAfterArchive(context, result);
                  } else {
                    late ArchiveFormat type;
                    CompressionType? cType;

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
                      bool result = await Archive.createArchive(
                        paths,
                        currentDir.path,
                        FsUtils.getName(generatedArchivePath),
                        type,
                        compressionType: cType,
                      ).catchError((err) {});

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
    autoCancel: true,
    showProgress: true,
    indeterminate: true,
  );
}
