import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/text_field.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_manager.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'file_list_view.dart';

Future<void> createSearchModal(
  BuildContext context, {
  // @required List<SelfFileEntity> fileList,
  @required Directory currentDir,
  @required ThemeModel provider,
}) async {
  TextEditingController textEditingController = TextEditingController();
  StreamSubscription<FileSystemEntity> listener;
  List<SelfFileEntity> fileList = [];

  bool visible = false;

  await showCupertinoModalPopup(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          Timer(Duration(milliseconds: 250), () {
            changeState(() {
              visible = true;
            });
          });

          textEditingController.addListener(() {
            listener?.cancel();
            fileList = [];
            listener = currentDir.list(recursive: false).listen((event) async {
              String name = pathLib.basename(event.path);
              if (textEditingController.text != '' &&
                  name.contains(RegExp(textEditingController.text,
                      caseSensitive: false))) {
                SelfFileEntity file =
                    await FileAction.createSelfFileEntity(event);
                fileList.insert(0, file);
              }
            }, onDone: () {
              changeState(() {});
            });
          });

          return WillPopScope(
            onWillPop: () async {
              changeState(() {
                visible = false;
              });
              // textEditingController = null;
              return true;
            },
            child: SafeArea(
              child: AnimatedOpacity(
                opacity: visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: visible ? 500 : 0),
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(
                          left: 8, right: 8, top: 12, bottom: 12),
                      child: LanTextField(
                        style: TextStyle(fontSize: 16),
                        // focusNode: ,
                        controller: textEditingController,
                        placeholder: '搜索...',
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: FileListView(
                          onScroll: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          fileList: fileList,
                          itemBgColor:
                              provider.isDark ? null : Color(0xF3EBEBEB),
                          mode: FileManagerMode.surf,
                          onItemTap: (index) async {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          onTapEmpty: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            MixUtils.safePop(context);
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
}
