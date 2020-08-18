import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_mix/android_mix.dart';
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
import 'package:lan_express/common/widget/text_field.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/back_button_interceptor/back_button_interceptor.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/external/menu/menu.dart';
import 'package:lan_express/isolate/airdrop.dart';
import 'package:lan_express/page/file_manager/create_fiile.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_list_view.dart';
import 'package:lan_express/page/file_manager/file_utils.dart';
import 'package:lan_express/page/installed_apps/installed_apps.dart';
import 'package:lan_express/provider/device.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/share.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/store.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:file_utils/file_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

class FileManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FileManagerPageState();
  }
}

class _FileManagerPageState extends State<FileManagerPage>
    with WidgetsBindingObserver {
  ThemeProvider _themeProvider;
  NativeProvider _nativeProvider;
  CommonProvider _commonProvider;
  ShareProvider _shareProvider;
  GlobalKey<SplitSelectionModalState> _modalKey;
  List<SelfFileEntity> _leftFileList;
  List<SelfFileEntity> _rightFileList;
  Directory _currentDir;
  Directory _parentDir;
  Directory _rootDir;
  String _rootPath;
  FileAction _action;
  bool _initMutex;
  double _totalSize;
  double _validSize;

  @override
  void initState() {
    super.initState();
    _rootPath = '';
    _leftFileList = [];
    _rightFileList = [];
    _currentDir = null;
    _parentDir = null;
    _initMutex = true;
    _totalSize = 0;
    _validSize = 0;
    _action = FileAction();
    WidgetsBinding.instance.addObserver(this);
    _modalKey = GlobalKey<SplitSelectionModalState>();
    BackButtonInterceptor.add(willPop);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _nativeProvider = Provider.of<NativeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
    _shareProvider = Provider.of<ShareProvider>(context);
    _rootPath = _nativeProvider.externalStorageRootPath;
    if (_initMutex) {
      _initMutex = false;
      _rootDir = Directory(_rootPath);
      _currentDir = _rootDir;
      _parentDir = _currentDir.parent;
      _leftFileList = await readdir(_currentDir);
      setState(() {});
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
    SelfFileList result = await _action
        .readdir(
      path,
      sortType: _commonProvider.sortType,
      showHidden: _commonProvider.isShowHidden,
      reversed: _commonProvider.sortReversed,
    )
        .catchError((err) {
      FLog.error(text: err, methodName: 'readdir', className: 'FileManager');
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

  Future<void> clearAllSelected(BuildContext context) async {
    await _shareProvider.clear();
    // await _commonProvider.setArchiveTarget(null);
    // await _commonProvider.setCopyTarget(null);
    // await _commonProvider.setMoveTarget(null);

    if (mounted) {
      setState(() {});
      showText('已取消全部选中');
      MixUtils.safePop(context);
    }
  }

  Future<void> _showMoreOptions(BuildContext context) async {
    showCupertinoModal(
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
                  }
                },
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

  Future<void> renameModal(BuildContext context, SelfFileEntity file) async {
    MixUtils.safePop(context);
    dynamic themeData = _themeProvider.themeData;
    TextEditingController textEditingController = TextEditingController();

    showCupertinoModal(
      context: context,
      builder: (BuildContext context) {
        return LanDialog(
          fontColor: themeData.itemFontColor,
          bgColor: themeData.dialogBgColor,
          title: NoResizeText('重命名'),
          action: true,
          children: <Widget>[
            LanTextField(
              controller: textEditingController,
              placeholder: '${file.filename}',
            ),
            SizedBox(height: 10),
          ],
          onOk: () async {
            String newPath = _action.renameNewPath(
                file.entity.path, textEditingController.text);
            await _action.rename(file, newPath, onExists: () {
              showText('文件已存在');
            }).then((value) async {
              showText('${textEditingController.text}重命名成功');
              await update2Side();
              MixUtils.safePop(context);
            }).catchError((err) {
              showText('重命名失败, 检查文件名是否非法等');
            });
          },
          onCancel: () {
            MixUtils.safePop(context);
          },
        );
      },
    );
  }

  Future<void> handleMove(BuildContext context) async {
    if (_shareProvider.selectedFiles.isNotEmpty) {
      await for (var item
          in Stream.fromIterable(_shareProvider.selectedFiles)) {
        String newPath =
            pathLib.join(_currentDir.path, pathLib.basename(item.entity.path));
        if (File(newPath).existsSync() || Directory(newPath).existsSync()) {
          showText('$newPath 已存在 移动失败');
          continue;
        }

        await _action.rename(item, newPath, onExists: () {}).catchError((err) {
          showText('$err');
          FLog.error(text: '$err', methodName: 'handleMove');
        });
      }
      await _shareProvider.clear();
      await update2Side();
      MixUtils.safePop(context);
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
                      ? LanText('Are you 确定粘贴?')
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
                    await _action.copy(item, targetPath);
                  }
                  if (mounted) {
                    changeState(() {
                      popAble = true;
                    });
                    MixUtils.safePop(context);
                    showText('粘贴完成');
                    await _shareProvider.clear();
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

  Future<void> archiveModal(BuildContext context, SelfFileEntity file) async {
    MixUtils.safePop(context);
    if (_shareProvider.selectedFiles.isNotEmpty) {
      dynamic themeData = _themeProvider.themeData;
      bool popAble = true;
      String archiveType = 'zip';
      String archiveText = 'Zip';
      bool preDisplay = false;
      String pwd;

      showCupertinoModal(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) changeState) {
              return WillPopScope(
                onWillPop: () async {
                  return popAble;
                },
                child: LanDialog(
                  display: preDisplay,
                  fontColor: themeData?.itemFontColor,
                  bgColor: themeData?.dialogBgColor,
                  title: NoResizeText('归档'),
                  action: true,
                  children: <Widget>[
                    SizedBox(height: 10),
                    popAble
                        ? FocusedMenuHolder(
                            menuWidth: MediaQuery.of(context).size.width * 0.4,
                            blurSize: 5.0,
                            menuItemExtent: 45,
                            duration: Duration(milliseconds: 100),
                            animateMenuItems: true,
                            maskColor: Color(0x00FFFFFF),
                            menuOffset: 10.0,
                            bottomOffsetHeight: 80.0,
                            menuItems: <FocusedMenuItem>[
                              FocusedMenuItem(
                                backgroundColor: themeData?.menuItemColor,
                                title: LanText("Zip"),
                                onPressed: () {
                                  changeState(() {
                                    archiveText = 'Zip';
                                    archiveType = 'zip';
                                  });
                                },
                              ),
                              FocusedMenuItem(
                                backgroundColor: themeData?.menuItemColor,
                                title: LanText("Zip 加密"),
                                onPressed: () async {
                                  changeState(() {
                                    preDisplay = !preDisplay;
                                  });
                                  await showSingleTextModal(
                                    context,
                                    _themeProvider,
                                    title: '输入密码',
                                    transparent: true,
                                    onOk: (val) async {
                                      changeState(() {
                                        archiveText = 'Zip 加密';
                                        archiveType = 'zip';
                                        pwd = val;
                                        preDisplay = !preDisplay;
                                      });
                                    },
                                    onCancel: () {
                                      MixUtils.safePop(context);
                                    },
                                  ).then((value) {
                                    changeState(() {
                                      preDisplay = !preDisplay;
                                    });
                                  });
                                },
                              ),
                              FocusedMenuItem(
                                backgroundColor: themeData?.menuItemColor,
                                title: LanText(
                                  '取消',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                trailingIcon: Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                                onPressed: () {
                                  MixUtils.safePop(context);
                                },
                              ),
                            ],
                            child: Container(
                              padding: EdgeInsets.only(left: 16, right: 16),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  NoResizeText(
                                    archiveText,
                                    style: TextStyle(color: Color(0xFF007AFF)),
                                  ),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          )
                        : loadingIndicator(context, _themeProvider),
                    SizedBox(height: 10),
                  ],
                  defaultOkText: '确定',
                  defaultCacnelText: popAble ? '取消' : '后台',
                  onOk: () async {
                    if (!popAble) {
                      return;
                    }
                    if (mounted) {
                      changeState(() {
                        popAble = false;
                      });
                    }
                    await Future.delayed(Duration(milliseconds: 50));
                    bool result = await AndroidMix.archive
                        .zip(
                      _shareProvider.selectedFiles
                          .map((e) => e.entity.path)
                          .toList(),
                      FileAction.genPathWhenExists(
                          _currentDir.path, '.' + archiveType),
                      pwd: pwd?.trim(),
                    )
                        .catchError((err) {
                      FLog.error(text: '$err', methodName: 'archiveModal');
                    });
                    if (result) {
                      showText('归档成功');
                    } else {
                      showText('归档失败');
                    }
                    if (mounted) {
                      await _shareProvider.clear();
                      await update2Side();
                      MixUtils.safePop(context);
                    }
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
  }

  Future<void> removeModal(BuildContext context, SelfFileEntity file) async {
    MixUtils.safePop(context);
    dynamic themeData = _themeProvider.themeData;
    List selected = _shareProvider.selectedFiles;
    bool confirmRm = false;

    showCupertinoModal(
      context: context,
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
                      'Are you 确定删除${selected.length == 0 ? 1 : selected.length}项?',
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
                _shareProvider.clear();
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

  Future<void> handleExtractZip(BuildContext context) async {
    bool result = false;
    if (_shareProvider.selectedFiles.length > 1) {
      showText('只允许操作单个文件');
    } else {
// if()

      SelfFileEntity first = _shareProvider.selectedFiles.first;

      // if (first.ext != '.zip') {
      //   showText('只支持');
      //   return;
      // }

      if (await AndroidMix.archive.isZipEncrypted(first.entity.path)) {
        await showSingleTextModal(
          context,
          _themeProvider,
          title: '输入密码',
          onOk: (val) async {
            showText('提取中 请等待...');
            result = await AndroidMix.archive
                .unzip(first.entity.path, _currentDir.path, pwd: val);
          },
          onCancel: () {
            MixUtils.safePop(context);
          },
        ).then((value) {
          MixUtils.safePop(context);
        });
      } else {
        showText('提取中 请等待...');
        result =
            await AndroidMix.archive.unzip(first.entity.path, _currentDir.path);
      }
      if (result) {
        showText('提取成功');
      } else {
        showText('提取失败');
      }
      if (mounted) {
        await _shareProvider.clear();
        await update2Side();
        MixUtils.safePop(context);
      }
    }
  }

  void isolateSendFile(SelfFileEntity file) async {
    IO.Socket socket = _commonProvider.socket;
    if (socket != null && socket.connected) {
      Map data = {
        'port': _commonProvider.expressPort,
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

  Future<void> showFileOptionsModal({SelfFileEntity file}) async {
    bool showSize = false;
    bool sharedNotEmpty = _shareProvider.selectedFiles.isNotEmpty;

    await showCupertinoModal(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, changeState) {
          return SplitSelectionModal(
            onDispose: () {},
            topPanel: FileInfoCard(file: file, showSize: showSize),
            leftChildren: [
              if (!(file.entity is Directory))
                ActionButton(
                  content: '内网快递',
                  onTap: () async {
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
                  renameModal(context, file);
                },
              ),
              if (sharedNotEmpty &&
                  _shareProvider.selectedFiles.first.ext == '.zip')
                ActionButton(
                  content: '提取到此',
                  onTap: () async {
                    await handleExtractZip(context);
                  },
                ),
              if (sharedNotEmpty)
                ActionButton(
                  content: '归档到此',
                  onTap: () async {
                    await archiveModal(context, file);
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
              if (!(file.entity is Directory))
                ActionButton(
                  content: '快递WebDAV',
                  onTap: () async {
                    // loadingModal(context, provider: _themeProvider);
                    // await removeModal(context, file);
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
              ActionButton(
                content: '详情',
                onTap: () {
                  changeState(() {
                    showSize = true;
                  });
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
                content: '链接到此',
                onTap: () async {},
              ),
              ActionButton(
                content: '分享',
                onTap: () {},
              ),
              ActionButton(
                content: '更多选项',
                onTap: () {},
              ),
            ],
          );
        });
      },
    );
  }

  void openFileActionByExt(SelfFileEntity file) {
    String path = file.entity.path;
    matchFileExt(
      file.ext,
      casePPT: () {},
      caseWord: () {},
      caseCVS: () {},
      caseFlash: () {},
      caseExcel: () {},
      caseHtml: () {},
      casePdf: () {},
      caseImage: () {},
      caseText: () {},
      caseAudio: () {},
      caseMP4: () {},
      caseVideo: () {},
      caseZip: () {
        _shareProvider.clear();
        _shareProvider.addFile(file);
        showText('请选择提取路径');
      },
      caseArchive: () {
        OpenFile.open(path);
      },
      casePs: () {},
      caseApk: () {
        OpenFile.open(path);
      },
      caseFolder: () {},
      caseSymbolLink: () {},
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
                    BotToast.showText(
                        text: '链接打开失败',
                        contentColor: _themeProvider?.themeData?.toastColor);
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
    if (_currentDir.path == _rootPath) {
      return false;
    }

    if (_parentDir.path == _rootPath) {
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
      if (_currentDir.path == _rootPath) {
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
              leading: _rootPath != _currentDir.path
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
                _action.filename(_currentDir.path ?? ''),
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
                      emptyOnLongPress: (d) async {
                        // await createFileModal(context,
                        //     left: _currentDir.path != _rootPath);
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
                        if (file.type == FileSystemEntityType.directory) {
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
                          openFileActionByExt(file);
                        }
                      },
                    ),
                  ),
                  if (_rootPath != _currentDir.path)
                    Expanded(
                      flex: 1,
                      child: FileListView(
                        onUpdateView: () async {
                          await update2Side();
                        },
                        emptyOnLongPress: (d) async {
                          // await createFileModal(context);
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
                          if (file.type == FileSystemEntityType.directory) {
                            changeSidesRole(file);
                            List<SelfFileEntity> list =
                                await readdir(file.entity);
                            if (mounted) {
                              setState(() {
                                _leftFileList = _rightFileList;
                                _rightFileList = list;
                              });
                            }
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
