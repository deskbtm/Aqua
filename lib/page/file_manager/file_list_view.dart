import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lan_file_more/common/widget/draggable_scrollbar.dart';
import 'package:lan_file_more/common/widget/images.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_item.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';

class ListFileItemInfo {
  final Widget leading;
  final SelfFileEntity file;

  ListFileItemInfo({this.leading, this.file});
}

class FileListView extends StatefulWidget {
  final List<SelfFileEntity> fileList;
  final Function(int, Function(bool)) itemOnLongPress;
  final Function(LongPressStartDetails) onLongPressEmpty;
  final Function(int, double) onHozDrag;
  final Function(int, Function(bool)) onItemTap;
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

class _FileListViewState extends State<FileListView> {
  ThemeModel _themeModel;
  ScrollController _scrollController;
  bool _mutex;
  List<ListFileItemInfo> _cachedFileList;

  @override
  void initState() {
    super.initState();
    _mutex = false;
    _cachedFileList = [];

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
    _themeModel = Provider.of<ThemeModel>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  @override
  void dispose() {
    super.dispose();
    _cachedFileList = [];
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel.themeData;

    /// 如果文件数量变化，更新否则使用缓存的[_cachedFileList]，防止读取照片文件
    /// thumb 时瞎几把闪，提前渲染好leaing

    if (widget.fileList.length != _cachedFileList.length) {
      _cachedFileList.clear();
      for (var i = 0; i < widget.fileList.length; i++) {
        SelfFileEntity file = widget.fileList[i];
        _cachedFileList.add(ListFileItemInfo(
            leading: getPreviewIcon(context, _themeModel, file), file: file));
      }
    }

    return _cachedFileList.isEmpty
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
                  itemCount: _cachedFileList.length,
                  itemBuilder: (BuildContext context, int index) {
                    ListFileItemInfo item = _cachedFileList[index];

                    return FileItem(
                      type: item.file.isDir
                          ? FileItemType.folder
                          : FileItemType.file,
                      leading: item.file.isDir
                          ? item.leading
                          // 显示文件的大小
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                item.leading,
                                SizedBox(height: 6),
                                NoResizeText(
                                  item.file.humanSize,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: themeData?.itemFontColor,
                                  ),
                                )
                              ],
                            ),
                      withAnimation: index < 15,
                      index: index,
                      filename: item.file.filename,
                      path: item.file.entity.path,
                      subTitle: MixUtils.formatFileTime(item.file.modified),
                      onLongPress: (details, update) {
                        if (widget.itemOnLongPress != null) {
                          widget.itemOnLongPress(index, update);
                        }
                      },
                      onTap: (itemUpdate) {
                        if (widget.onItemTap != null)
                          widget.onItemTap(index, itemUpdate);
                      },
                      onHozDrag: (dir) {
                        /// [index] 位数 [dir] 方向 1 向右 -1 左
                        widget.onHozDrag(index, dir);
                      },
                    );
                  },
                ),
              ),
            ),
          );
  }

  // @override
  // bool get wantKeepAlive => true;
}

// FutureBuilder<Widget>(
//                       future: getPreviewIcon(file),
//                       builder: (BuildContext context, AsyncSnapshot snapshot) {
//                         if (snapshot.connectionState == ConnectionState.done) {
//                           if (snapshot.hasError) {
//                             return loadingIndicator(context, _themeModel);
//                           } else {
//                             return file.isDir
//                                 ? snapshot.data
//                                 : Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: <Widget>[
//                                       snapshot.data,
//                                       SizedBox(height: 6),
//                                       NoResizeText(
//                                         file.humanSize,
//                                         style: TextStyle(
//                                           fontSize: 8,
//                                           color: themeData?.itemFontColor,
//                                         ),
//                                       )
//                                     ],
//                                   );
//                           }
//                         } else {
//                           return loadingIndicator(context, _themeModel);
//                         }
//                       },
//                     ),
