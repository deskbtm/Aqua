import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lan_express/common/widget/draggable_scrollbar.dart';
import 'package:lan_express/common/widget/images.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_item.dart';
import 'package:lan_express/model/theme_model.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:provider/provider.dart';

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

class _FileListViewState extends State<FileListView>
    with AutomaticKeepAliveClientMixin {
  ThemeModel _themeModel;
  ScrollController _scrollController;
  bool _mutex;
  List<Widget> _loadedList;

  @override
  void initState() {
    super.initState();
    _mutex = false;
    _loadedList = List(widget.fileList.length);
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
    if (widget.fileList.isNotEmpty) {
      _loadedList = List(widget.fileList.length);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loadedList = [];
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    dynamic themeData = _themeModel.themeData;

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

            // ListView.custom();

            /// [bug] DraggableScrollbar 会导致ListView setState()
            child: AnimationLimiter(
              child: DraggableScrollbar.rrect(
                controller: _scrollController,
                scrollbarTimeToFade: const Duration(seconds: 5),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  itemCount: widget.fileList.length,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  itemBuilder: (BuildContext context, int index) {
                    SelfFileEntity file = widget.fileList[index];
                    if (_loadedList.elementAt(index) == null) {
                      Widget previewIcon =
                          getPreviewIconSync(context, _themeModel, file);
                      _loadedList[index] = previewIcon;
                    }

                    return FileItem(
                      type:
                          file.isDir ? FileItemType.folder : FileItemType.file,
                      leading: file.isDir
                          ? _loadedList[index]
                          // 显示文件的大小
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _loadedList[index],
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

  @override
  bool get wantKeepAlive => true;
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
