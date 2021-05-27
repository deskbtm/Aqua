import 'dart:io';
import 'dart:ui';
import 'package:aqua/page/file_editor/editor_theme.dart';
import 'package:aqua/plugin/archive/archive.dart';
import 'package:aqua/plugin/archive/enums.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/dialog.dart';
import 'package:aqua/common/widget/file_info_card.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/file_model.dart';
import 'package:aqua/model/theme_model.dart';

import 'package:aqua/page/file_manager/show_more.dart';
import 'package:aqua/page/photo_viewer/photo_viewer.dart';
import 'package:aqua/page/video/meida_info.dart';
import 'package:aqua/page/video/video.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/common/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';
import 'create_archive.dart';
import 'create_rename.dart';
import 'create_file.dart';
import 'file_manager_mode.dart';
import 'file_utils.dart';

class FileOperation {
  final Future<void> Function() update2Side;
  final FileManagerMode mode;
  final int? selectLimit;
  final bool left;
  final BuildContext context;
  late FileModel _fileModel;
  late GlobalModel _globalModel;
  late ThemeModel _themeModel;

  FileOperation({
    required this.context,
    required this.left,
    required this.update2Side,
    required this.mode,
    this.selectLimit,
  }) {
    _fileModel = Provider.of<FileModel>(context, listen: false);
    _globalModel = Provider.of<GlobalModel>(context, listen: false);
    _themeModel = Provider.of<ThemeModel>(context, listen: false);
  }

  Future<void> showCreateArchiveModal(
    BuildContext context, {
    required bool mounted,
  }) async {
    return createArchiveModal(
      context,
      currentDir: _fileModel.currentDir!,
      onSuccessUpdate: (context) async {
        if (mounted) {
          _fileModel.clearSelectedFiles();
          await update2Side();
          MixUtils.safePop(context);
        }
      },
    );
  }

