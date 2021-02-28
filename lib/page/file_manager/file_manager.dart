import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:android_mix/android_mix.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/common/widget/storage_card.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/external/back_button_interceptor/back_button_interceptor.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/external/breadcrumb/src/breadcrumb.dart';
import 'package:lan_file_more/external/breadcrumb/src/breadcrumb_item.dart';
import 'package:lan_file_more/model/file_model.dart';
import 'package:lan_file_more/page/file_manager/file_list_view.dart';
import 'package:lan_file_more/page/installed_apps/installed_apps.dart';
import 'package:lan_file_more/page/lan/code_server/utils.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'create_search.dart';
import 'file_utils.dart';

enum FileManagerMode { surf, pick, search }

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
    // _fileModel.currentDir = null;
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
      SelfFileList result = await LanFileUtils.readdir(
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
    _fileModel.setRootDir(Directory(path));
    _fileModel.setCurrentDir(_rootDir);
    _leftFileList = await readdir(_fileModel.currentDir);
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

  Future<bool> _willPopFileRoute(stopDefaultButtonEvent, routeInfo) async {
    if (_popLocker) {
      return false;
    }

    if (pathLib.equals(_fileModel.currentDir.path, _rootDir.path)) {
      return false;
    }

    if (pathLib.equals(_fileModel.currentDir.parent.path, _rootDir.path)) {
      _fileModel.setCurrentDir(_rootDir);
      _leftFileList = await readdir(_fileModel.currentDir);

      if (mounted) {
        setState(() {
          _rightFileList = [];
        });
      }
      return false;
    }

    if (pathLib.isWithin(_rootDir.path, _fileModel.currentDir.path)) {
      _fileModel.setCurrentDir(_fileModel.currentDir.parent);
      _leftFileList = await readdir(_fileModel.currentDir.parent);
      _rightFileList = await readdir(_fileModel.currentDir);
      if (mounted) {
        setState(() {});
      }
    }
    return false;
  }

  Future<void> update2Side({updateView = true}) async {
    /// 只有curentPath 存在的时候才读取
    if (pathLib.equals(_fileModel.currentDir.path, _rootDir.path)) {
      _leftFileList = await readdir(_fileModel.currentDir);
    } else {
      _leftFileList = await readdir(_fileModel.currentDir.parent);
      _rightFileList = await readdir(_fileModel.currentDir);
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
    List<String> paths = pathLib.split(_fileModel.currentDir.path);
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
                        _fileModel.setCurrentDir(dir);
                      } else if (pathLib.isWithin(_rootDir.path, path)) {
                        _leftFileList = await readdir(dir.parent);
                        _rightFileList = await readdir(dir);
                        // _fileModel.currentDir = dir;
                        _fileModel.setCurrentDir(dir);
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
        : pathLib.equals(_rootDir.path, _fileModel.currentDir?.path);
    LanFileMoreTheme themeData = _themeModel.themeData;

    if (widget.mode == FileManagerMode.surf) {
      if (_fileModel.currentDir != null && _rootDir != null) {
        if (pathLib.equals(_fileModel.currentDir?.path, _rootDir.path)) {
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
                            await createSearchModal(
                              context,
                              onChangePopLocker: (val) {
                                _popLocker = val;
                              },
                            );
                            await update2Side();
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
              leading:
                  pathLib.isWithin(_rootDir.path, _fileModel.currentDir.path)
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
                  pathLib.equals(_fileModel.currentDir.path, _rootDir.path)
                      ? '/'
                      : LanFileUtils.filename(_fileModel.currentDir.path ?? ''),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
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
                      left: true,
                      selectLimit: widget.selectLimit,
                      mode: widget.mode,
                      update2Side: update2Side,
                      onChangePopLocker: (val) {
                        _popLocker = val;
                      },
                      fileList: _leftFileList,
                      onChangeCurrentDir: _fileModel.setCurrentDir,
                      onDirItemTap: (dir) async {
                        _fileModel.setCurrentDir(dir.entity);
                        List<SelfFileEntity> list = await readdir(dir.entity);
                        if (mounted) {
                          setState(() {
                            _rightFileList = list;
                          });
                        }
                      },
                    ),
                  ),
                  if (!isRootDir)
                    Expanded(
                      flex: 1,
                      child: FileListView(
                        left: false,
                        selectLimit: widget.selectLimit,
                        mode: widget.mode,
                        onChangeCurrentDir: _fileModel.setCurrentDir,
                        onChangePopLocker: (val) {
                          _popLocker = val;
                        },
                        update2Side: update2Side,
                        fileList: _rightFileList,
                        onDirItemTap: (dir) async {
                          _fileModel.setCurrentDir(dir.entity);
                          List<SelfFileEntity> list = await readdir(dir.entity);
                          if (mounted) {
                            setState(() {
                              _leftFileList = _rightFileList;
                              _rightFileList = list;
                            });
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
