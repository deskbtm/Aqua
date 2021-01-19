import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_mix/android_mix.dart';
import 'package:android_mix/archive/enums.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:file_editor/editor_theme.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/file_info_card.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/isolate/airdrop.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/file_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_manager.dart';
import 'package:lan_file_more/page/file_manager/show_more.dart';
import 'package:lan_file_more/page/photo_viewer/photo_viewer.dart';
import 'package:lan_file_more/page/video/meida_info.dart';
import 'package:lan_file_more/page/video/video.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as pathLib;
import 'package:share_extend/share_extend.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'create_archive.dart';
import 'create_fiile.dart';
import 'create_rename.dart';
import 'file_utils.dart';

class FileActionUI {
  // final CommonModel commonModel;
  // final ThemeModel themeModel;
  final FileModel fileModel;
  final Function update2Side;
  final FileManagerMode mode;
  final int selectLimit;
  final bool left;

  FileActionUI({
    @required this.fileModel,
    @required this.left,
    // @required this.commonModel,
    // @required this.themeModel,
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

  void isolateSendFile(BuildContext context, SelfFileEntity file) async {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);

    IO.Socket socket = commonModel.socket;
    if (socket != null && socket.connected) {
      Map data = {
        'port': commonModel.filePort,
        'ip': commonModel.currentConnectIp,
        'filepath': file.entity.path,
        'filename': file.filename,
      };

      ReceivePort recPort = ReceivePort();
      SendPort sendPort = recPort.sendPort;
      Isolate isolate = await Isolate.spawn(isolateAirDrop, [sendPort, data]);
      showText('已送入快递站点');
      recPort.listen((message) {
        if (message == 'done') {
          showText('${file.filename} 收货成功');
          isolate?.kill();
        }
      });
    } else {
      showText('未发现设备, 请连接后在试');
    }
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
        showText('请选择提取路径');
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
          showText('$newPath 已存在 移动失败');
          continue;
        }

        await item.entity.rename(newPath).catchError((err) {
          showText('$err');
          FLog.error(text: '', methodName: 'handleMove');
        });
      }
      if (mounted) {
        showText('移动完成');
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
        showText('文件已存在');
      },
      onSuccess: (val) async {
        showText('$val 重命名成功');
        await update2Side();
      },
      onError: (err) {
        showText('重命名失败 $err');
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
        showText('已存在, 请重新命名');
      },
      onSuccess: (file) async {
        showText('$file 创建成功');
        await update2Side();
      },
      onError: (err) {
        showText('创建文件失败 $err');
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
    LanFileMoreTheme themeData = themeModel.themeData;
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
            title: NoResizeText('删除'),
            action: true,
            children: <Widget>[
              confirmRm
                  ? loadingIndicator(context, themeModel)
                  : NoResizeText(
                      '确定删除${selected.length == 0 ? 1 : selected.length}项?',
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
                showText('删除完成');
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
      showText('请选择目标目录');
      await commonModel.addSelectedFile(file);
    }

    MixUtils.safePop(context);
  }

  bool isBeyondLimit(BuildContext context) {
    CommonModel commonModel = Provider.of<CommonModel>(context, listen: false);
    if (mode == FileManagerMode.pick && selectLimit != null) {
      if (commonModel.pickedFiles.length >= selectLimit) {
        showText('选中数量不可超过 $selectLimit');
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
      showText('只允许操作单个文件');
    } else {
      SelfFileEntity first = commonModel.selectedFiles.first;
      String archivePath = first.entity.path;
      String name = LanFileUtils.getName(archivePath);
      if (Directory(pathLib.join(fileModel.currentDir.path, name))
          .existsSync()) {
        showText('目录重名, 请更换');
        return;
      }

      switch (first.ext) {
        case '.zip':
          if (await AndroidMix.archive.isZipEncrypted(archivePath)) {
            await showSingleTextFieldModal(
              context,
              title: '输入密码',
              onOk: (val) async {
                showWaitForArchiveNotification('解压中...');
                result = await AndroidMix.archive
                    .unzip(archivePath, fileModel.currentDir.path, pwd: val);
              },
              onCancel: () {
                MixUtils.safePop(context);
              },
            );
          } else {
            showWaitForArchiveNotification('解压中...');
            result = await AndroidMix.archive
                .unzip(archivePath, fileModel.currentDir.path);
          }
          break;
        case '.tar':
          showWaitForArchiveNotification('解压中...');
          await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
          );
          break;
        case '.gz':
        case '.tgz':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.gzip,
          );
          break;
        case '.bz2':
        case '.tz2':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.bzip2,
          );
          break;
        case '.xz':
        case '.txz':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.xz,
          );
          break;
        case '.jar':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            fileModel.currentDir.path,
            ArchiveFormat.jar,
          );
          break;
      }
      LocalNotification.plugin?.cancel(0);
      if (result) {
        showText('提取成功');
      } else {
        showText('提取失败');
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
      showText('无复制内容');
      return;
    }

    LanFileMoreTheme themeData = themeModel.themeData;
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
                title: NoResizeText('粘贴'),
                action: true,
                children: <Widget>[
                  SizedBox(height: 10),
                  popAble
                      ? LanText('确定粘贴?')
                      : loadingIndicator(context, themeModel),
                  SizedBox(height: 10),
                ],
                defaultOkText: '确定',
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
                    showText('粘贴完成');
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
        '可长按详情 复制内容',
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
              if (!(file.entity is Directory))
                ActionButton(
                  content: '内网快递',
                  onTap: () async {
                    if (!commonModel.isPurchased) {
                      showText('此功能为付费功能');
                      return;
                    }
                    isolateSendFile(context, file);
                  },
                ),
              ActionButton(
                content: '新建',
                onTap: () async {
                  await showCreateFileModal(context);
                },
              ),
              ActionButton(
                content: '重命名',
                onTap: () async {
                  await showRenameModal(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '归档到此',
                  onTap: () async {
                    await showCreateArchiveModal(
                      context,
                      mounted: mounted,
                    );
                  },
                ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '移动到此',
                  onTap: () async {
                    await handleMove(context, mounted: mounted);
                  },
                ),
              ActionButton(
                content: '删除',
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
                content: '选中',
                onTap: () {
                  handleSelectedSingle(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '复制到此',
                  onTap: () {
                    copyModal(context, mounted: mounted);
                  },
                ),
              ActionButton(
                content: '详情',
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
                  content: '提取到此',
                  onTap: () async {
                    await handleExtractArchive(context, mounted: mounted);
                  },
                ),
              if (file.isFile)
                ActionButton(
                  content: '分享',
                  onTap: () async {
                    await shareFile(context, file);
                  },
                ),
              ActionButton(
                content: '更多选项',
                onTap: () async {
                  if (file.isFile) {
                    await showMoreModal(context, file: file);
                    await update2Side();
                  } else {
                    showText('只支持文件');
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
