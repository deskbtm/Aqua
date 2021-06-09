import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:aqua/page/file_manager/search_bar.dart';

import 'file_utils.dart';
import 'dart:developer';
import 'file_manager_mode.dart';
import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/plugin/storage/storage.dart';
import 'package:aqua/third_party/back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/dialog.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/external/breadcrumb/src/breadcrumb.dart';
import 'package:aqua/external/breadcrumb/src/breadcrumb_item.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/page/file_manager/file_list_view.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileManagerPage extends StatefulWidget {
  final String? appointPath;
  final Widget Function(BuildContext)? trailingBuilder;
  final int? selectLimit;
  final FileManagerMode? mode;
  final GlobalKey<InnerDrawerState>? innerDrawerKey;

  ///  * [appointPath] 默认外存的根目录
  const FileManagerPage({
    Key? key,
    this.appointPath,
    this.selectLimit = 1,
    this.trailingBuilder,
    this.mode = FileManagerMode.normal,
    this.innerDrawerKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileManagerPageState();
  }
}

class _FileManagerPageState extends State<FileManagerPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ThemeModel _themeModel;
  late GlobalModel _globalModel;
  late FileManagerModel _fileManagerModel;

  late GlobalKey<SplitSelectionModalState> _modalKey;
  late List<SelfFileEntity> _leftFileList;
  late List<SelfFileEntity> _rightFileList;

  late Directory? _rootDir;
  late bool _useSandboxDir;
  late bool _initMutex;
  late bool _popLocker;
  late double _totalSize;
  late double _validSize;
  // late

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _leftFileList = [];
    _rightFileList = [];
    _initMutex = true;
    _useSandboxDir = false;
    _popLocker = false;
    _totalSize = 0;
    _validSize = 0;

    WidgetsBinding.instance?.addObserver(this);
    _modalKey = GlobalKey<SplitSelectionModalState>();
    BackButtonInterceptor.add(_willPopFileRoute);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);
    _fileManagerModel = Provider.of<FileManagerModel>(context);

    if (_initMutex) {
      _initMutex = false;

      // 初始化可以不用
      await _fileManagerModel.init();

      String initialPath = getInitialPath();

      _fileManagerModel.setVisitMode(widget.mode);
      _fileManagerModel.setEntryPath(initialPath);

      log("file-root_path ========= $initialPath");
      await _changeRootPath(initialPath);
      // await getValidAndTotalStorageSize();
    }
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    BackButtonInterceptor.remove(_willPopFileRoute);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //切回来刷新下
    if (state == AppLifecycleState.resumed) {
      // if (mounted) update2Side();
    }
  }

  String getInitialPath() {
    if (widget.mode == FileManagerMode.normal || widget.appointPath == null) {
      return _globalModel.storageRootPath;
    } else {
      return widget.appointPath!;
    }
  }

  Future<List<SelfFileEntity>> readdir(Directory dir) async {
    if (_rootDir == null) {
      return [];
    }

    if (pathLib.isWithin(_rootDir!.path, dir.path) ||
        pathLib.equals(_rootDir!.path, dir.path)) {
      SelfFileList? result = await FsUtils.readdir(
        dir,
        sortType: _fileManagerModel.sortType,
        showHidden: _fileManagerModel.isDisplayHidden,
        reversed: _fileManagerModel.sortReversed,
      ).catchError((err) {});

      switch (_fileManagerModel.showOnlyType) {
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

  LayoutMode getLayoutMode() {
    return _fileManagerModel.layoutMode;
  }

  AquaTheme getTheme() {
    return _themeModel.themeData;
  }

  Future<void> _changeRootPath(String path) async {
    _rootDir = Directory(path);
    _fileManagerModel.setRootDir(Directory(path));
    _fileManagerModel.setCurrentDir(_rootDir!);
    _leftFileList = await readdir(_fileManagerModel.currentDir!);
    _rightFileList = [];
    if (mounted) setState(() {});
  }

  Future<void> _clearAllSelected(BuildContext context) async {
    _globalModel.clearSelectedFiles();

    if (mounted) {
      setState(() {});
      // showText(AppLocalizations.of(context)!.cancelSelect);
      MixUtils.safePop(context);
      // Fluttertoast.showToast(msg: content);
    }
  }

  Future<bool> _willPopFileRoute(
      bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
    if (_popLocker) {
      return false;
    }

    if (pathLib.equals(
        _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')) {
      return false;
    }

    if (pathLib.equals(
        _fileManagerModel.currentDir!.parent.path, _rootDir?.path ?? '')) {
      _fileManagerModel.setCurrentDir(_rootDir!);
      _leftFileList = await readdir(_fileManagerModel.currentDir!);

      if (mounted) {
        setState(() {
          _rightFileList = [];
        });
      }
      return false;
    }

    ///[f]
    if (pathLib.isWithin(
        _rootDir?.path ?? '', _fileManagerModel.currentDir!.path)) {
      _fileManagerModel.setCurrentDir(_fileManagerModel.currentDir!.parent);
      _leftFileList = await readdir(_fileManagerModel.currentDir!.parent);
      _rightFileList = await readdir(_fileManagerModel.currentDir!);
      if (mounted) {
        setState(() {});
      }
    }
    return false;
  }

  Future<void> updateAllFileWindows({updateView = true}) async {
    // 只有curentPath 存在的时候才读取
    if (pathLib.equals(
        _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')) {
      _leftFileList = await readdir(_fileManagerModel.currentDir!);
    } else {
      _leftFileList = await readdir(_fileManagerModel.currentDir!.parent);
      _rightFileList = await readdir(_fileManagerModel.currentDir!);
    }
    if (mounted) {
      if (updateView) {
        setState(() {});
        // await getValidAndTotalStorageSize();
      }
    }
  }

  Future<void> _showBreadcrumb() async {
    AquaTheme themeData = _themeModel.themeData;
    List<String> paths = pathLib.split(_fileManagerModel.currentDir!.path);
    return showCupertinoModal(
      context: context,
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      builder: (BuildContext context) {
        return AquaDialog(
          fontColor: themeData.itemFontColor,
          bgColor: themeData.dialogBgColor,
          title: AquaDialogTitle(title: AppLocalizations.of(context)!.select),
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

                      if (pathLib.equals(path, _rootDir?.path ?? '')) {
                        _leftFileList = await readdir(dir);
                        _rightFileList = [];
                        _fileManagerModel.setCurrentDir(dir);
                      } else if (pathLib.isWithin(_rootDir?.path ?? '', path)) {
                        _leftFileList = await readdir(dir.parent);
                        _rightFileList = await readdir(dir);
                        // _fileManagerModel.currentDir = dir;
                        _fileManagerModel.setCurrentDir(dir);
                      }
                      setState(() {});
                      MixUtils.safePop(context);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.only(top: 4, bottom: 4, right: 6, left: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: themeData.listTileColor,
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

  Future setTheme(bool val) async {
    if (val) {
      _themeModel.setTheme(DARK_THEME);
    } else {
      _themeModel.setTheme(LIGHT_THEME);
    }
  }

  List<Widget> _createFileWindows() {
    return <Widget>[
      Expanded(
        flex: 1,
        child: FileListView(
          left: true,
          selectLimit: widget.selectLimit,
          mode: widget.mode!,
          update2Side: updateAllFileWindows,
          onChangePopLocker: (val) {
            _popLocker = val;
          },
          fileList: _leftFileList,
          onChangeCurrentDir: _fileManagerModel.setCurrentDir,
          onDirTileTap: (dir) async {
            _fileManagerModel.setCurrentDir(dir.entity as Directory);
            List<SelfFileEntity> list = await readdir(dir.entity as Directory);
            if (mounted) {
              setState(() {
                _rightFileList = list;
              });
            }
          },
        ),
      ),
      if (!_getIsRootDir()) ...[
        if (getLayoutMode() == LayoutMode.vertical)
          Container(
            height: 5,
            alignment: Alignment.center,
            child: Container(
              height: 2,
              color: Color(0xFF7BC4FF),
            ),
          ),
        Expanded(
          flex: 1,
          child: FileListView(
            left: false,
            selectLimit: widget.selectLimit,
            mode: widget.mode!,
            onChangeCurrentDir: _fileManagerModel.setCurrentDir,
            onChangePopLocker: (val) {
              _popLocker = val;
            },
            update2Side: () async {},
            fileList: _rightFileList,
            onDirTileTap: (dir) async {
              _fileManagerModel.setCurrentDir(dir.entity as Directory);
              List<SelfFileEntity> list =
                  await readdir(dir.entity as Directory);
              if (mounted) {
                setState(() {
                  _leftFileList = _rightFileList;
                  _rightFileList = list;
                });
              }
            },
            scrollController: _nestedController,
          ),
        ),
      ]
    ];
  }

  bool _getIsRootDir() {
    return _leftFileList.isEmpty
        ? true
        : pathLib.equals(
            _rootDir!.path, _fileManagerModel.currentDir?.path ?? '');
  }

  void _toggleSplitWindowMode() {
    LayoutMode mode = _fileManagerModel.layoutMode;
    mode = mode == LayoutMode.horizontal
        ? LayoutMode.vertical
        : LayoutMode.horizontal;
    _fileManagerModel.setLayoutMode(mode, update: true);
  }

  ObstructingPreferredSizeWidget _createNavbar() {
    return CupertinoNavigationBar(
      backgroundColor: _themeModel.themeData.systemNavigationBarColor,
      trailing: widget.trailingBuilder != null
          ? widget.trailingBuilder!(context)
          : Wrap(
              children: [
                GestureDetector(
                  onTap: _toggleSplitWindowMode,
                  child: Icon(
                    getLayoutMode() == LayoutMode.horizontal
                        ? UniconsLine.border_vertical
                        : UniconsLine.border_horizontal,
                    color: Color(0xFF007AFF),
                    size: 25,
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {},
                  child: Icon(
                    UniconsLine.location_arrow,
                    color: Color(0xFF007AFF),
                    size: 23,
                  ),
                ),
              ],
            ),
      leading: GestureDetector(
        onTap: () {},
        child: Icon(
          UniconsLine.bars,
          color: Color(0xFF007AFF),
          size: 26,
        ),
      ),
      middle: CupertinoButton(
        padding: EdgeInsets.all(0),
        onPressed: _showBreadcrumb,
        child: NoResizeText(
          pathLib.equals(
                  _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')
              ? '/'
              : FsUtils.filename(_fileManagerModel.currentDir?.path ?? ''),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
          ),
        ),
      ),
      // backgroundColor: themeData.navBackgroundColor,
      border: null,
    );
  }

  ScrollController _nestedController = ScrollController();
  FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    AquaTheme themeData = _themeModel.themeData;

    if (widget.mode == FileManagerMode.normal) {
      if (_fileManagerModel.currentDir != null && _rootDir != null) {
        if (pathLib.equals(
            _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')) {
          _globalModel.setCanPopToDesktop(true);
        } else {
          _globalModel.setCanPopToDesktop(false);
        }
      }
    }

    return _leftFileList.isEmpty
        ? Container(color: themeData.scaffoldBackgroundColor)
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: CupertinoPageScaffold(
              backgroundColor: themeData.scaffoldBackgroundColor,
              navigationBar: _createNavbar(),
              child: SafeArea(
                  child: Column(
                children: [
                  SearchBar(),
                  Expanded(
                    child: getLayoutMode() == LayoutMode.vertical
                        ? Column(children: _createFileWindows())
                        : Row(
                            children: _createFileWindows(),
                          ),
                  ),
                ],
              )

                  // _fileManagerModel.layoutMode == LayoutMode.vertical
                  //     ? Row(children: windowView)
                  //     : Column(children: windowView),
                  ),
            ),
          );
  }
}
