import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:aqua/common/widget/aqua_text_field.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/file_model.dart';
import 'package:aqua/model/theme_model.dart';

import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';
import 'file_list_view.dart';
import 'file_manager_mode.dart';
import 'file_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> createSearchModal(
  BuildContext context, {
  required Function(bool) onChangePopLocker,
}) async {
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  FileModel fileModel = Provider.of<FileModel>(context, listen: false);
  AquaTheme themeData = themeModel.themeData;

  TextEditingController textEditingController = TextEditingController();
  StreamSubscription<FileSystemEntity>? listener;
  List<SelfFileEntity> fileList = [];
  Directory currentDir = fileModel.currentDir!;
  late Timer timer;
  bool visible = false;
  bool mutex = true;
  onChangePopLocker(true);

  await showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          void submitSearch([text]) {
            listener?.cancel();
            fileList = [];
            listener = currentDir.list(recursive: false).listen((event) async {
              String name = pathLib.basename(event.path);
              if (textEditingController.text != '' &&
                  name.contains(
                    RegExp(textEditingController.text, caseSensitive: false),
                  )) {
                SelfFileEntity file = await FsUtils.createSelfFileEntity(event);
                fileList.insert(0, file);
              }
            }, onDone: () {
              changeState(() {});
            });
          }

          if (mutex) {
            mutex = false;
            timer = Timer(Duration(milliseconds: 250), () {
              changeState(() {
                visible = true;
              });
            });
          }

          Future<void> readCurrentDir(Directory dir) async {
            fileList = [];

            SelfFileList? result =
                await FsUtils.readdir(dir).catchError((err) async {
              // String errorString = err.toString().toLowerCase();
              // bool overAndroid11 = int.parse(
              //         (await DeviceInfoPlugin().androidInfo).version.release) >=
              //     11;

              // if (errorString.contains('permission') &&
              //     errorString.contains('denied')) {
              //   showTipTextModal(
              //     context,
              //     title: AppLocalizations.of(context)!.error,
              //     tip: (overAndroid11)
              //         ? AppLocalizations.of(context)!.noPermissionO
              //         : AppLocalizations.of(context)!.noPermission,
              //     onCancel: () {},
              //   );
              // }
            });

            if (result != null) {
              changeState(() {
                fileList = result.allList;
              });
            }
          }

          return WillPopScope(
            onWillPop: () async {
              if (pathLib.equals(currentDir.path, fileModel.currentDir!.path)) {
                return true;
              } else {
                currentDir = currentDir.parent;
                await readCurrentDir(currentDir);
                return false;
              }
            },
            child: SafeArea(
              child: AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: visible ? 250 : 0),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(
                          left: 8, right: 8, top: 12, bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              child: AquaTextField(
                                style: TextStyle(fontSize: 16),
                                controller: textEditingController,
                                placeholder:
                                    AppLocalizations.of(context)!.searching,
                                onSubmitted: submitSearch,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            onTap: submitSearch,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: themeData.inputColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.search),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: FileListView(
                          left: true,
                          onScroll: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          fileList: fileList,
                          itemBgColor:
                              themeModel.isDark ? null : Color(0xFFFFFFFF),
                          mode: FileManagerMode.search,
                          onDirTileTap: (dir) async {
                            currentDir = Directory(dir.path);
                            await readCurrentDir(currentDir);
                          },
                          onTapEmpty: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            MixUtils.safePop(context);
                          },
                          // fileModel: fileModel,
                          onChangeCurrentDir: (dir) {},
                          selectLimit: null,
                          onChangePopLocker: onChangePopLocker,
                          update2Side: () async {
                            submitSearch();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
  timer.cancel();
  onChangePopLocker(false);
}
