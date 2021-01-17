import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:device_info/device_info.dart';
import 'package:file_editor/editor_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:android_mix/android_mix.dart';
import 'package:android_mix/archive/enums.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/file_info_card.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/common/widget/storage_card.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/external/back_button_interceptor/back_button_interceptor.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/external/breadcrumb/src/breadcrumb.dart';
import 'package:lan_file_more/external/breadcrumb/src/breadcrumb_item.dart';
import 'package:lan_file_more/isolate/airdrop.dart';
import 'package:lan_file_more/model/file_model.dart';
import 'package:lan_file_more/page/file_manager/create_archive.dart';
import 'package:lan_file_more/page/file_manager/create_fiile.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_list_view.dart';
import 'package:lan_file_more/page/file_manager/file_utils.dart';
import 'package:lan_file_more/page/installed_apps/installed_apps.dart';
import 'package:lan_file_more/page/lan/code_server/utils.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/photo_viewer/photo_viewer.dart';
import 'package:lan_file_more/page/video/meida_info.dart';
import 'package:lan_file_more/page/video/video.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:file_utils/file_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'package:share_extend/share_extend.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:markdown_widget/markdown_widget.dart';
import 'create_search.dart';
import 'show_more.dart';

enum FileManagerMode {
  surf,
  pick,
}

class FileManagerPage extends StatefulWidget {
  final String appointPath;
  final Widget Function(BuildContext) trailingBuilder;
  final int selectLimit;
  final FileManagerMode mode;

  ///  * [appointPath] 默认外存的根目录
  const FileManagerPage({
    Key key,
    this.appointPath,
    this.selectLimit = 1,
    this.trailingBuilder,
    @required this.mode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileManagerPageState();
  }
}

class _FileManagerPageState extends State<FileManagerPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  ThemeModel _themeModel;
  CommonModel _commonModel;
  FileModel _fileModel;

  GlobalKey<SplitSelectionModalState> _modalKey;
  List<SelfFileEntity> _leftFileList;
  List<SelfFileEntity> _rightFileList;
  Directory _currentDir;
  Directory _rootDir;
  bool _useSandboxDir;
  bool _initMutex;
  bool _popLocker;
  double _totalSize;
  double _validSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _leftFileList = [];
    _rightFileList = [];
    _currentDir = null;
    _initMutex = true;
    _useSandboxDir = false;
    _popLocker = false;
    _totalSize = 0;
    _validSize = 0;

