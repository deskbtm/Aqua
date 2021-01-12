import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lan_file_more/common/widget/draggable_scrollbar.dart';
import 'package:lan_file_more/common/widget/images.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_item.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_manager.dart';
import 'package:provider/provider.dart';

class ListFileItemInfo {
  final Widget leading;
  final SelfFileEntity file;

  ListFileItemInfo({
    this.leading,
    this.file,
  });
}

class FileListView extends StatefulWidget {
  final List<SelfFileEntity> fileList;
  final Function(int) itemOnLongPress;
  final Function(LongPressStartDetails) onLongPressEmpty;
  final Function(int, double) onHozDrag;
  final Function(int) onItemTap;
  final FileManagerMode mode;
  final Function onUpdateView;

  const FileListView({
    Key key,
    @required this.fileList,
    this.itemOnLongPress,
    @required this.onHozDrag,
    this.onItemTap,
    this.onLongPressEmpty,
    this.onUpdateView,
    @required this.mode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListViewState();
  }
}

class _FileListViewState extends State<FileListView> {
  ThemeModel _themeModel;
  ScrollController _scrollController;
  bool _mutex;

  @override
  void initState() {
    super.initState();
    _mutex = false;
    // _cachedFileList = [];

    _scrollController = ScrollController()
      ..addListener(() {
        // if (_scrollController.offset < -140) {
        //   _mutex = true;
        // }
        // if (_scrollController.offset >= 0 && _scrollController.offset <= 10) {
        //   // if (_mutex) {
        //   //   if (widget.onUpdateView != null) widget.onUpdateView();
        //   // }
        //   _mutex = false;
        // }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  void showText(String content) {
    BotToast.showText(text: content);
  }

  @override
  void dispose() {
    super.dispose();
    // _cachedFileList = [];
  }

  @override
  Widget build(BuildContext context) {
    /// 如果文件数量变化，更新否则使用缓存的[_cachedFileList]，防止读取照片文件
    /// thumb 时瞎几把闪，提前渲染好leaing

    log("====================================");

    return widget.fileList.isEmpty
        ? GestureDetector(
            onLongPressStart: widget.onLongPressEmpty,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: NoResizeText('空'),
              ),
            ),
          )
        : GestureDetector(
            onLongPressStart: widget.onLongPressEmpty,

            /// [bug] DraggableScrollbar 会导致ListView setState()
            /// 会有错误抛出 但是不太影响

            child: AnimationLimiter(
              child: DraggableScrollbar.rrect(
                controller: _scrollController,
                scrollbarTimeToFade: const Duration(seconds: 5),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  itemCount: widget.fileList.length,
                  itemBuilder: (BuildContext context, int index) {
                    SelfFileEntity file = widget.fileList[index];
                    ListFileItemInfo item = ListFileItemInfo(
                      leading: getPreviewIcon(context, _themeModel, file),
                      file: file,
                    );

                    return FileItem(
                      mode: widget.mode,
                      isDir: item.file.isDir,
                      leading: item.leading,
                      withAnimation: index < 15,
                      index: index,
                      file: item.file,
                      onLongPress: (details) {
                        if (widget.itemOnLongPress != null) {
                          widget.itemOnLongPress(index);
                        }
                      },
                      onTap: () {
                        if (widget.onItemTap != null) widget.onItemTap(index);
                      },
                      onHozDrag: (dir) async {
                        /// [index] 位数 [dir] 方向 1 向右 -1 左
                        await widget.onHozDrag(index, dir);
                      },
                    );
                  },
                ),
              ),
            ),
          );
  }
}
