import 'dart:io';
import 'dart:ui';

import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lan_express/common/widget/images.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_item.dart';
import 'package:lan_express/page/file_manager/file_utils.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as pathLib;
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FileListView extends StatefulWidget {
  final List<SelfFileEntity> fileList;
  final Function(int) itemOnLongPress;
  final Function(LongPressStartDetails) emptyOnLongPress;
  final Function(int, double) onHozDrag;
  final Function(int) onItemTap;
  // final Function(int) onFolderTap;
  final Function onUpdateView;

  const FileListView(
      {Key key,
      @required this.fileList,
      this.itemOnLongPress,
      @required this.onHozDrag,
      this.onItemTap,
      // this.onFolderTap,
      this.emptyOnLongPress,
      this.onUpdateView})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListViewState();
  }
}

class _FileListViewState extends State<FileListView> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;
  ScrollController _scrollController;
  bool locker;

  @override
  void initState() {
    super.initState();
    locker = false;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset < -140) {
          locker = true;
        }
        if (_scrollController.offset >= 0 && _scrollController.offset <= 10) {
          if (locker) {
            if (widget.onUpdateView != null) widget.onUpdateView();
          }
          locker = false;
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider.themeData;
    return widget.fileList.isEmpty
        ? GestureDetector(
            onLongPressStart: widget.emptyOnLongPress,
            child: Center(
              child: NoResizeText('空'),
            ),
          )
        : GestureDetector(
            onLongPressStart: widget.emptyOnLongPress,
            child: Scrollbar(
              child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                itemCount: widget.fileList.length,
                itemBuilder: (BuildContext context, int index) {
                  SelfFileEntity file = widget.fileList[index];
                  Widget previewIcon = getPreViewIcon(file);

                  return FileItem(
                    type: file.isDir ? FileItemType.folder : FileItemType.file,
                    leading: file.isDir
                        ? previewIcon
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              previewIcon,
                              SizedBox(height: 6),
                              NoResizeText(
                                file.humanSize,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: themeData?.itemFontColor,
                                ),
                              )
                            ],
                          ),
                    withAnimation: index < 15,
                    index: index,
                    filename: file.filename,
                    path: file.entity.path,
                    subTitle: MixUtils.formatFileTime(file.modified),
                    onLongPress: (details) {
                      if (widget.itemOnLongPress != null)
                        widget.itemOnLongPress(index);
                    },
                    onTap: () {
                      if (widget.onItemTap != null) widget.onItemTap(index);

                      // if (!file.isDir) {
                      //   openFileActionByExt(file.entity.path);
                      // }
                    },
                    onHozDrag: (dir) {
                      /// [index] 位数 [dir] 方向 1 向右 -1 左
                      widget.onHozDrag(index, dir);
                    },
                  );
                },
              ),
            ),
          );
  }
}
