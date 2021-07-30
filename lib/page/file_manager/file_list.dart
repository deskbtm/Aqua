import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/theme.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/common/widget/static_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:aqua/common/widget/cloud_header.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/page/file_manager/file_operation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:aqua/page/file_manager/file_list_tile.dart';
import 'package:aqua/common/widget/images.dart';
import 'package:aqua/model/global_model.dart';
import 'package:provider/provider.dart';
import 'fs_ui_utils.dart';
import 'fs_utils.dart';

class FileList extends StatefulWidget {
  final List<SelfFileEntity>? list;
  final Function(SelfFileEntity)? onDirTileTap;
  final FileManagerMode mode;

  final Color? itemBgColor;

  final VoidCallback? onTapEmpty;

  // final FileManagerModel fileModel;

  final Function(Directory) onChangeCurrentDir;
  final Function(bool) onChangePopLocker;
  final int? selectLimit;
  final bool first;

  const FileList({
    Key? key,
    this.onTapEmpty,
    this.itemBgColor,
    this.onDirTileTap,
    this.selectLimit,
    required this.list,
    required this.mode,
    required this.first,
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
  late ThemeModel _themeModel;
  late FileOperation _fileOperation;
  late GlobalModel _globalModel;
  EasyRefreshController _controller = EasyRefreshController();
  ScrollController _scrollController = ScrollController();
  late FileManagerModel _fmModel;

  @override
  void initState() {
    super.initState();

    _fileOperation = FileOperation(
      context: context,
      selectLimit: widget.selectLimit,
      mode: widget.mode,
      left: widget.first,
    );

    _globalModel = Provider.of<GlobalModel>(context, listen: false);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _fmModel = Provider.of<FileManagerModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
  }

  AquaTheme getTheme() {
    return _themeModel.themeData;
  }

  Directory getDirectory() {
    return widget.first && !_fmModel.isRelativeRoot
        ? _fmModel.currentDir!.parent
        : _fmModel.currentDir!;
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
                content: S.of(context)!.archiveHere,
                onTap: () async {
                  await _fileOperation.showCreateArchiveModal(
                    context,
                    mounted: mounted,
                  );
                },
              ),
            if (sharedNotEmpty)
              ActionButton(
                content: S.of(context)!.moveHere,
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
                content: S.of(context)!.copyHere,
                onTap: () async {
                  await _fileOperation.copyModal(
                    context,
                    mounted: mounted,
                  );
                },
              ),
              ActionButton(
                content: S.of(context)!.extractHere,
                onTap: () async {
                  await _fileOperation.handleExtractArchive(
                    context,
                    mounted: mounted,
                  );
                },
              ),
            ],
            ActionButton(
              content: S.of(context)!.create,
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
                  onRefresh: () async => setState(() {}),
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
                              await FsUIUtils.handleHozDragItem(
                                  context, file, dir);
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
    return widget.list == null ? Container() : validFileList(widget.list!);
    // return FutureBuilder(
    //   future: _readdir(),
    //   builder:
    //       (BuildContext context, AsyncSnapshot<List<SelfFileEntity>> snapshot) {
    //     if (snapshot.hasData && snapshot.data != null) {
    //       return validFileList(snapshot.data!);
    //     } else if (snapshot.hasError) {
    //       return ErrorBoard();
    //     } else {
    //       return Container();
    //     }
    //   },
    // );
  }
}
