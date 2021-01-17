import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/draggable_scrollbar.dart';
import 'package:lan_file_more/common/widget/images.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_action_ui.dart';
import 'package:lan_file_more/page/file_manager/file_item.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_manager.dart';

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
  final Function(int) onItemTap;
  final FileManagerMode mode;
  final Function onUpdateView;
  final Color itemBgColor;
  final Function onScroll;
  final Function onTapEmpty;
  final ThemeModel themeModel;
  final CommonModel commonModel;
  final Directory currentDir;
  final Function(Directory) onChangeCurrentDir;

  const FileListView({
    Key key,
    @required this.fileList,
    this.onItemTap,
    this.onUpdateView,
    @required this.mode,
    this.itemBgColor,
    this.onScroll,
    this.onTapEmpty,
    this.themeModel,
    this.commonModel,
    @required this.currentDir,
    @required this.onChangeCurrentDir,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListViewState();
  }
}

class _FileListViewState extends State<FileListView> {
  ScrollController _scrollController;
  EasyRefreshController _controller;

  ThemeModel get themeModel => widget.themeModel;
  CommonModel get commonModel => widget.commonModel;
  Function get onUpdateView => widget.onUpdateView;
  FileManagerMode get mode => widget.mode;
  Directory get currentDir => widget.currentDir;
  Function(Directory) get onChangeCurrentDir => widget.onChangeCurrentDir;

  FileActionUI _fileActionUI;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _fileActionUI = FileActionUI(
      commonModel: commonModel,
      themeModel: themeModel,
      update2Side: onUpdateView,
      mode: mode,
    );
    if (widget.onScroll != null) {
      _scrollController.addListener(widget.onScroll);
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // _themeModel = Provider.of<ThemeModel>(context);
  //   // _commonModel = Provider.of<CommonModel>(context);
  // }

  void showText(String content) {
    BotToast.showText(text: content);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _scrollController?.dispose();
    _controller = null;
  }

  Future<void> _showOptionsWhenPressedEmpty(BuildContext context,
      {bool left = false}) async {
    bool sharedNotEmpty = commonModel.selectedFiles.isNotEmpty;
    showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return SplitSelectionModal(
          leftChildren: <Widget>[
            if (sharedNotEmpty)
              ActionButton(
                content: '归档到此',
                onTap: () async {
                  await _fileActionUI.showCreateArchiveModal(context);
                },
              ),
            if (sharedNotEmpty)
              ActionButton(
                content: '移动到此',
                onTap: () async {
                  await _fileActionUI.handleMove(context);
                },
              ),
          ],
          rightChildren: <Widget>[
            if (sharedNotEmpty) ...[
              ActionButton(
                content: '复制到此',
                onTap: () async {
                  await _fileActionUI.copyModal(context);
                },
              ),
              ActionButton(
                content: '提取到此',
                onTap: () async {
                  await _fileActionUI.handleExtractArchive(
                    context,
                    currentDir: null,
                    mounted: mounted,
                  );
                },
              ),
            ],
            ActionButton(
              content: '新建',
              onTap: () async {
                await _fileActionUI.showCreateFileModal(context, left: left);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 如果文件数量变化，更新否则使用缓存的[_cachedFileList]，防止读取照片文件
    /// thumb 时瞎几把闪，提前渲染好leaing

    return widget.fileList.isEmpty
        ? GestureDetector(
            onLongPressStart: (details) async {
              await _showOptionsWhenPressedEmpty(context);
            },
            onTap: widget.onTapEmpty,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: NoResizeText('空'),
              ),
            ),
          )
        : GestureDetector(
            onLongPressStart: (details) async {
              await _showOptionsWhenPressedEmpty(context);
            },

            /// [bug] DraggableScrollbar 会导致ListView setState()
            /// 会有错误抛出 但是不太影响
            child: AnimationLimiter(
              child: DraggableScrollbar.rrect(
                controller: _scrollController,
                scrollbarTimeToFade: const Duration(seconds: 5),
                child: EasyRefresh.custom(
                  controller: _controller,
                  scrollController: _scrollController,
                  header: TaurusHeader(),
                  onRefresh: widget.onUpdateView,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          SelfFileEntity file = widget.fileList[index];
                          ListFileItemInfo item = ListFileItemInfo(
                            leading: getPreviewIcon(context, themeModel, file),
                            file: file,
                          );
                          return FileItem(
                            itemBgColor: widget.itemBgColor,
                            mode: widget.mode,
                            isDir: item.file.isDir,
                            leading: item.leading,
                            withAnimation: index < 15,
                            index: index,
                            file: item.file,
                            onLongPress: (details) async {
                              await _fileActionUI.showFileActionModal(
                                context,
                                file: item.file,
                                currentDir: currentDir,
                                onChangeCurrentDir: onChangeCurrentDir,
                              );
                            },
                            onTap: () {
                              if (widget.onItemTap != null)
                                widget.onItemTap(index);
                            },
                            onHozDrag: (dir) async {
                              /// [index] 位数 [dir] 方向 1 向右 -1 左
                              _fileActionUI.handleHozDragItem(item.file, dir);
                            },
                          );
                        },
                        childCount: widget.fileList.length,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
