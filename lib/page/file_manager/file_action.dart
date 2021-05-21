import 'dart:io';
import 'dart:ui';
import 'package:android_mix/android_mix.dart';
import 'package:android_mix/archive/enums.dart';
import 'package:aqua/page/file_editor/editor_theme.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/dialog.dart';
import 'package:aqua/common/widget/file_info_card.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/show_modal.dart';
import 'package:aqua/external/bot_toast/src/toast.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/file_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/page/file_manager/show_more.dart';
import 'package:aqua/page/photo_viewer/photo_viewer.dart';
import 'package:aqua/page/video/meida_info.dart';
import 'package:aqua/page/video/video.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/utils/theme.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_extend/share_extend.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';
import 'create_archive.dart';
import 'create_rename.dart';
import 'create_fiile.dart';
import 'file_utils.dart';

class FileActionUI {
  final FileModel fileModel;
  final Function update2Side;
  final FileManagerMode mode;
  final int selectLimit;
  final bool left;

  FileActionUI({
    @required this.fileModel,
    @required this.left,
    @required this.update2Side,
    @required this.mode,
    @required this.selectLimit,
  });

  void showText(
    String content, {
    Duration duration = const Duration(seconds: 3),
    align: const Alignment(0, 0.8),
  }) {
    BotToast.showText(
      text: content,
      duration: duration,
      align: align,
    );
  }

  Future<void> showCreateArchiveModal(
    BuildContext context, {
    @required bool mounted,
  }) async {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    return createArchiveModal(
      context,
      // commonModel: commonModel,
      // themeModel: themeModel,
      currentDir: fileModel.currentDir,
      onSuccessUpdate: (context) async {
        if (mounted) {
          commonModel.clearSelectedFiles();
          await update2Side();
          MixUtils.safePop(context);
        }
      },
    );
  }