  void openFileActionByExt(
    SelfFileEntity file, {
    int index = 0,
    required List<SelfFileEntity> fileList,
    required Function(bool) onChangePopLocker,
    required Function(Function()) updateView,
  }) {
    String path = file.entity.path;
    FsUtils.matchFileActionByExt(
      file.ext,
      caseImage: () async {
        List<String> images = FsUtils.filterImages(fileList);
        onChangePopLocker(true);
        // _popLocker = true;

        await Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) {
              return PhotoViewerPage(
                imageRes: images,
                index: images.indexOf(file.entity.path),
              );
            },
          ),
        );
        onChangePopLocker(false);
        // _popLocker = false;
      },
      caseText: () {
        OpenFile.open(path);
      },
      caseAudio: () {
        OpenFile.open(path);
      },
      caseVideo: () async {
        onChangePopLocker(true);
        // _popLocker = true;
        await Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (BuildContext context) {
              return VideoPage(
                info: MediaInfo(
                  name: file.filename,
                  path: file.path,
                ),
              );
            },
          ),
        );
        onChangePopLocker(false);
        // _popLocker = false;
      },
      caseArchive: () {
        _fileModel.clearSelectedFiles();
        _fileModel.addSelectedFile(file);
        updateView(() {});
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.target,
        );
      },
      caseMd: () async {
        String data = await File(path).readAsString();
        await showCupertinoModalPopup(
          context: context,
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          builder: (BuildContext context) {
            return Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: MarkdownWidget(
                data: data,
                padding: EdgeInsets.all(15),
                styleConfig: StyleConfig(
                  codeConfig: CodeConfig(
                    decoration: BoxDecoration(color: Colors.transparent),
                  ),
                  markdownTheme: _themeModel.isDark
                      ? MarkdownTheme.darkTheme
                      : MarkdownTheme.lightTheme,
                  preConfig: PreConfig(
                    theme: setEditorTheme(
                      _themeModel.isDark,
                      TextStyle(
                        color: _themeModel.themeData.itemFontColor,
                        backgroundColor:
                            _themeModel.themeData.scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      defaultExec: () {
        OpenFile.open(path);
      },
    );
  }

  Future<void> handleMove({
    required bool mounted,
  }) async {
    if (_fileModel.selectedFiles.isNotEmpty) {
      await for (var item in Stream.fromIterable(_fileModel.selectedFiles)) {
        String newPath = pathLib.join(
            _fileModel.currentDir!.path, pathLib.basename(item.entity.path));
        if (await File(newPath).exists() || await Directory(newPath).exists()) {
          Fluttertoast.showToast(
            msg: '$newPath ${AppLocalizations.of(context)!.fileExisted}',
          );

          continue;
        }

        await item.entity.rename(newPath).catchError((e, s) async {
          Fluttertoast.showToast(
            msg:
                '${AppLocalizations.of(context)!.rename}${AppLocalizations.of(context)!.error}',
          );
          await Sentry.captureException(
            e,
            stackTrace: s,
          );
        });
      }
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.setSuccess,
        );
        update2Side();
        await _fileModel.clearSelectedFiles();
        MixUtils.safePop(context);
      }
    }
  }

  Future<void> showRenameModal(
    BuildContext context,
    SelfFileEntity file,
  ) async {
    await createRenameModal(
      context,
      file,
      onExists: () {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.fileExisted,
        );
      },
      onSuccess: (val) async {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.setSuccess,
        );
        update2Side();
      },
      onError: (err) {
        Fluttertoast.showToast(
          msg: '${AppLocalizations.of(context)!.setFail} $err',
        );
      },
    );
  }

  Future<void> shareFile(BuildContext context, SelfFileEntity file) async {
    String path = file.entity.path;
    if (FsUtils.IMG_EXTS.contains(file.ext)) {
      await ShareExtend.share(path, 'image');
    } else if (FsUtils.VIDEO_EXTS.contains(file.ext)) {
      await ShareExtend.share(path, 'video');
    } else {
      await ShareExtend.share(path, 'file');
    }
  }

  Future<void> showCreateFileModal(BuildContext context) async {
    bool isRoot =
        pathLib.equals(_fileModel.rootDir!.path, _fileModel.currentDir!.path);

    return createFileModal(
      context,
      willCreateDir: !left || isRoot
          ? _fileModel.currentDir!.path
          : _fileModel.currentDir!.parent.path,
      onExists: () {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.fileExisted,
        );
      },
      onSuccess: (file) async {
        Fluttertoast.showToast(
            msg: '$file ${AppLocalizations.of(context)!.setSuccess}');
        await update2Side();
      },
      onError: (err) {
        Fluttertoast.showToast(
            msg: '${AppLocalizations.of(context)!.setFail} $err');
      },
    );
  }

  Future<void> removeModal(
    BuildContext context,
    SelfFileEntity file, {
    required Function(Directory) onChangeCurrentDir,
    required bool mounted,
  }) async {
    MixUtils.safePop(context);

    AquaTheme themeData = _themeModel.themeData;
    List<SelfFileEntity> selected = _fileModel.selectedFiles;
    bool confirmRm = false;

    showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return AquaDialog(
            actionPos: MainAxisAlignment.end,
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: NoResizeText(AppLocalizations.of(context)!.delete),
            action: true,
            children: <Widget>[
              confirmRm
                  ? loadingIndicator(context, _themeModel)
                  : NoResizeText(
                      '${AppLocalizations.of(context)!.delete} ${selected.length == 0 ? 1 : selected.length} ${AppLocalizations.of(context)!.files}?',
                    ),
              SizedBox(height: 10),
            ],
            onOk: () async {
              if (!confirmRm) {
                changeState(() {
                  confirmRm = true;
                });

                _fileModel.addSelectedFile(file);

                await for (var item in Stream.fromIterable(selected)) {
                  if (item.isDir) {
                    if (FileUtils.rm([item.entity.path],
                        recursive: true, directory: true, force: true)) {
                      //删除后 已经不存在了 交换一下
                      if (item.entity.path != _fileModel.rootDir!.path) {
                        onChangeCurrentDir(item.entity.parent);
                      }
                    }
                  } else {
                    await item.entity.delete();
                  }
                }
                if (mounted) {
                  await update2Side();
                  MixUtils.safePop(context);
                }
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.setSuccess);
                _fileModel.clearSelectedFiles();
              }
            },
            onCancel: () {
              MixUtils.safePop(context);
            },
          );
        });
      },
    );
  }

  Future<void> handleSelectedSingle(
    BuildContext context,
    SelfFileEntity file,
  ) async {
    if (isBeyondLimit(context)) {
      return;
    }

    if (mode == FileManagerMode.pick) {
      await _fileModel.addPickedFile(file);
    } else {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.target);
      await _fileModel.addSelectedFile(file);
    }

    MixUtils.safePop(context);
  }

  bool isBeyondLimit(BuildContext context) {
    if (mode == FileManagerMode.pick && selectLimit is int) {
      if (_fileModel.pickedFiles.length >= selectLimit!) {
        Fluttertoast.showToast(
            msg: '${AppLocalizations.of(context)!.selectLimit} $selectLimit');
        return true;
      }
    }
    return false;
  }

  Future<void> handleHozDragItem(SelfFileEntity file, double dir) async {
    if (mode == FileManagerMode.pick) {
      if (dir == 1) {
        if (isBeyondLimit(context)) {
          return;
        }
        await _fileModel.addPickedFile(file);
      } else if (dir == -1) {
        await _fileModel.removePickedFile(file);
      }
    } else {
      if (dir == 1) {
        await _fileModel.addSelectedFile(file, update: true);
      } else if (dir == -1) {
        await _fileModel.removeSelectedFile(file, update: true);
      }
    }
  }

  Future<void> handleExtractArchive(
    BuildContext context, {
    required bool mounted,
  }) async {
    bool result = false;
    if (_fileModel.selectedFiles.length > 1) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.onlyOneFile);
    } else {
      SelfFileEntity first = _fileModel.selectedFiles.first;
      String archivePath = first.entity.path;
      String name = FsUtils.getName(archivePath);
      if (Directory(pathLib.join(_fileModel.currentDir!.path, name))
          .existsSync()) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.duplicateFile);
        return;
      }

      switch (first.ext) {
        case '.zip':
          if (await Archive.isZipEncrypted(archivePath)) {
            await showSingleTextFieldModal(
              context,
              title: AppLocalizations.of(context)!.password,
              onOk: (val) async {
                showWaitForArchiveNotification(
                    AppLocalizations.of(context)!.decompressing);
                result = await Archive.unzip(
                    archivePath, _fileModel.currentDir!.path,
                    pwd: val);
              },
              onCancel: () {
                MixUtils.safePop(context);
              },
            );
          } else {
            showWaitForArchiveNotification(
                AppLocalizations.of(context)!.decompressing);
            result =
                await Archive.unzip(archivePath, _fileModel.currentDir!.path);
          }
          break;
        case '.tar':
          showWaitForArchiveNotification(
              AppLocalizations.of(context)!.decompressing);
          await Archive.extractArchive(
            archivePath,
            _fileModel.currentDir!.path,
            ArchiveFormat.tar,
          );
          break;
        case '.gz':
        case '.tgz':
          showWaitForArchiveNotification(
              AppLocalizations.of(context)!.decompressing);
          result = await Archive.extractArchive(
            archivePath,
            _fileModel.currentDir!.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.gzip,
          );
          break;
        case '.bz2':
        case '.tz2':
          showWaitForArchiveNotification(
              AppLocalizations.of(context)!.decompressing);
          result = await Archive.extractArchive(
            archivePath,
            _fileModel.currentDir!.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.bzip2,
          );
          break;
        case '.xz':
        case '.txz':
          showWaitForArchiveNotification(
              AppLocalizations.of(context)!.decompressing);
          result = await Archive.extractArchive(
            archivePath,
            _fileModel.currentDir!.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.xz,
          );
          break;
        case '.jar':
          showWaitForArchiveNotification(
              AppLocalizations.of(context)!.decompressing);
          result = await Archive.extractArchive(
            archivePath,
            _fileModel.currentDir!.path,
            ArchiveFormat.jar,
          );
          break;
      }
      LocalNotification.plugin?.cancel(0);
      if (result) {
        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.setSuccess);
      } else {
        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.setFail);
      }
      if (mounted) {
        await _fileModel.clearSelectedFiles();
        await update2Side();
        MixUtils.safePop(context);
      }
    }
  }

  Future<void> copyModal(
    BuildContext context, {
    required bool mounted,
  }) async {
    MixUtils.safePop(context);

    if (_fileModel.selectedFiles.isEmpty) {
      Fluttertoast.showToast(msg: AppLocalizations.of(context)!.noContent);
      return;
    }

    AquaTheme themeData = _themeModel.themeData;
    bool popAble = true;

    showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      semanticsDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) changeState) {
            return WillPopScope(
              onWillPop: () async {
                return popAble;
              },
              child: AquaDialog(
                fontColor: themeData.itemFontColor,
                bgColor: themeData.dialogBgColor,
                title: NoResizeText(AppLocalizations.of(context)!.paste),
                action: true,
                children: <Widget>[
                  SizedBox(height: 10),
                  popAble
                      ? ThemedText(AppLocalizations.of(context)!.pasteTip)
                      : loadingIndicator(context, _themeModel),
                  SizedBox(height: 10),
                ],
                defaultOkText: AppLocalizations.of(context)!.sure,
                onOk: () async {
                  // 粘贴时无法退出Modal
                  if (!popAble) {
                    return;
                  }
                  changeState(() {
                    popAble = false;
                  });

                  await for (var item
                      in Stream.fromIterable(_fileModel.selectedFiles)) {
                    String targetPath = pathLib.join(
                        _fileModel.currentDir!.path,
                        pathLib.basename(item.entity.path));
                    await FsUtils.copy(item, targetPath);
                  }
                  if (mounted) {
                    changeState(() {
                      popAble = true;
                    });
                    MixUtils.safePop(context);
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.setSuccess);
                    await _fileModel.clearSelectedFiles();
                    await update2Side();
                  }
                  return;
                },
                onCancel: () {
                  MixUtils.safePop(context);
                },
                actionPos: MainAxisAlignment.end,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showFileActionModal({
    required SelfFileEntity file,
    required Function(Directory) onChangeCurrentDir,
    required bool mounted,
  }) async {
    bool showSize = false;

    bool sharedNotEmpty = _fileModel.selectedFiles.isNotEmpty;

    if (_globalModel.isFileOptionPromptNotInit) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.copyDetails,
      );
      _globalModel.setFileOptionPromptInit(false);
    }

    await showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, changeState) {
          return SplitSelectionModal(
            topPanel: FileInfoCard(file: file, showSize: showSize),
            leftChildren: [
              ActionButton(
                content: AppLocalizations.of(context)!.create,
                onTap: () async {
                  await showCreateFileModal(context);
                },
              ),
              ActionButton(
                content: AppLocalizations.of(context)!.rename,
                onTap: () async {
                  await showRenameModal(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: AppLocalizations.of(context)!.archiveHere,
                  onTap: () async {
                    await showCreateArchiveModal(
                      context,
                      mounted: mounted,
                    );
                  },
                ),
              if (sharedNotEmpty)
                ActionButton(
                  content: AppLocalizations.of(context)!.moveHere,
                  onTap: () async {
                    await handleMove(mounted: mounted);
                  },
                ),
              ActionButton(
                content: AppLocalizations.of(context)!.delete,
                fontColor: Colors.redAccent,
                onTap: () async {
                  await removeModal(
                    context,
                    file,
                    mounted: mounted,
                    onChangeCurrentDir: onChangeCurrentDir,
                  );
                },
              ),
            ],
            rightChildren: <Widget>[
              ActionButton(
                content: AppLocalizations.of(context)!.selected,
                onTap: () {
                  handleSelectedSingle(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: AppLocalizations.of(context)!.copyHere,
                  onTap: () {
                    copyModal(context, mounted: mounted);
                  },
                ),
              ActionButton(
                content: AppLocalizations.of(context)!.details,
                onTap: () {
                  changeState(() {
                    showSize = true;
                  });
                },
              ),
              if (sharedNotEmpty &&
                  // 在判断下 不然移动下 sharedNotEmpty有问题
                  _fileModel.selectedFiles.length != 0 &&
                  FsUtils.ARCHIVE_EXTS
                      .contains(_fileModel.selectedFiles.first.ext))
                ActionButton(
                  content: AppLocalizations.of(context)!.extractHere,
                  onTap: () async {
                    await handleExtractArchive(context, mounted: mounted);
                  },
                ),
              if (file.isFile)
                ActionButton(
                  content: AppLocalizations.of(context)!.share,
                  onTap: () async {
                    await shareFile(context, file);
                  },
                ),
              ActionButton(
                content: AppLocalizations.of(context)!.moreOptions,
                onTap: () async {
                  if (file.isFile) {
                    await showMoreModal(context, file: file);
                    await update2Side();
                  } else {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.onlySupportFile);
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
