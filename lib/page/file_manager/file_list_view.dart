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
import 'package:lan_file_more/model/file_model.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_item.dart';
import 'package:lan_file_more/page/file_manager/file_manager.dart';
import 'package:provider/provider.dart';

import 'file_utils.dart';

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
  final Function(SelfFileEntity) onDirItemTap;
  final FileManagerMode mode;
  final Function update2Side;
  final Color itemBgColor;
  final Function onScroll;
  final Function onTapEmpty;
  // final FileModel fileModel;

  final Function(Directory) onChangeCurrentDir;
  final Function(bool) onChangePopLocker;
  final int selectLimit;
  final bool left;

  const FileListView({
    Key key,
    this.onScroll,
    this.onTapEmpty,
    this.itemBgColor,
    this.onDirItemTap,
    @required this.fileList,
    @required this.update2Side,
    @required this.mode,
    @required this.left,
    @required this.selectLimit,
    @required this.onChangeCurrentDir,
    @required this.onChangePopLocker,
    // @required this.fileModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListViewState();
  }
}

class _FileListViewState extends State<FileListView> {
  ScrollController _scrollController;
  EasyRefreshController _controller;
  FileModel fileModel;

  FileActionUI _fileActionUI;

  @override
  void initState() {
    super.initState();
    fileModel = Provider.of<FileModel>(context, listen: false);
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
    _fileActionUI = FileActionUI(
      update2Side: widget.update2Side,
      selectLimit: widget.selectLimit,
      mode: widget.mode,
      fileModel: fileModel,
      left: widget.left,
    );
    if (widget.onScroll != null) {
      _scrollController.addListener(widget.onScroll);
    }
  }

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

  Future<void> _showOptionsWhenPressedEmpty(BuildContext context) async {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
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
                  await _fileActionUI.showCreateArchiveModal(
                    context,
                    mounted: mounted,
                  );
                },
              ),
            if (sharedNotEmpty)
              ActionButton(
                content: '移动到此',
                onTap: () async {
                  await _fileActionUI.handleMove(
                    context,
                    mounted: mounted,
                  );
                },
              ),
          ],
          rightChildren: <Widget>[
            if (sharedNotEmpty) ...[
              ActionButton(
                content: '复制到此',
                onTap: () async {
                  await _fileActionUI.copyModal(
                    context,
                    mounted: mounted,
                  );
                },
              ),
              ActionButton(
                content: '提取到此',
                onTap: () async {
                  await _fileActionUI.handleExtractArchive(
                    context,
                    mounted: mounted,
                  );
                },
              ),
            ],
            ActionButton(
              content: '新建',
              onTap: () async {
                await _fileActionUI.showCreateFileModal(context);
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
                  onRefresh: widget.update2Side,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          SelfFileEntity file = widget.fileList[index];
                          ListFileItemInfo item = ListFileItemInfo(
                            leading: getPreviewIcon(context, file),
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
                                onChangeCurrentDir: widget.onChangeCurrentDir,
                                mounted: mounted,
                              );
                            },
                            onTap: () {
                              if (file.isDir) {
                                if (widget.onDirItemTap != null) {
                                  widget.onDirItemTap(item.file);
                                }
                              } else {
                                _fileActionUI.openFileActionByExt(
                                  context,
                                  item.file,
                                  index: index,
                                  fileList: widget.fileList,
                                  onChangePopLocker: widget.onChangePopLocker,
                                  updateView: setState,
                                );
                              }
                            },
                            onHozDrag: (dir) async {
                              /// [index] 位数 [dir] 方向 1 向右 -1 左
                              _fileActionUI.handleHozDragItem(
                                  context, item.file, dir);
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
