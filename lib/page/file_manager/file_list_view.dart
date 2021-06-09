import 'dart:io';
import 'dart:ui';

import 'package:aqua/common/theme.dart';
import 'package:aqua/common/widget/cloud_header.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/images.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/page/file_manager/file_operation.dart';
import 'package:aqua/page/file_manager/file_list_tile.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unicons/unicons.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'file_manager_mode.dart';
import 'file_utils.dart';

class FileListView extends StatefulWidget {
  final List<SelfFileEntity> fileList;
  final Function(SelfFileEntity)? onDirTileTap;
  final FileManagerMode mode;
  final Future<void> Function() update2Side;
  final Color? itemBgColor;
  final void Function()? onScroll;
  final VoidCallback? onTapEmpty;
  final ScrollController? scrollController;
  // final FileManagerModel fileModel;

  final Function(Directory) onChangeCurrentDir;
  final Function(bool) onChangePopLocker;
  final int? selectLimit;
  final bool left;

  const FileListView({
    Key? key,
    this.onScroll,
    this.onTapEmpty,
    this.itemBgColor,
    this.onDirTileTap,
    required this.fileList,
    required this.update2Side,
    required this.mode,
    required this.left,
    this.selectLimit,
    required this.onChangeCurrentDir,
    required this.onChangePopLocker,
    this.scrollController,
    // required this.fileModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListViewState();
  }
}

class _FileListViewState extends State<FileListView> {
  // late ScrollController _scrollController;
  late ThemeModel _themeModel;

  late FileOperation _fileOperation;
  late GlobalModel _globalModel;
  EasyRefreshController _controller = EasyRefreshController();

  @override
  void initState() {
    super.initState();

    // _scrollController = ScrollController();
    _fileOperation = FileOperation(
      context: context,
      update2Side: widget.update2Side,
      selectLimit: widget.selectLimit,
      mode: widget.mode,
      left: widget.left,
    );
    _globalModel = Provider.of<GlobalModel>(context, listen: false);
    if (widget.onScroll != null) {
      // _scrollController.addListener(widget.onScroll!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    // _scrollController.dispose();
  }

  Future<void> _showOptionsWhenPressedEmpty(BuildContext context) async {
    bool sharedNotEmpty = _globalModel.selectedFiles.isNotEmpty;
    showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return SplitSelectionModal(
          leftChildren: <Widget>[
            if (sharedNotEmpty)
              ActionButton(
                content: AppLocalizations.of(context)!.archiveHere,
                onTap: () async {
                  await _fileOperation.showCreateArchiveModal(
                    context,
                    mounted: mounted,
                  );
                },
              ),
            if (sharedNotEmpty)
              ActionButton(
                content: AppLocalizations.of(context)!.moveHere,
                onTap: () async {
                  await _fileOperation.handleMove(
                    mounted: mounted,
                  );
                },
              ),
          ],
          rightChildren: <Widget>[
            if (sharedNotEmpty) ...[
              ActionButton(
                content: AppLocalizations.of(context)!.copyHere,
                onTap: () async {
                  await _fileOperation.copyModal(
                    context,
                    mounted: mounted,
                  );
                },
              ),
              ActionButton(
                content: AppLocalizations.of(context)!.extractHere,
                onTap: () async {
                  await _fileOperation.handleExtractArchive(
                    context,
                    mounted: mounted,
                  );
                },
              ),
            ],
            ActionButton(
              content: AppLocalizations.of(context)!.create,
              onTap: () async {
                await _fileOperation.showCreateFileModal(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _handleTileTap(SelfFileEntity file, int index) {
    if (file.isDir) {
      if (widget.onDirTileTap != null) {
        widget.onDirTileTap!(file);
      }
    } else {
      _fileOperation.openFileActionByExt(
        file,
        index: index,
        fileList: widget.fileList,
        onChangePopLocker: widget.onChangePopLocker,
        updateView: setState,
      );
    }
  }

  Future<void> _handleLongPressStart(SelfFileEntity file) async {
    return _fileOperation.showFileActionModal(
      file: file,
      onChangeCurrentDir: widget.onChangeCurrentDir,
      mounted: mounted,
    );
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme theme = _themeModel.themeData;

    return widget.fileList.isEmpty
        ? GestureDetector(
            onLongPressStart: (details) async {
              await _showOptionsWhenPressedEmpty(context);
            },
            onTap: widget.onTapEmpty,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: NoResizeText(AppLocalizations.of(context)!.empty),
              ),
            ),
          )
        : GestureDetector(
            onLongPressStart: (details) async {
              await _showOptionsWhenPressedEmpty(context);
            },
            child: AnimationLimiter(
              child: CupertinoScrollbar(
                controller: widget.scrollController,
                child: EasyRefresh.custom(
                  controller: _controller,
                  scrollController: widget.scrollController,
                  header: CloudHeader(),
                  onRefresh: widget.update2Side,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          SelfFileEntity file = widget.fileList[index];
                          Widget leading = getPreviewIcon(context, file);
                          return FileListTile(
                            path: file.path,
                            title: file.filename,
                            subTitle: file.humanModified,
                            mode: widget.mode,
                            leading: leading,
                            height: 72,
                            titleStyle: TextStyle(color: theme.itemFontColor),
                            leadingTitle: file.isDir ? file.humanSize : null,
                            trailing: file.isDir
                                ? Icon(
                                    Icons.arrow_right,
                                    size: 16,
                                    color: theme.itemFontColor,
                                  )
                                : null,
                            withAnimation: index < 15,
                            index: index,
                            onLongPressStart: (details) async {
                              await _handleLongPressStart(file);
                            },
                            onTap: () => _handleTileTap(file, index),
                            onHozDrag: (dir) async {
                              await _fileOperation.handleHozDragItem(file, dir);
                            },
                          );
                        },
                        childCount: widget.fileList.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
