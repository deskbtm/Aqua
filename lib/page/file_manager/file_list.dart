import 'dart:io';
import 'dart:ui';

import 'package:aqua/common/theme.dart';
import 'package:aqua/common/widget/cloud_header.dart';
import 'package:aqua/common/widget/static_utils.dart';
import 'package:aqua/model/file_manager_model.dart';
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
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unicons/unicons.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'fs_ui_utils.dart';
import 'fs_utils.dart';

class FileList extends StatefulWidget {
  // final List<SelfFileEntity> fileList;
  final Function(SelfFileEntity)? onDirTileTap;
  final FileManagerMode mode;
  final Future<void> Function() update2Side;
  final Color? itemBgColor;
  final void Function()? onScroll;
  final VoidCallback? onTapEmpty;

  // final FileManagerModel fileModel;

  final Function(Directory) onChangeCurrentDir;
  final Function(bool) onChangePopLocker;
  final int? selectLimit;
  final bool left;

  const FileList({
    Key? key,
    this.onScroll,
    this.onTapEmpty,
    this.itemBgColor,
    this.onDirTileTap,
    // required this.fileList,
    required this.update2Side,
    required this.mode,
    required this.left,
    this.selectLimit,
    required this.onChangeCurrentDir,
    required this.onChangePopLocker,

    // required this.fileModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileListState();
  }
}

class _FileListState extends State<FileList> {
  // late ScrollController _scrollController;
  late ThemeModel _themeModel;

  late FileOperation _fileOperation;
  late GlobalModel _globalModel;
  EasyRefreshController _controller = EasyRefreshController();
  ScrollController _scrollController = ScrollController();
  late FileManagerModel _fileManagerModel;

  late bool _pending = false;

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
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _fileManagerModel = Provider.of<FileManagerModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    // _scrollController.dispose();
  }

  AquaTheme getTheme() {
    return _themeModel.themeData;
  }

  Future<List<SelfFileEntity>> _readDir() async {
    return FsUIUtils.readdirSafely(context, _fileManagerModel.currentDir!);
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

  void _handleTileTap(
      SelfFileEntity file, int index, List<SelfFileEntity> list) {
    if (file.isDir) {
      if (widget.onDirTileTap != null) {
        widget.onDirTileTap!(file);
      }
    } else {
      _fileOperation.openFileActionByExt(
        file,
        index: index,
        fileList: list,
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

  Widget validFileList(List<SelfFileEntity> list) {
    return list.isEmpty
        ? GestureDetector(
            onLongPressStart: (details) async {
              await _showOptionsWhenPressedEmpty(context);
            },
            onTap: widget.onTapEmpty,
            child: EmptyBoard(),
          )
        : GestureDetector(
            onLongPressStart: (details) async {
              await _showOptionsWhenPressedEmpty(context);
            },
            child: AnimationLimiter(
              child: CupertinoScrollbar(
                controller: _scrollController,
                child: EasyRefresh.custom(
                  controller: _controller,
                  scrollController: _scrollController,
                  header: CloudHeader(),
                  onRefresh: widget.update2Side,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          SelfFileEntity file = list[index];
                          Widget leading = getPreviewIcon(context, file);
                          return FileListTile(
                            path: file.path,
                            title: file.filename,
                            subTitle: file.humanModified,
                            mode: widget.mode,
                            leading: leading,
                            height: 72,
                            titleStyle:
                                TextStyle(color: getTheme().itemFontColor),
                            leadingTitle: file.isDir ? file.humanSize : null,
                            trailing: file.isDir
                                ? Icon(
                                    Icons.arrow_right,
                                    size: 16,
                                    color: getTheme().itemFontColor,
                                  )
                                : null,
                            withAnimation: index < 15,
                            index: index,
                            onLongPressStart: (details) async {
                              await _handleLongPressStart(file);
                            },
                            onTap: () => _handleTileTap(file, index, list),
                            onHozDrag: (dir) async {
                              await _fileOperation.handleHozDragItem(file, dir);
                            },
                          );
                        },
                        childCount: list.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _readDir(),
      builder:
          (BuildContext context, AsyncSnapshot<List<SelfFileEntity>> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return validFileList(snapshot.data!);
        } else if (snapshot.hasError) {
          return ErrorBoard();
        } else {
          return Container();
        }
      },
    );
  }
}
