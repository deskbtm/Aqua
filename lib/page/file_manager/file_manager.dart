import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_mix/android_mix.dart';
import 'package:android_mix/archive/enums.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lan_express/common/widget/action_button.dart';
import 'package:lan_express/common/widget/dialog.dart';
import 'package:lan_express/common/widget/file_info_card.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/common/widget/storage_card.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/back_button_interceptor/back_button_interceptor.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/isolate/airdrop.dart';
import 'package:lan_express/page/file_manager/create_archive.dart';
import 'package:lan_express/page/file_manager/create_fiile.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_list_view.dart';
import 'package:lan_express/page/file_manager/file_utils.dart';
import 'package:lan_express/page/file_manager/create_rename.dart';
import 'package:lan_express/page/installed_apps/installed_apps.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/page/photo_viewer/photo_viewer.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/share.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/notification.dart';
import 'package:lan_express/utils/store.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:file_utils/file_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'package:share_extend/share_extend.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'show_more.dart';

class FileManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FileManagerPageState();
  }
}

class _FileManagerPageState extends State<FileManagerPage>
    with WidgetsBindingObserver {
  ThemeProvider _themeProvider;

  CommonProvider _commonProvider;
  ShareProvider _shareProvider;
  GlobalKey<SplitSelectionModalState> _modalKey;
  List<SelfFileEntity> _leftFileList;
  List<SelfFileEntity> _rightFileList;
  Directory _currentDir;
  Directory _parentDir;
  Directory _rootDir;
  bool _useSandboxDir;
  bool _initMutex;
  double _totalSize;
  double _validSize;

  @override
  void initState() {
    super.initState();
    _leftFileList = [];
    _rightFileList = [];
    _currentDir = null;
    _parentDir = null;
    _initMutex = true;
    _useSandboxDir = false;
    _totalSize = 0;
    _validSize = 0;

    WidgetsBinding.instance.addObserver(this);
    _modalKey = GlobalKey<SplitSelectionModalState>();
    BackButtonInterceptor.add(willPop);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
    _shareProvider = Provider.of<ShareProvider>(context);
    if (_initMutex) {
      _initMutex = false;
      await _changeRootPath(_commonProvider.storageRootPath);
      await getValidAndTotalStorageSize();
    }
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    BackButtonInterceptor.remove(willPop);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //切回来刷新下 以防文件变化
    if (state == AppLifecycleState.resumed) {
      if (mounted) update2Side();
    }
  }

  Future<void> getValidAndTotalStorageSize() async {
    _totalSize = await AndroidMix.storage.getTotalExternalStorageSize;
    _validSize = await AndroidMix.storage.getValidExternalStorageSize;
  }

  Future<List<SelfFileEntity>> readdir(Directory path) async {
    SelfFileList result = await FileAction.readdir(
      path,
      sortType: _commonProvider.sortType,
      showHidden: _commonProvider.isShowHidden,
      reversed: _commonProvider.sortReversed,
    ).catchError((err) {
      FLog.error(text: '$err', methodName: 'readdir', className: 'FileManager');
    });

    switch (_commonProvider.showOnlyType) {
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
  }

  Future<void> _changeRootPath(String path) async {
    _rootDir = Directory(path);
    _currentDir = _rootDir;
    _parentDir = _currentDir.parent;
    _leftFileList = await readdir(_currentDir);
    _rightFileList = [];
    if (mounted) setState(() {});
  }

  Future<void> clearAllSelected(BuildContext context) async {
    await _shareProvider.clearSelectedFiles();

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
                  await clearAllSelected(context);
                },
              ),
              ActionButton(
                content: _commonProvider.isShowHidden ? '显示隐藏文件' : '不显示隐藏',
                onTap: () {
                  if (mounted) {
                    changeFilesVisible();
                    changeState(() {});
                    MixUtils.safePop(context);
                  }
                },
              ),
              ActionButton(
                content: _useSandboxDir ? '切换系统目录' : '切换沙盒目录',
                onTap: changeSandboxDir,
              ),
              ActionButton(
                content: '排序方式',
                onTap: insertSortOptions,
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
                onTap: filterType,
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> filterType() async {
    _modalKey.currentState?.insertRightCol([
      ActionButton(
        content: '显示全部',
        onTap: () {
          _commonProvider.setShowOnlyType(ShowOnlyType.all);
          update2Side();
        },
      ),
      ActionButton(
        content: '只显示文件夹',
        onTap: () {
          _commonProvider.setShowOnlyType(ShowOnlyType.folder);
          update2Side();
        },
      ),
      ActionButton(
        content: '只显示文件',
        onTap: () {
          _commonProvider.setShowOnlyType(ShowOnlyType.file);
          update2Side();
        },
      ),
      ActionButton(
        content: '只显示链接',
        onTap: () {
          _commonProvider.setShowOnlyType(ShowOnlyType.link);
          update2Side();
        },
      ),
    ]);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  Future<void> showRenameModal(
      BuildContext context, SelfFileEntity file) async {
    await createRenameModal(
      context,
      file,
      provider: _themeProvider,
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

  Future<void> handleMove(BuildContext context) async {
    if (_shareProvider.selectedFiles.isNotEmpty) {
      await for (var item
          in Stream.fromIterable(_shareProvider.selectedFiles)) {
        String newPath =
            pathLib.join(_currentDir.path, pathLib.basename(item.entity.path));
        if (await File(newPath).exists() || await Directory(newPath).exists()) {
          showText('$newPath 已存在 移动失败');
          continue;
        }

        await item.entity.rename(newPath).then((val) async {
          showText('移动完成');
          await _shareProvider.clearSelectedFiles();
          await update2Side();
          MixUtils.safePop(context);
        }).catchError((err) {
          showText('$err');
          FLog.error(text: '$err', methodName: 'handleMove');
        });
      }
    }
  }

  Future<void> handleSelectedSingle(
      BuildContext context, SelfFileEntity file) async {
    showText('请选择目标目录');
    _shareProvider.addFile(file);
    MixUtils.safePop(context);
  }

  Future<void> copyModal(BuildContext context) async {
    MixUtils.safePop(context);
    if (_shareProvider.selectedFiles.isEmpty) {
      showText('无复制内容');
      return;
    }

    dynamic themeData = _themeProvider.themeData;
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
                      : loadingIndicator(context, _themeProvider),
                  SizedBox(height: 10),
                ],
                defaultOkText: '确定',
                onOk: () async {
                  if (!popAble) {
                    return;
                  }
                  changeState(() {
                    popAble = false;
                  });

                  await for (var item
                      in Stream.fromIterable(_shareProvider.selectedFiles)) {
                    String targetPath = pathLib.join(
                        _currentDir.path, pathLib.basename(item.entity.path));
                    await FileAction.copy(item, targetPath);
                  }
                  if (mounted) {
                    changeState(() {
                      popAble = true;
                    });
                    MixUtils.safePop(context);
                    showText('粘贴完成');
                    await _shareProvider.clearSelectedFiles();
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

  Future<void> removeModal(BuildContext context, SelfFileEntity file) async {
    MixUtils.safePop(context);
    dynamic themeData = _themeProvider.themeData;
    List selected = _shareProvider.selectedFiles;
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
                  ? loadingIndicator(context, _themeProvider)
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

                _shareProvider.addFile(file);
                await for (var item in Stream.fromIterable(selected)) {
                  if (item.isDir) {
                    if (FileUtils.rm([item.entity.path],
                        recursive: true, directory: true, force: true)) {
                      //删除后 已经不存在了 交换一下
                      if (item.entity.path != _rootDir.path) {
                        _currentDir = item.entity.parent;
                        _parentDir = _currentDir.parent;
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
                _shareProvider.clearSelectedFiles();
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

  Future<void> showCreateFileModal(BuildContext context,
      {bool left = false}) async {
    createFileModal(
      context,
      provider: _themeProvider,
      willCreateDir: left ? _parentDir.path : _currentDir.path,
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

  Future<void> showCreateArchiveModal(
    BuildContext context,
  ) async {
    createArchiveModal(
      context,
      shareProvider: _shareProvider,
      themeProvider: _themeProvider,
      currentDir: _currentDir,
      onSuccessUpdate: (context) async {
        if (mounted) {
          _shareProvider.clearSelectedFiles();
          await update2Side();
          MixUtils.safePop(context);
        }
      },
    );
  }

  Future<void> shareFile(BuildContext context, SelfFileEntity file) async {
    String path = file.entity.path;
    if (IMG_EXTS.contains(file.ext)) {
      await ShareExtend.share(path, 'image');
    } else if (VIDEO_EXTS.contains(file.ext)) {
      await ShareExtend.share(path, 'video');
    } else {
      await ShareExtend.share(path, 'file');
    }
  }

  Future<void> insertSortOptions() async {
    _modalKey.currentState.insertRightCol([
      ActionButton(
        content: '正序',
        fontColor: Colors.pink,
        onTap: () async {
          _commonProvider.setSortReversed(false);
          update2Side();
        },
      ),
      ActionButton(
        content: '倒序',
        fontColor: Colors.yellow,
        onTap: () async {
          _commonProvider.setSortReversed(true);
          update2Side();
        },
      ),
      ActionButton(
        content: '名称',
        fontColor: Colors.lightBlue,
        onTap: () async {
          _commonProvider.setSortType(SORT_CASE);
          update2Side();
          await Store.setString(FILE_SORT_TYPE, SORT_CASE);
        },
      ),
      ActionButton(
        content: '大小',
        fontColor: Colors.blueAccent,
        onTap: () async {
          _commonProvider.setSortType(SORT_SIZE);
          update2Side();
          await Store.setString(FILE_SORT_TYPE, SORT_SIZE);
        },
      ),
      ActionButton(
        content: '修改日期',
        fontColor: Colors.cyanAccent,
        onTap: () async {
          _commonProvider.setSortType(SORT_MODIFIED);
          update2Side();
          await Store.setString(FILE_SORT_TYPE, SORT_MODIFIED);
        },
      ),
      ActionButton(
        content: '类型',
        fontColor: Colors.teal,
        onTap: () async {
          _commonProvider.setSortType(SORT_TYPE);
          update2Side();
          await Store.setString(FILE_SORT_TYPE, SORT_TYPE);
        },
      ),
    ]);
  }

  Future<void> changeFilesVisible() async {
    Store.setBool(SHOW_FILE_HIDDEN, !_commonProvider.isShowHidden);
    _commonProvider.setShowHidden(!_commonProvider.isShowHidden);
    _modalKey.currentState.replaceLeft(1, [
      ActionButton(
        content: _commonProvider.isShowHidden ? '显示隐藏文件' : '不显示隐藏',
        onTap: () async {
          if (mounted) {
            await changeFilesVisible();
          }
        },
      )
    ]);
    update2Side(updateView: false);
  }

  Future<void> changeSandboxDir() async {
    CodeSrvUtils cutils = await CodeSrvUtils().init();
    Directory rootfs = Directory('${cutils.filesPath}/rootfs');
    _useSandboxDir = !_useSandboxDir;
    if (_useSandboxDir) {
      if (await rootfs.exists()) {
        _commonProvider.setStorageRootPath(rootfs.path);
      } else {
        showText('沙盒不存在');
        return;
      }
    } else {
      String path = await MixUtils.getExternalPath();
      _commonProvider.setStorageRootPath(path);
    }
    showText('切换完成');

    await _changeRootPath(_commonProvider.storageRootPath);

    _modalKey.currentState.replaceLeft(2, [
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

  Future<void> handleExtractArchive(BuildContext context) async {
    bool result = false;

    if (_shareProvider.selectedFiles.length > 1) {
      showText('只允许操作单个文件');
    } else {
      SelfFileEntity first = _shareProvider.selectedFiles.first;
      String archivePath = first.entity.path;
      String name = FileAction.getName(archivePath);
      if (Directory(pathLib.join(_currentDir.path, name)).existsSync()) {
        showText('目录重名, 请更换');
        return;
      }

      switch (first.ext) {
        case '.zip':
          if (await AndroidMix.archive.isZipEncrypted(archivePath)) {
            await showSingleTextFieldModal(
              context,
              _themeProvider,
              title: '输入密码',
              onOk: (val) async {
                showWaitForArchiveNotification('解压中...');
                result = await AndroidMix.archive
                    .unzip(archivePath, _currentDir.path, pwd: val);
              },
              onCancel: () {
                MixUtils.safePop(context);
              },
            );
          } else {
            showWaitForArchiveNotification('解压中...');
            result =
                await AndroidMix.archive.unzip(archivePath, _currentDir.path);
          }
          break;
        case '.tar':
          showWaitForArchiveNotification('解压中...');
          await AndroidMix.archive.extractArchive(
            archivePath,
            _currentDir.path,
            ArchiveFormat.tar,
          );
          break;
        case '.gz':
        case '.tgz':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            _currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.gzip,
          );
          break;
        case '.bz2':
        case '.tz2':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            _currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.bzip2,
          );
          break;
        case '.xz':
        case '.txz':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            _currentDir.path,
            ArchiveFormat.tar,
            compressionType: CompressionType.xz,
          );
          break;
        case '.jar':
          showWaitForArchiveNotification('解压中...');
          result = await AndroidMix.archive.extractArchive(
            archivePath,
            _currentDir.path,
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
        await _shareProvider.clearSelectedFiles();
        await update2Side();
        MixUtils.safePop(context);
      }
    }
  }

  void isolateSendFile(SelfFileEntity file) async {
    IO.Socket socket = _commonProvider.socket;
    if (socket != null && socket.connected) {
      Map data = {
        'port': _commonProvider.filePort,
        'ip': _commonProvider.aliveIps.first,
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

  Future<void> showOptionsWhenPressedEmpty(BuildContext context,
      {bool left = false}) async {
    bool sharedNotEmpty = _shareProvider.selectedFiles.isNotEmpty;
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
                  await showCreateArchiveModal(context);
                },
              ),
            if (sharedNotEmpty)
              ActionButton(
                content: '移动到此',
                onTap: () async {
                  await handleMove(context);
                },
              ),
          ],
          rightChildren: <Widget>[
            if (sharedNotEmpty)
              ActionButton(
                content: '复制到此',
                onTap: () {
                  copyModal(context);
                },
              ),
            ActionButton(
              content: '新建',
              onTap: () {
                showCreateFileModal(context, left: left);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showFileOptionsModal({SelfFileEntity file}) async {
    bool showSize = false;
    bool sharedNotEmpty = _shareProvider.selectedFiles.isNotEmpty;

    await showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, changeState) {
          return SplitSelectionModal(
            // onDispose: () {},
            topPanel: FileInfoCard(file: file, showSize: showSize),
            leftChildren: [
              if (!(file.entity is Directory))
                ActionButton(
                  content: '内网快递',
                  onTap: () async {
                    if (!_commonProvider.isPurchased) {
                      showText('此功能为付费功能');
                      return;
                    }
                    isolateSendFile(file);
                  },
                ),
              ActionButton(
                content: '新建',
                onTap: () {
                  showCreateFileModal(context);
                },
              ),
              ActionButton(
                content: '重命名',
                onTap: () {
                  showRenameModal(context, file);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '归档到此',
                  onTap: () async {
                    await showCreateArchiveModal(context);
                  },
                ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '移动到此',
                  onTap: () async {
                    await handleMove(context);
                  },
                ),
              ActionButton(
                content: '删除',
                fontColor: Colors.redAccent,
                onTap: () async {
                  await removeModal(context, file);
                },
              ),
            ],
            rightChildren: <Widget>[
              ActionButton(
                content: '选中',
                onTap: () {
                  handleSelectedSingle(context, file);
                  // _commonProvider.setCopyTargetPath(file.entity.path);
                },
              ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '复制到此',
                  onTap: () {
                    copyModal(context);
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
                  ARCHIVE_EXTS.contains(_shareProvider.selectedFiles.first.ext))
                ActionButton(
                  content: '提取到此',
                  onTap: () async {
                    await handleExtractArchive(context);
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
                  await showMoreModal(
                    context,
                    setState,
                    file: file,
                    themeProvider: _themeProvider,
                    commonProvider: _commonProvider,
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  void openFileActionByExt(SelfFileEntity file, {bool left, int index = 0}) {
    String path = file.entity.path;
    matchSupportFileExt(
      file.ext,
      caseImage: () {
        List<String> images;
        if (left) {
          images = filterImages(_leftFileList);
        } else {
          images = filterImages(_rightFileList);
        }
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) {
              return PhotoViewer(
                images: images,
                index: images.indexOf(file.entity.path),
              );
            },
          ),
        );
      },
      caseText: () {
        OpenFile.open(path);
      },
      caseAudio: () {},
      caseVideo: () {
        OpenFile.open(path);
      },
      caseArchive: () {
        _shareProvider.clearSelectedFiles();
        _shareProvider.addFile(file);
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
              color: Color(0x83FFFFFF),
              child: Markdown(
                selectable: true,
                data: data,
                extensionSet: md.ExtensionSet.gitHubWeb,
                onTapLink: (url) async {
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    showText('链接打开失败');
                    FLog.error(text: 'markdown url');
                  }
                },
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

  void changeSidesRole(SelfFileEntity file) {
    _currentDir = file.entity;
    _parentDir = _currentDir.parent;
  }

  Future<bool> willPop(stopDefaultButtonEvent, routeInfo) async {
    if (_currentDir.path == _rootDir.path) {
      return false;
    }

    if (_parentDir.path == _rootDir.path) {
      _leftFileList = await readdir(_rootDir);
      _rightFileList = [];
      _currentDir = _rootDir;
    } else {
      _leftFileList = await readdir(_parentDir.parent);
      _rightFileList = await readdir(_parentDir);
      _currentDir = _parentDir;
      _parentDir = _parentDir.parent;
    }

    setState(() {});
    return false;
  }

  Future<void> update2Side({updateView = true}) async {
    if (mounted) {
      /// 只有curentPath 存在的时候才读取
      if (_currentDir.path == _rootDir.path) {
        _leftFileList = await readdir(_currentDir);
      } else {
        _leftFileList = await readdir(_parentDir);
        _rightFileList = await readdir(_currentDir);
      }
      // if (await Directory(_currentDir.path).exists()) {
      // } else {
      //   if (_currentDir.parent.path == _rootPath) {
      //     _leftFileList = await readdir(_currentDir.parent);
      //     _rightFileList = [];
      //   } else {
      //     _leftFileList = await readdir(_parentDir.parent);
      //     _rightFileList = await readdir(_currentDir.parent);
      //   }
      // }
      if (updateView) {
        setState(() {});
        await getValidAndTotalStorageSize();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider?.themeData;
    return _leftFileList.isEmpty
        ? Container()
        : CupertinoPageScaffold(
            backgroundColor: themeData?.scaffoldBackgroundColor,
            navigationBar: CupertinoNavigationBar(
              trailing: GestureDetector(
                onTap: () async {
                  await _showMoreOptions(context);
                },
                child: Icon(
                  Icons.hdr_strong,
                  color: themeData?.topNavIconColor,
                  size: 25,
                ),
              ),
              leading: _rootDir.path != _currentDir.path
                  ? GestureDetector(
                      onTap: () => {willPop(1, 1)},
                      child: Icon(
                        Icons.arrow_left,
                        color: themeData?.topNavIconColor,
                        size: 35,
                      ),
                    )
                  : null,
              middle: NoResizeText(
                FileAction.filename(_currentDir.path ?? ''),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: themeData?.navTitleColor,
                ),
              ),
              backgroundColor: themeData?.navBackgroundColor,
              border: null,
            ),
            child: Container(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: FileListView(
                      onUpdateView: () async {
                        await update2Side();
                      },
                      fileList: _leftFileList,
                      onLongPressEmpty: (d) async {
                        await showOptionsWhenPressedEmpty(context, left: true);
                      },
                      onHozDrag: (index, dir) {
                        SelfFileEntity file = _leftFileList[index];
                        if (dir == 1) {
                          _shareProvider.addFile(file);
                        } else if (dir == -1) {
                          _shareProvider.removeFile(file);
                        }
                      },
                      itemOnLongPress: (index) {
                        SelfFileEntity file = _leftFileList[index];
                        showFileOptionsModal(file: file);
                      },
                      onItemTap: (index) async {
                        SelfFileEntity file = _leftFileList[index];
                        if (file.isDir) {
                          // 点击后交换两边角色
                          changeSidesRole(file);
                          List<SelfFileEntity> list =
                              await readdir(file.entity);
                          if (mounted) {
                            setState(() {
                              _rightFileList = list;
                            });
                          }
                        } else {
                          openFileActionByExt(
                            file,
                            left: true,
                            index: index,
                          );
                        }
                      },
                    ),
                  ),
                  if (_rootDir.path != _currentDir.path)
                    Expanded(
                      flex: 1,
                      child: FileListView(
                        onUpdateView: () async {
                          await update2Side();
                        },
                        onLongPressEmpty: (d) async {
                          print('demo');
                          await showOptionsWhenPressedEmpty(context,
                              left: false);
                        },
                        fileList: _rightFileList,
                        onHozDrag: (index, dir) {
                          SelfFileEntity file = _rightFileList[index];
                          if (dir == 1) {
                            _shareProvider.addFile(file);
                          } else if (dir == -1) {
                            _shareProvider.removeFile(file);
                          }
                        },
                        itemOnLongPress: (index) {
                          SelfFileEntity file = _rightFileList[index];
                          showFileOptionsModal(file: file);
                        },
                        onItemTap: (index) async {
                          SelfFileEntity file = _rightFileList[index];
                          if (file.isDir) {
                            changeSidesRole(file);
                            List<SelfFileEntity> list =
                                await readdir(file.entity);
                            if (mounted) {
                              setState(() {
                                _leftFileList = _rightFileList;
                                _rightFileList = list;
                              });
                            }
                          } else {
                            openFileActionByExt(
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