  void openFileActionByExt(
    BuildContext context,
    SelfFileEntity file, {
    int index = 0,
    @required List<SelfFileEntity> fileList,
    @required Function(bool) onChangePopLocker,
    @required Function(Function()) updateView,
  }) {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
    String path = file.entity.path;
    LanFileUtils.matchFileActionByExt(
      file.ext,
      caseImage: () async {
        List<String> images = LanFileUtils.filterImages(fileList);
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
        commonModel.clearSelectedFiles();
        commonModel.addSelectedFile(file);
        updateView(() {});
        showText(AppLocalizations.of(context).target);
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
                  markdownTheme: themeModel.isDark
                      ? MarkdownTheme.darkTheme
                      : MarkdownTheme.lightTheme,
                  preConfig: PreConfig(
                    theme: setEditorTheme(
                      themeModel.isDark,
                      TextStyle(
                        color: themeModel.themeData?.itemFontColor,
                        backgroundColor:
                            themeModel.themeData?.scaffoldBackgroundColor,
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

  Future<void> handleMove(
    BuildContext context, {
    @required bool mounted,
  }) async {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    if (commonModel.selectedFiles.isNotEmpty) {
      await for (var item in Stream.fromIterable(commonModel.selectedFiles)) {
        String newPath = pathLib.join(
            fileModel.currentDir.path, pathLib.basename(item.entity.path));
        if (await File(newPath).exists() || await Directory(newPath).exists()) {
          showText('$newPath ${AppLocalizations.of(context).fileExisted}');
          continue;
        }

        await item.entity.rename(newPath).catchError((e, s) async {
          showText(
              '${AppLocalizations.of(context).rename}${AppLocalizations.of(context).error}');
          await Sentry.captureException(
            e,
            stackTrace: s,
          );
        });
      }
      if (mounted) {
        showText(AppLocalizations.of(context).setSuccess);
        await update2Side();
        await commonModel.clearSelectedFiles();
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
        showText(AppLocalizations.of(context).fileExisted);
      },
      onSuccess: (val) async {
        showText('$val ${AppLocalizations.of(context).setSuccess}');
        await update2Side();
      },
      onError: (err) {
        showText('${AppLocalizations.of(context).setFail} $err');
      },
    );
  }

  Future<void> shareFile(BuildContext context, SelfFileEntity file) async {
    String path = file.entity.path;
    if (LanFileUtils.IMG_EXTS.contains(file.ext)) {
      await ShareExtend.share(path, 'image');
    } else if (LanFileUtils.VIDEO_EXTS.contains(file.ext)) {
      await ShareExtend.share(path, 'video');
    } else {
      await ShareExtend.share(path, 'file');
    }
  }

  Future<void> showCreateFileModal(BuildContext context) async {
    bool isRoot =
        pathLib.equals(fileModel.rootDir.path, fileModel.currentDir.path);

    return createFileModal(
      context,
      willCreateDir: !left || isRoot
          ? fileModel.currentDir.path
          : fileModel.currentDir.parent.path,
      onExists: () {
        showText(AppLocalizations.of(context).fileExisted);
      },
      onSuccess: (file) async {
        showText('$file ${AppLocalizations.of(context).setSuccess}');
        await update2Side();
      },
      onError: (err) {
        showText('${AppLocalizations.of(context).setFail} $err');
      },
    );
  }

  Future<void> removeModal(
    BuildContext context,
    SelfFileEntity file, {
    @required Function(Directory) onChangeCurrentDir,
    @required bool mounted,
  }) async {
    MixUtils.safePop(context);
    ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    AquaTheme themeData = themeModel.themeData;
    List<SelfFileEntity> selected = commonModel.selectedFiles;
    bool confirmRm = false;

    showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            actionPos: MainAxisAlignment.end,
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: NoResizeText(AppLocalizations.of(context).delete),
            action: true,
            children: <Widget>[
              confirmRm
                  ? loadingIndicator(context, themeModel)
                  : NoResizeText(
                      '${AppLocalizations.of(context).delete} ${selected.length == 0 ? 1 : selected.length} ${AppLocalizations.of(context).files}?',
                    ),
              SizedBox(height: 10),
            ],
            onOk: () async {
              if (!confirmRm) {
                changeState(() {
                  confirmRm = true;
                });

                commonModel.addSelectedFile(file);

                await for (var item in Stream.fromIterable(selected)) {
                  if (item.isDir) {
                    if (FileUtils.rm([item.entity.path],
                        recursive: true, directory: true, force: true)) {
                      //删除后 已经不存在了 交换一下
                      if (item.entity.path != fileModel.rootDir.path) {
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
                showText(AppLocalizations.of(context).setSuccess);
                commonModel.clearSelectedFiles();
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

    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);

    if (mode == FileManagerMode.pick) {
      await commonModel.addPickedFile(file);
    } else {
      showText(AppLocalizations.of(context).target);
      await commonModel.addSelectedFile(file);
    }

    MixUtils.safePop(context);
  }

  bool isBeyondLimit(BuildContext context) {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    if (mode == FileManagerMode.pick && selectLimit != null) {
      if (commonModel.pickedFiles.length >= selectLimit) {
        showText('${AppLocalizations.of(context).selectLimit} $selectLimit');
        return true;
      }
    }
    return false;
  }

  Future<void> handleHozDragItem(
      BuildContext context, SelfFileEntity file, double dir) async {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    if (mode == FileManagerMode.pick) {
      if (dir == 1) {
        if (isBeyondLimit(context)) {
          return;
        }
        await commonModel.addPickedFile(file);
      } else if (dir == -1) {
        await commonModel.removePickedFile(file);
      }
    } else {
      if (dir == 1) {
        await commonModel.addSelectedFile(file);
      } else if (dir == -1) {
        await commonModel.removeSelectedFile(file);
      }
    }
  }

  Future<void> handleExtractArchive(
    BuildContext context, {
    @required bool mounted,
  }) async {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    bool result = false;
    if (commonModel.selectedFiles.length > 1) {
      showText(AppLocalizations.of(context).onlyOneFile);
    } else {
      SelfFileEntity first = commonModel.selectedFiles.first;
      String archivePath = first.entity.path;
      String name = LanFileUtils.getName(archivePath);
      if (Directory(pathLib.join(fileModel.currentDir.path, name))
          .existsSync()) {
        showText(AppLocalizations.of(context).duplicateFile);
        return;
      }

      switch (first.ext) {
        case '.zip':
          if (await AndroidMix.archive.isZipEncrypted(archivePath)) {
            await showSingleTextFieldModal(
              context,
              title: AppLocalizations.of(context).password,
              onOk: (val) async {
                showWaitForArchiveNotification(
                    AppLocalizations.of(context).decompressing);
                result = await AndroidMix.archive
                    .unzip(archivePath, fileModel.currentDir.path, pwd: val);
              },
              onCancel: () {
                MixUtils.safePop(context);
              },
            );
          } else {
            showWaitForArchiveNotification(
                AppLocalizations.of(context).decompressing);
            result = await AndroidMix.archive
                .unzip(archivePath, fileModel.currentDir.path);
          }
          break;
        case '.tar':
          showWaitForArchiveNotification(
              AppLocalizations.of(context).decompressing);
          await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
          );
          break;
        case '.gz':
        case '.tgz':
          showWaitForArchiveNotification(
              AppLocalizations.of(context).decompressing);
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.gzip,
          );
          break;
        case '.bz2':
        case '.tz2':
          showWaitForArchiveNotification(
              AppLocalizations.of(context).decompressing);
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.bzip2,
          );
          break;
        case '.xz':
        case '.txz':
          showWaitForArchiveNotification(
              AppLocalizations.of(context).decompressing);
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.xz,
          );
          break;
        case '.jar':
          showWaitForArchiveNotification(
              AppLocalizations.of(context).decompressing);
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.jar,
          );
          break;
      }
      LocalNotification.plugin?.cancel(0);
      if (result) {
        showText(AppLocalizations.of(context).setSuccess);
      } else {
        showText(AppLocalizations.of(context).setFail);
      }
      if (mounted) {
        await commonModel.clearSelectedFiles();
        await update2Side();
        MixUtils.safePop(context);
      }
    }
  }

  Future<void> copyModal(
    BuildContext context, {
    @required bool mounted,
  }) async {
    MixUtils.safePop(context);
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);

    if (commonModel.selectedFiles.isEmpty) {
      showText(AppLocalizations.of(context).noContent);
      return;
    }

    AquaTheme themeData = themeModel.themeData;
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
              child: LanDialog(
                fontColor: themeData.itemFontColor,
                bgColor: themeData.dialogBgColor,
                title: NoResizeText(AppLocalizations.of(context).paste),
                action: true,
                children: <Widget>[
                  SizedBox(height: 10),
                  popAble
                      ? LanText(AppLocalizations.of(context).pasteTip)
                      : loadingIndicator(context, themeModel),
                  SizedBox(height: 10),
                ],
                defaultOkText: AppLocalizations.of(context).sure,
                onOk: () async {
                  // 粘贴时无法退出Modal
                  if (!popAble) {
                    return;
                  }
                  changeState(() {
                    popAble = false;
                  });

                  await for (var item
                      in Stream.fromIterable(commonModel.selectedFiles)) {
                    String targetPath = pathLib.join(fileModel.currentDir.path,
                        pathLib.basename(item.entity.path));
                    await LanFileUtils.copy(item, targetPath);
                  }
                  if (mounted) {
                    changeState(() {
                      popAble = true;
                    });
                    MixUtils.safePop(context);
                    showText(AppLocalizations.of(context).setSuccess);
                    await commonModel.clearSelectedFiles();
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

  Future<void> showFileActionModal(
    BuildContext context, {
    @required SelfFileEntity file,
    @required Function(Directory) onChangeCurrentDir,
    @required bool mounted,
  }) async {
    bool showSize = false;
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    bool sharedNotEmpty = commonModel.selectedFiles.isNotEmpty;

    if (commonModel.isFileOptionPromptNotInit) {
      showText(
        AppLocalizations.of(context).copyDetails,
        duration: Duration(seconds: 4),
        align: const Alignment(0, 0),
      );
      commonModel.setFileOptionPromptInit(false);
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
                content: AppLocalizations.of(context).create,
                onTap: () async {
                  await showCreateFileModal(context);
                },
              ),
              ActionButton(
                content: AppLocalizations.of(context).rename,
                onTap: () async {
                  await showRenameModal(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: AppLocalizations.of(context).archiveHere,
                  onTap: () async {
                    await showCreateArchiveModal(
                      context,
                      mounted: mounted,
                    );
                  },
                ),
              if (sharedNotEmpty)
                ActionButton(
                  content: AppLocalizations.of(context).moveHere,
                  onTap: () async {
                    await handleMove(context, mounted: mounted);
                  },
                ),
              ActionButton(
                content: AppLocalizations.of(context).delete,
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
                content: AppLocalizations.of(context).selected,
                onTap: () {
                  handleSelectedSingle(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: AppLocalizations.of(context).copyHere,
                  onTap: () {
                    copyModal(context, mounted: mounted);
                  },
                ),
              ActionButton(
                content: AppLocalizations.of(context).details,
                onTap: () {
                  changeState(() {
                    showSize = true;
                  });
                },
              ),
              if (sharedNotEmpty &&
                  // 在判断下 不然移动下 sharedNotEmpty有问题
                  commonModel.selectedFiles.length != 0 &&
                  LanFileUtils.ARCHIVE_EXTS
                      .contains(commonModel.selectedFiles.first.ext))
                ActionButton(
                  content: AppLocalizations.of(context).extractHere,
                  onTap: () async {
                    await handleExtractArchive(context, mounted: mounted);
                  },
                ),
              if (file.isFile)
                ActionButton(
                  content: AppLocalizations.of(context).share,
                  onTap: () async {
                    await shareFile(context, file);
                  },
                ),
              ActionButton(
                content: AppLocalizations.of(context).moreOptions,
                onTap: () async {
                  if (file.isFile) {
                    await showMoreModal(context, file: file);
                    await update2Side();
                  } else {
                    showText(AppLocalizations.of(context).onlySupportFile);
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
