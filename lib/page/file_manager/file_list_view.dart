import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lan_express/common/widget/draggable_scrollbar.dart';
import 'package:lan_express/common/widget/images.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_item.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:provider/provider.dart';

class FileListView extends StatefulWidget {
  final List<SelfFileEntity> fileList;
  final Function(int) itemOnLongPress;
  final Function(LongPressStartDetails) onLongPressEmpty;
  final Function(int, double) onHozDrag;
  final Function(int) onItemTap;
  final Function onUpdateView;

  const FileListView(
      {Key key,
      @required this.fileList,
      this.itemOnLongPress,
      @required this.onHozDrag,
      this.onItemTap,
      this.onLongPressEmpty,
      this.onUpdateView})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListViewState();
  }
}

class _FileListViewState extends State<FileListView>
    with AutomaticKeepAliveClientMixin {
  ThemeProvider _themeProvider;
  // CommonProvider _commonProvider;
  ScrollController _scrollController;
  bool _mutex;

  @override
  void initState() {
    super.initState();
    _mutex = false;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset < -140) {
          _mutex = true;
        }
        if (_scrollController.offset >= 0 && _scrollController.offset <= 10) {
          if (_mutex) {
            if (widget.onUpdateView != null) widget.onUpdateView();
          }
          _mutex = false;
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    // _commonProvider = Provider.of<CommonProvider>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    dynamic themeData = _themeProvider.themeData;
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
            child: DraggableScrollbar.rrect(
              controller: _scrollController,
              scrollbarTimeToFade: const Duration(seconds: 5),
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
            ));
  }

  @override
  bool get wantKeepAlive => true;
}