    WidgetsBinding.instance.addObserver(this);
    _modalKey = GlobalKey<SplitSelectionModalState>();
    BackButtonInterceptor.add(_willPopFileRoute);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    _fileModel = Provider.of<FileModel>(context);
    if (_initMutex) {
      _initMutex = false;
      String initialPath;
      if (widget.mode == FileManagerMode.surf || widget.appointPath == null) {
        await _fileModel.init();
        initialPath = _commonModel.storageRootPath;
      } else {
        initialPath = widget.appointPath;
      }

      log("file-root_path ========= $initialPath");
      await _changeRootPath(initialPath);
      await getValidAndTotalStorageSize();
    }
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    BackButtonInterceptor.remove(_willPopFileRoute);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //切回来刷新下
    if (state == AppLifecycleState.resumed) {
      if (mounted) update2Side();
    }
  }

  Future<void> getValidAndTotalStorageSize() async {
    _totalSize = await AndroidMix.storage.getTotalExternalStorageSize;
    _validSize = await AndroidMix.storage.getValidExternalStorageSize;
  }

  Future<List<SelfFileEntity>> readdir(Directory dir) async {
    if (pathLib.isWithin(_rootDir.path, dir.path) ||
        pathLib.equals(_rootDir.path, dir.path)) {
      SelfFileList result = await FileAction.readdir(
        dir,
        sortType: _fileModel.sortType,
        showHidden: _fileModel.isDisplayHidden,
        reversed: _fileModel.sortReversed,
      ).catchError((err) async {
        String errorString = err.toString().toLowerCase();
        bool overAndroid11 =
            int.parse((await DeviceInfoPlugin().androidInfo).version.release) >=
                11;

        if (errorString.contains('permission') &&
            errorString.contains('denied')) {
          showTipTextModal(
            context,
            _themeModel,
            title: '错误',
            tip: (overAndroid11) ? '安卓11以上data / obb 没有权限' : '没有该目录权限',
            onCancel: null,
          );
        }
        recordError(
          text: '',
          exception: err,
          methodName: 'readdir',
          className: 'FileManager',
        );
      });

      switch (_fileModel.showOnlyType) {
        case ShowOnlyType.all:
          return result?.allList ?? [];
        case ShowOnlyType.file:
          return result?.fileList ?? [];
        case ShowOnlyType.folder:
          return result?.folderList ?? [];
        case ShowOnlyType.link:
          return result?.linkList ?? [];
        default:
          return result?.allList ?? [];
      }
    } else {
      return [];
    }
  }

  Future<void> _changeRootPath(String path) async {
    _rootDir = Directory(path);
    _currentDir = _rootDir;
    _leftFileList = await readdir(_currentDir);
    _rightFileList = [];
    if (mounted) setState(() {});
  }

  Future<void> _clearAllSelected(BuildContext context) async {
    await _commonModel.clearSelectedFiles();

    if (mounted) {
      setState(() {});
      showText('已取消全部选中');
      MixUtils.safePop(context);
    }
  }

  Future<void> _showMoreOptions(BuildContext context) async {
    showCupertinoModal(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, changeState) {
          return SplitSelectionModal(
            key: _modalKey,
            topPanel: StorageCard(
              validSize: _validSize,
              totalSize: _totalSize,
            ),
            leftChildren: [
              ActionButton(
                content: '取消全部选中',
                onTap: () async {
                  await _clearAllSelected(context);
                },
              ),
              ActionButton(
                content: _fileModel.isDisplayHidden ? '不显示隐藏' : '显示隐藏文件',
                onTap: () async {
                  if (mounted) {
                    await _fileModel
                        .setDisplayHidden(!_fileModel.isDisplayHidden);
                    MixUtils.safePop(context);
                    await update2Side();
                  }
                },
              ),
              ActionButton(
                content: _useSandboxDir ? '切换系统目录' : '切换沙盒目录',
                onTap: changeSandboxDir,
              ),
              ActionButton(
                content: '排序方式',
                onTap: () {
                  insertSortOptions(context);
                },
              ),
              ActionButton(
                content: '本机应用',
                onTap: () {
                  MixUtils.safePop(context);
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      maintainState: false,
                      builder: (BuildContext context) {
                        return InstalledAppsPage();
                      },
                    ),
                  );
                },
              ),
              ActionButton(
                content: '过滤类型',
                onTap: () {
                  _filterType(context);
                },
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _filterType(BuildContext context) async {
    _modalKey.currentState?.insertRightCol([
      ActionButton(
        content: '显示全部',
        onTap: () {
          _fileModel.setShowOnlyType(ShowOnlyType.all);
          update2Side();
          MixUtils.safePop(context);
        },
      ),
      ActionButton(
        content: '只显示文件夹',
        onTap: () {
          _fileModel.setShowOnlyType(ShowOnlyType.folder);
          update2Side();
          MixUtils.safePop(context);
        },
      ),
      ActionButton(
        content: '只显示文件',
        onTap: () {
          _fileModel.setShowOnlyType(ShowOnlyType.file);
          update2Side();
          MixUtils.safePop(context);
        },
      ),
      ActionButton(
        content: '只显示链接',
        onTap: () {
          _fileModel.setShowOnlyType(ShowOnlyType.link);
          update2Side();
          MixUtils.safePop(context);
        },
      ),
    ]);
  }

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

  // Future<void> showRenameModal(
  //     BuildContext context, SelfFileEntity file) async {
  //   await createRenameModal(
  //     context,
  //     file,
  //     provider: _themeModel,
  //     onExists: () {
  //       showText('文件已存在');
  //     },
  //     onSuccess: (val) async {
  //       showText('$val 重命名成功');
  //       await update2Side();
  //     },
  //     onError: (err) {
  //       showText('重命名失败 $err');
  //     },
  //   );
  // }

  // Future<void> handleMove(BuildContext context) async {
  //   if (_commonModel.selectedFiles.isNotEmpty) {
  //     await for (var item in Stream.fromIterable(_commonModel.selectedFiles)) {
  //       String newPath =
  //           pathLib.join(_currentDir.path, pathLib.basename(item.entity.path));
  //       if (await File(newPath).exists() || await Directory(newPath).exists()) {
  //         showText('$newPath 已存在 移动失败');
  //         continue;
  //       }

  //       await item.entity.rename(newPath).catchError((err) {
  //         showText('$err');
  //         recordError(text: '', methodName: 'handleMove');
  //       });
  //     }
  //     if (mounted) {
  //       showText('移动完成');
  //       await update2Side();
  //       await _commonModel.clearSelectedFiles();
  //       MixUtils.safePop(context);
  //     }
  //   }
  // }

  // bool _isBeyondLimit() {
  //   if (widget.mode == FileManagerMode.pick && widget.selectLimit != null) {
  //     if (_commonModel.pickedFiles.length >= widget.selectLimit) {
  //       showText('选中数量不可超过 ${widget.selectLimit}');
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  // Future<void> handleSelectedSingle(BuildContext context, SelfFileEntity file,
  //     {Function(bool) updateItem}) async {
  //   if (_isBeyondLimit()) {
  //     return;
  //   }

  //   if (widget.mode == FileManagerMode.pick) {
  //     await _commonModel.addPickedFile(file);
  //   } else {
  //     showText('请选择目标目录');
  //     await _commonModel.addSelectedFile(file);
  //   }

  //   // updateItem(true);
  //   MixUtils.safePop(context);
  // }

  // Future<void> handleHozDragItem(
  //     int index, double dir, List<SelfFileEntity> list) async {
  //   SelfFileEntity file = list[index];
  //   if (widget.mode == FileManagerMode.pick) {
  //     if (dir == 1) {
  //       if (isBeyondLimit()) {
  //         return;
  //       }
  //       await _commonModel.addPickedFile(file);
  //     } else if (dir == -1) {
  //       await _commonModel.removePickedFile(file);
  //     }
  //   } else {
  //     if (dir == 1) {
  //       await _commonModel.addSelectedFile(file);
  //     } else if (dir == -1) {
  //       await _commonModel.removeSelectedFile(file);
  //     }
  //   }
  // }

  // Future<void> copyModal(BuildContext context) async {
  //   MixUtils.safePop(context);
  //   if (_commonModel.selectedFiles.isEmpty) {
  //     showText('无复制内容');
  //     return;
  //   }

  //   LanFileMoreTheme themeData = _themeModel.themeData;
  //   bool popAble = true;

  //   showCupertinoModal(
  //     context: context,
  //     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  //     semanticsDismissible: true,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (BuildContext context,
  //             void Function(void Function()) changeState) {
  //           return WillPopScope(
  //             onWillPop: () async {
  //               return popAble;
  //             },
  //             child: LanDialog(
  //               fontColor: themeData.itemFontColor,
  //               bgColor: themeData.dialogBgColor,
  //               title: NoResizeText('粘贴'),
  //               action: true,
  //               children: <Widget>[
  //                 SizedBox(height: 10),
  //                 popAble
  //                     ? LanText('确定粘贴?')
  //                     : loadingIndicator(context, _themeModel),
  //                 SizedBox(height: 10),
  //               ],
  //               defaultOkText: '确定',
  //               onOk: () async {
  //                 // 粘贴时无法退出Modal
  //                 if (!popAble) {
  //                   return;
  //                 }
  //                 changeState(() {
  //                   popAble = false;
  //                 });

  //                 await for (var item
  //                     in Stream.fromIterable(_commonModel.selectedFiles)) {
  //                   String targetPath = pathLib.join(
  //                       _currentDir.path, pathLib.basename(item.entity.path));
  //                   await FileAction.copy(item, targetPath);
  //                 }
  //                 if (mounted) {
  //                   changeState(() {
  //                     popAble = true;
  //                   });
  //                   MixUtils.safePop(context);
  //                   showText('粘贴完成');
  //                   await _commonModel.clearSelectedFiles();
  //                   await update2Side();
  //                 }
  //                 return;
  //               },
  //               onCancel: () {
  //                 MixUtils.safePop(context);
  //               },
  //               actionPos: MainAxisAlignment.end,
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // Future<void> removeModal(BuildContext context, SelfFileEntity file,
  //     {Function(bool) updateItem}) async {
  //   MixUtils.safePop(context);
  //   LanFileMoreTheme themeData = _themeModel.themeData;
  //   List selected = _commonModel.selectedFiles;
  //   bool confirmRm = false;

  //   showCupertinoModal(
  //     context: context,
  //     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(builder:
  //           (BuildContext context, void Function(void Function()) changeState) {
  //         return LanDialog(
  //           actionPos: MainAxisAlignment.end,
  //           fontColor: themeData.itemFontColor,
  //           bgColor: themeData.dialogBgColor,
  //           title: NoResizeText('删除'),
  //           action: true,
  //           children: <Widget>[
  //             confirmRm
  //                 ? loadingIndicator(context, _themeModel)
  //                 : NoResizeText(
  //                     '确定删除${selected.length == 0 ? 1 : selected.length}项?',
  //                   ),
  //             SizedBox(height: 10),
  //           ],
  //           onOk: () async {
  //             if (!confirmRm) {
  //               changeState(() {
  //                 confirmRm = true;
  //               });

  //               _commonModel.addSelectedFile(file);
  //               // updateItem(true);
  //               await for (var item in Stream.fromIterable(selected)) {
  //                 if (item.isDir) {
  //                   if (FileUtils.rm([item.entity.path],
  //                       recursive: true, directory: true, force: true)) {
  //                     //删除后 已经不存在了 交换一下
  //                     if (item.entity.path != _rootDir.path) {
  //                       _currentDir = item.entity.parent;
  //                     }
  //                   }
  //                 } else {
  //                   await item.entity.delete();
  //                 }
  //               }
  //               if (mounted) {
  //                 await update2Side();
  //                 MixUtils.safePop(context);
  //               }
  //               showText('删除完成');
  //               _commonModel.clearSelectedFiles();
  //             }
  //           },
  //           onCancel: () {
  //             MixUtils.safePop(context);
  //           },
  //         );
  //       });
  //     },
  //   );
  // }

  // Future<void> showCreateFileModal(BuildContext context,
  //     {bool left = false}) async {
  //   createFileModal(
  //     context,
  //     provider: _themeModel,
  //     willCreateDir: left ? _currentDir.parent.path : _currentDir.path,
  //     onExists: () {
  //       showText('已存在, 请重新命名');
  //     },
  //     onSuccess: (file) async {
  //       showText('$file 创建成功');
  //       await update2Side();
  //     },
  //     onError: (err) {
  //       showText('创建文件失败 $err');
  //     },
  //   );
  // }

  // Future<void> showCreateArchiveModal(
  //   BuildContext context,
  // ) async {
  //   createArchiveModal(
  //     context,
  //     commonProvider: _commonModel,
  //     themeProvider: _themeModel,
  //     currentDir: _currentDir,
  //     onSuccessUpdate: (context) async {
  //       if (mounted) {
  //         _commonModel.clearSelectedFiles();
  //         await update2Side();
  //         MixUtils.safePop(context);
  //       }
  //     },
  //   );
  // }

  // Future<void> shareFile(BuildContext context, SelfFileEntity file) async {
  //   String path = file.entity.path;
  //   if (LanFileUtils.IMG_EXTS.contains(file.ext)) {
  //     await ShareExtend.share(path, 'image');
  //   } else if (LanFileUtils.VIDEO_EXTS.contains(file.ext)) {
  //     await ShareExtend.share(path, 'video');
  //   } else {
  //     await ShareExtend.share(path, 'file');
  //   }
  // }

  Future<void> insertSortOptions(BuildContext context) async {
    _modalKey.currentState.insertRightCol([
      ActionButton(
        content: '正序',
        fontColor: Colors.pink,
        onTap: () async {
          await _fileModel.setSortReversed(false);
          MixUtils.safePop(context);
          await update2Side();
        },
      ),
      ActionButton(
        content: '倒序',
        fontColor: Colors.yellow,
        onTap: () async {
          await _fileModel.setSortReversed(true);
          MixUtils.safePop(context);
          await update2Side();
        },
      ),
      ActionButton(
        content: '名称',
        fontColor: Colors.lightBlue,
        onTap: () async {
          await _fileModel.setSortType(SORT_CASE);
          MixUtils.safePop(context);
          await update2Side();
        },
      ),
      ActionButton(
        content: '大小',
        fontColor: Colors.blueAccent,
        onTap: () async {
          if (mounted) {
            await _fileModel.setSortType(SORT_SIZE);
            MixUtils.safePop(context);
            await update2Side();
          }
        },
      ),
      ActionButton(
        content: '修改日期',
        fontColor: Colors.cyanAccent,
        onTap: () async {
          await _fileModel.setSortType(SORT_MODIFIED);
          MixUtils.safePop(context);
          await update2Side();
        },
      ),
      ActionButton(
        content: '类型',
        fontColor: Colors.teal,
        onTap: () async {
          await _fileModel.setSortType(SORT_TYPE);
          MixUtils.safePop(context);
          await update2Side();
        },
      ),
    ]);
  }

  Future<void> changeSandboxDir() async {
    CodeSrvUtils cutils = await CodeSrvUtils().init();
    Directory rootfs = Directory('${cutils.filesPath}/rootfs');
    _useSandboxDir = !_useSandboxDir;
    if (_useSandboxDir) {
      if (await rootfs.exists()) {
        _commonModel.setStorageRootPath(rootfs.path);
      } else {
        showText('沙盒不存在');
        return;
      }
    } else {
      String path = await MixUtils.getExternalRootPath();
      _commonModel.setStorageRootPath(path);
    }
    showText('切换完成');

    await _changeRootPath(_commonModel.storageRootPath);

    _modalKey.currentState?.replaceLeft(2, [
      ActionButton(
        content: _useSandboxDir ? '切换沙盒目录' : '切换系统目录',
        onTap: () async {
          if (mounted) {
            await changeSandboxDir();
          }
        },
      )
    ]);
    MixUtils.safePop(context);
  }

  // Future<void> handleExtractArchive(BuildContext context) async {
  //   bool result = false;

  //   if (_commonModel.selectedFiles.length > 1) {
  //     showText('只允许操作单个文件');
  //   } else {
  //     SelfFileEntity first = _commonModel.selectedFiles.first;
  //     String archivePath = first.entity.path;
  //     String name = FileAction.getName(archivePath);
  //     if (Directory(pathLib.join(_currentDir.path, name)).existsSync()) {
  //       showText('目录重名, 请更换');
  //       return;
  //     }

  //     switch (first.ext) {
  //       case '.zip':
  //         if (await AndroidMix.archive.isZipEncrypted(archivePath)) {
  //           await showSingleTextFieldModal(
  //             context,
  //             _themeModel,
  //             title: '输入密码',
  //             onOk: (val) async {
  //               showWaitForArchiveNotification('解压中...');
  //               result = await AndroidMix.archive
  //                   .unzip(archivePath, _currentDir.path, pwd: val);
  //             },
  //             onCancel: () {
  //               MixUtils.safePop(context);
  //             },
  //           );
  //         } else {
  //           showWaitForArchiveNotification('解压中...');
  //           result =
  //               await AndroidMix.archive.unzip(archivePath, _currentDir.path);
  //         }
  //         break;
  //       case '.tar':
  //         showWaitForArchiveNotification('解压中...');
  //         await AndroidMix.archive.extractArchive(
  //           archivePath,
  //           _currentDir.path,
  //           ArchiveFormat.tar,
  //         );
  //         break;
  //       case '.gz':
  //       case '.tgz':
  //         showWaitForArchiveNotification('解压中...');
  //         result = await AndroidMix.archive.extractArchive(
  //           archivePath,
  //           _currentDir.path,
  //           ArchiveFormat.tar,
  //           compressionType: CompressionType.gzip,
  //         );
  //         break;
  //       case '.bz2':
  //       case '.tz2':
  //         showWaitForArchiveNotification('解压中...');
  //         result = await AndroidMix.archive.extractArchive(
  //           archivePath,
  //           _currentDir.path,
  //           ArchiveFormat.tar,
  //           compressionType: CompressionType.bzip2,
  //         );
  //         break;
  //       case '.xz':
  //       case '.txz':
  //         showWaitForArchiveNotification('解压中...');
  //         result = await AndroidMix.archive.extractArchive(
  //           archivePath,
  //           _currentDir.path,
  //           ArchiveFormat.tar,
  //           compressionType: CompressionType.xz,
  //         );
  //         break;
  //       case '.jar':
  //         showWaitForArchiveNotification('解压中...');
  //         result = await AndroidMix.archive.extractArchive(
  //           archivePath,
  //           _currentDir.path,
  //           ArchiveFormat.jar,
  //         );
  //         break;
  //     }
  //     LocalNotification.plugin?.cancel(0);
  //     if (result) {
  //       showText('提取成功');
  //     } else {
  //       showText('提取失败');
  //     }
  //     if (mounted) {
  //       await _commonModel.clearSelectedFiles();
  //       await update2Side();
  //       MixUtils.safePop(context);
  //     }
  //   }
  // }

  // void isolateSendFile(SelfFileEntity file) async {
  //   IO.Socket socket = _commonModel.socket;
  //   if (socket != null && socket.connected) {
  //     Map data = {
  //       'port': _commonModel.filePort,
  //       'ip': _commonModel.currentConnectIp,
  //       'filepath': file.entity.path,
  //       'filename': file.filename,
  //     };

  //     ReceivePort recPort = ReceivePort();
  //     SendPort sendPort = recPort.sendPort;
  //     Isolate isolate = await Isolate.spawn(isolateAirDrop, [sendPort, data]);
  //     showText('已送入快递站点');
  //     recPort.listen((message) {
  //       if (message == 'done') {
  //         showText('${file.filename} 收货成功');
  //         isolate?.kill();
  //       }
  //     });
  //   } else {
  //     showText('未发现设备, 请连接后在试');
  //   }
  // }

  // Future<void> _showOptionsWhenPressedEmpty(BuildContext context,
  //     {bool left = false}) async {
  //   bool sharedNotEmpty = _commonModel.selectedFiles.isNotEmpty;
  //   showCupertinoModal(
  //     context: context,
  //     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  //     builder: (BuildContext context) {
  //       return SplitSelectionModal(
  //         leftChildren: <Widget>[
  //           if (sharedNotEmpty)
  //             ActionButton(
  //               content: '归档到此',
  //               onTap: () async {
  //                 await showCreateArchiveModal(context);
  //               },
  //             ),
  //           if (sharedNotEmpty)
  //             ActionButton(
  //               content: '移动到此',
  //               onTap: () async {
  //                 await handleMove(context);
  //               },
  //             ),
  //         ],
  //         rightChildren: <Widget>[
  //           if (sharedNotEmpty) ...[
  //             ActionButton(
  //               content: '复制到此',
  //               onTap: () {
  //                 copyModal(context);
  //               },
  //             ),
  //             ActionButton(
  //               content: '提取到此',
  //               onTap: () async {
  //                 // await handleExtractArchive(context);
  //               },
  //             ),
  //           ],
  //           ActionButton(
  //             content: '新建',
  //             onTap: () {
  //               showCreateFileModal(context, left: left);
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Future<void> _showFileOptionsModal({SelfFileEntity file}) async {
  //   bool showSize = false;
  //   bool sharedNotEmpty = _commonModel.selectedFiles.isNotEmpty;

  //   if (_commonModel.isFileOptionPromptNotInit) {
  //     showText(
  //       '可长按详情 复制内容',
  //       duration: Duration(seconds: 4),
  //       align: const Alignment(0, 0),
  //     );
  //     _commonModel.setFileOptionPromptInit(false);
  //   }

  //   await showCupertinoModal(
  //     context: context,
  //     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(builder: (context, changeState) {
  //         return SplitSelectionModal(
  //           topPanel: FileInfoCard(file: file, showSize: showSize),
  //           leftChildren: [
  //             if (!(file.entity is Directory))
  //               ActionButton(
  //                 content: '内网快递',
  //                 onTap: () async {
  //                   if (!_commonModel.isPurchased) {
  //                     showText('此功能为付费功能');
  //                     return;
  //                   }
  //                   isolateSendFile(file);
  //                 },
  //               ),
  //             ActionButton(
  //               content: '新建',
  //               onTap: () async {
  //                 await showCreateFileModal(context);
  //               },
  //             ),
  //             ActionButton(
  //               content: '重命名',
  //               onTap: () {
  //                 // showRenameModal(context, file);
  //               },
  //             ),
  //             if (sharedNotEmpty)
  //               ActionButton(
  //                 content: '归档到此',
  //                 onTap: () async {
  //                   await showCreateArchiveModal(context);
  //                 },
  //               ),
  //             if (sharedNotEmpty)
  //               ActionButton(
  //                 content: '移动到此',
  //                 onTap: () async {
  //                   await handleMove(context);
  //                 },
  //               ),
  //             ActionButton(
  //               content: '删除',
  //               fontColor: Colors.redAccent,
  //               onTap: () async {
  //                 await removeModal(context, file);
  //               },
  //             ),
  //           ],
  //           rightChildren: <Widget>[
  //             ActionButton(
  //               content: '选中',
  //               onTap: () {
  //                 handleSelectedSingle(context, file);
  //               },
  //             ),
  //             if (sharedNotEmpty)
  //               ActionButton(
  //                 content: '复制到此',
  //                 onTap: () {
  //                   copyModal(context);
  //                 },
  //               ),
  //             ActionButton(
  //               content: '详情',
  //               onTap: () {
  //                 changeState(() {
  //                   showSize = true;
  //                 });
  //               },
  //             ),
  //             if (sharedNotEmpty &&
  //                 // 在判断下 不然移动下 sharedNotEmpty有问题
  //                 _commonModel.selectedFiles.length != 0 &&
  //                 LanFileUtils.ARCHIVE_EXTS
  //                     .contains(_commonModel.selectedFiles.first.ext))
  //               ActionButton(
  //                 content: '提取到此',
  //                 onTap: () async {
  //                   await handleExtractArchive(context);
  //                 },
  //               ),
  //             if (file.isFile)
  //               ActionButton(
  //                 content: '分享',
  //                 onTap: () async {
  //                   await shareFile(context, file);
  //                 },
  //               ),
  //             ActionButton(
  //               content: '更多选项',
  //               onTap: () async {
  //                 if (file.isFile) {
  //                   await showMoreModal(
  //                     context,
  //                     setState,
  //                     file: file,
  //                     themeModel: _themeModel,
  //                     commonProvider: _commonModel,
  //                   );
  //                   await update2Side();
  //                 }
  //               },
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }

  void _openFileActionByExt(
    SelfFileEntity file, {
    bool left,
    int index = 0,
  }) {
    String path = file.entity.path;
    LanFileUtils.matchFileActionByExt(
      file.ext,
      caseImage: () async {
        List<String> images;
        if (left) {
          images = LanFileUtils.filterImages(_leftFileList);
        } else {
          images = LanFileUtils.filterImages(_rightFileList);
        }
        _popLocker = true;

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
        _popLocker = false;
      },
      caseText: () {
        OpenFile.open(path);
      },
      caseAudio: () {
        OpenFile.open(path);
      },
      caseVideo: () async {
        _popLocker = true;
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
        _popLocker = false;
      },
      caseArchive: () {
        _commonModel.clearSelectedFiles();
        _commonModel.addSelectedFile(file);
        setState(() {});
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
                  markdownTheme: _themeModel.isDark
                      ? MarkdownTheme.darkTheme
                      : MarkdownTheme.lightTheme,
                  preConfig: PreConfig(
                    theme: setEditorTheme(
                      _themeModel.isDark,
                      TextStyle(
                        color: _themeModel.themeData?.itemFontColor,
                        backgroundColor:
                            _themeModel.themeData?.scaffoldBackgroundColor,
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

  Future<bool> _willPopFileRoute(stopDefaultButtonEvent, routeInfo) async {
    if (_popLocker) {
      return false;
    }

    if (pathLib.equals(_currentDir.path, _rootDir.path)) {
      return false;
    }

    if (pathLib.equals(_currentDir.parent.path, _rootDir.path)) {
      _currentDir = _rootDir;
      _leftFileList = await readdir(_currentDir);

      if (mounted) {
        setState(() {
          _rightFileList = [];
        });
      }
      return false;
    }

    if (pathLib.isWithin(_rootDir.path, _currentDir.path)) {
      _currentDir = _currentDir.parent;
      _leftFileList = await readdir(_currentDir.parent);
      _rightFileList = await readdir(_currentDir);
      if (mounted) {
        setState(() {});
      }
    }
    return false;
  }

  Future<void> update2Side({updateView = true}) async {
    /// 只有curentPath 存在的时候才读取
    if (pathLib.equals(_currentDir.path, _rootDir.path)) {
      _leftFileList = await readdir(_currentDir);
    } else {
      _leftFileList = await readdir(_currentDir.parent);
      _rightFileList = await readdir(_currentDir);
    }
    if (mounted) {
      if (updateView) {
        setState(() {});
        await getValidAndTotalStorageSize();
      }
    }
  }

  Future<void> _showBreadcrumb() async {
    LanFileMoreTheme themeData = _themeModel.themeData;
    List<String> paths = pathLib.split(_currentDir.path);
    return showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return LanDialog(
          fontColor: themeData.itemFontColor,
          bgColor: themeData.dialogBgColor,
          title: LanDialogTitle(title: '选择'),
          action: true,
          withOk: false,
          withCancel: false,
          children: <Widget>[
            BreadCrumb.builder(
              itemCount: paths.length,
              builder: (index) {
                return BreadCrumbItem(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  content: InkWell(
                    onTap: () async {
                      List<String> willNav =
                          paths.getRange(0, index + 1).toList();
                      String path = pathLib.joinAll(willNav);
                      Directory dir = Directory(path);

                      if (pathLib.equals(path, _rootDir.path)) {
                        _leftFileList = await readdir(dir);
                        _rightFileList = [];
                        _currentDir = dir;
                      } else if (pathLib.isWithin(_rootDir.path, path)) {
                        _leftFileList = await readdir(dir.parent);
                        _rightFileList = await readdir(dir);
                        _currentDir = dir;
                      }
                      setState(() {});
                      MixUtils.safePop(context);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.only(top: 4, bottom: 4, right: 6, left: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: themeData.itemColor,
                      ),
                      constraints: BoxConstraints(maxWidth: 100),
                      child: NoResizeText(
                        paths[index],
                        style: TextStyle(
                            fontSize: 16, color: themeData.itemFontColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
              divider: Icon(Icons.chevron_right),
            ),
            SizedBox(height: 25),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool isRootDir = _leftFileList.isEmpty
        ? true
        : pathLib.equals(_rootDir.path, _currentDir.path);
    LanFileMoreTheme themeData = _themeModel.themeData;

    if (widget.mode == FileManagerMode.surf) {
      if (_currentDir != null && _rootDir != null) {
        if (pathLib.equals(_currentDir.path, _rootDir.path)) {
          _commonModel.setCanPopToDesktop(true);
        } else {
          _commonModel.setCanPopToDesktop(false);
        }
      }
    }

    return _leftFileList.isEmpty
        ? Container(color: themeData?.scaffoldBackgroundColor)
        : CupertinoPageScaffold(
            backgroundColor: themeData?.scaffoldBackgroundColor,
            navigationBar: CupertinoNavigationBar(
              trailing: widget.trailingBuilder != null
                  ? widget.trailingBuilder(context)
                  : Wrap(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await createSearchModal(context,
                                provider: _themeModel, currentDir: _currentDir
                                // fileList:
                                //     isRootDir ? _leftFileList : _rightFileList,
                                );
                          },
                          child: Icon(
                            Icons.search,
                            color: Color(0xFF007AFF),
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            await _showMoreOptions(context);
                          },
                          child: Icon(
                            Icons.hdr_strong,
                            color: Color(0xFF007AFF),
                            size: 25,
                          ),
                        ),
                      ],
                    ),
              leading: pathLib.isWithin(_rootDir.path, _currentDir.path)
                  ? GestureDetector(
                      onTap: () => {_willPopFileRoute(1, 1)},
                      child: Icon(
                        Icons.arrow_left,
                        color: Color(0xFF007AFF),
                        size: 35,
                      ),
                    )
                  : Container(),
              middle: CupertinoButton(
                padding: EdgeInsets.all(0),
                onPressed: _showBreadcrumb,
                child: NoResizeText(
                  FileAction.filename(_currentDir.path ?? ''),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    // color: themeData?.navTitleColor,
                  ),
                ),
              ),
              backgroundColor: themeData?.navBackgroundColor,
              border: null,
            ),
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FileListView(
                      commonModel: _commonModel,
                      themeModel: _themeModel,
                      mode: widget.mode,
                      onUpdateView: () async {
                        await update2Side();
                      },
                      currentDir: _currentDir,
                      fileList: _leftFileList,
                      onChangeCurrentDir: (dir) {
                        _currentDir = dir;
                      },
                      // onLongPressEmpty: (d) async {
                      //   // await _showOptionsWhenPressedEmpty(context, left: true);
                      // },
                      // onHozDrag: (index, dir) async {
                      //   // await handleHozDragItem(index, dir, _leftFileList);
                      // },
                      // itemOnLongPress: (index) async {
                      //   // SelfFileEntity file = _leftFileList[index];
                      //   // await _showFileOptionsModal(file: file);
                      // },
                      onItemTap: (index) async {
                        SelfFileEntity file = _leftFileList[index];
                        if (file.isDir) {
                          // 点击后交换两边角色
                          _currentDir = file.entity;
                          List<SelfFileEntity> list =
                              await readdir(file.entity);
                          if (mounted) {
                            setState(() {
                              _rightFileList = list;
                            });
                          }
                        } else {
                          _openFileActionByExt(
                            file,
                            left: true,
                            index: index,
                          );
                        }
                      },
                    ),
                  ),
                  if (!isRootDir)
                    Expanded(
                      flex: 1,
                      child: FileListView(
                        commonModel: _commonModel,
                        themeModel: _themeModel,
                        mode: widget.mode,
                        onChangeCurrentDir: (dir) {
                          _currentDir = dir;
                        },
                        onUpdateView: () async {
                          await update2Side();
                        },
                        currentDir: _currentDir,
                        // onLongPressEmpty: (d) async {
                        //   // await _showOptionsWhenPressedEmpty(context,
                        //   //     left: false);
                        // },
                        fileList: _rightFileList,
                        // onHozDrag: (index, dir) async {
                        //   // await handleHozDragItem(index, dir, _rightFileList);
                        // },
                        onItemTap: (index) async {
                          SelfFileEntity file = _rightFileList[index];
                          if (file.isDir) {
                            _currentDir = file.entity;
                            List<SelfFileEntity> list =
                                await readdir(file.entity);
                            if (mounted) {
                              setState(() {
                                _leftFileList = _rightFileList;
                                _rightFileList = list;
                              });
                            }
                          } else {
                            _openFileActionByExt(
                              file,
                              left: false,
                              index: index,
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}

// Column(
//                 children: <Widget>[
//                   Container(
//                     height: 40,
//                     alignment: Alignment.center,
//                     padding: EdgeInsets.only(left: 8, right: 8),
//                     margin: EdgeInsets.only(bottom: 5),
//                     child: GestureDetector(
//                       onTap: () {
//                         showCupertinoModalPopup(
//                           filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//                           context: context,
//                           builder: (context) {
//                             return Column(
//                               children: [

//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: themeData?.itemColor,
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [LanText('搜索...')],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child:
//                   ),
//                 ],
//               ),
