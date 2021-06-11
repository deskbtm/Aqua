import 'dart:io';
import 'dart:ui';
import 'dart:async';

import 'package:aqua/page/file_manager/fs_ui_utils.dart';
import 'package:aqua/page/file_manager/search_bar.dart';
import 'package:aqua/plugin/storage/storage.dart';

import 'fs_utils.dart';
import 'dart:developer';

import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/third_party/back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/page/file_manager/file_list.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:unicons/unicons.dart';
import 'package:intent/intent.dart' as intent;

import 'package:intent/action.dart' as android_action;

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

  // late Directory? _rootDir;
  late bool _initMutex;
  // late

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _leftFileList = [];
    _rightFileList = [];
    _initMutex = true;

    // 从后台返回刷新文件
    WidgetsBinding.instance?.addObserver(this);
    _modalKey = GlobalKey<SplitSelectionModalState>();
    // BackButtonInterceptor.add(_willPopFileRoute);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);
    _fileManagerModel = Provider.of<FileManagerModel>(context);

    if (_initMutex) {
      _initMutex = false;

      // 初始化阻塞UI
      await _fileManagerModel.storageInit();

      _initFileManagerModel();
      setState(() {});

      // _leftFileList =
      //     await FsUIUtils.readdirSafely(context, _fileManagerModel.currentDir!);
      // _rightFileList = [];

      // log("file-root_path ========= $initialPath");
      // await _changeRootPath(initialPath);
      // await getValidAndTotalStorageSize();
    }
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    // BackButtonInterceptor.remove(_willPopFileRoute);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //切回来刷新下
    if (state == AppLifecycleState.resumed) {
      // if (mounted) update2Side();
    }
  }

  void _initFileManagerModel() {
    String initialPath = getInitialPath();
    _fileManagerModel.setVisitMode(widget.mode);
    _fileManagerModel.setEntryDir(Directory(initialPath));
    _fileManagerModel.setCurrentDir(Directory(initialPath));
  }

  String getInitialPath() {
    if (widget.mode == FileManagerMode.normal || widget.appointPath == null) {
      return _globalModel.storageRootPath;
    } else {
      return widget.appointPath!;
    }
  }

  // Future<List<SelfFileEntity>> readdir(Directory dir) async {
  //   if (_rootDir == null) {
  //     return [];
  //   }

  //   if (pathLib.isWithin(_rootDir!.path, dir.path) ||
  //       pathLib.equals(_rootDir!.path, dir.path)) {
  //     SelfFileList? result = await FsUtils.readdir(
  //       dir,
  //       sortType: _fileManagerModel.sortType,
  //       showHidden: _fileManagerModel.isDisplayHidden,
  //       reversed: _fileManagerModel.sortReversed,
  //     ).catchError((err) {
  //       print(err.toString());
  //     });

  //     switch (_fileManagerModel.showOnlyType) {
  //       case ShowOnlyType.all:
  //         return result?.allList ?? [];
  //       case ShowOnlyType.file:
  //         return result?.fileList ?? [];
  //       case ShowOnlyType.folder:
  //         return result?.folderList ?? [];
  //       case ShowOnlyType.link:
  //         return result?.linkList ?? [];
  //       default:
  //         return result?.allList ?? [];
  //     }
  //   } else {
  //     return [];
  //   }
  // }

  LayoutMode getLayoutMode() {
    return _fileManagerModel.layoutMode;
  }

  AquaTheme getTheme() {
    return _themeModel.themeData;
  }

  // Future<void> _changeRootPath(String path) async {
  //   _rootDir = Directory(path);
  //   _fileManagerModel.setCurrentDir(_rootDir!);
  //   _leftFileList = await readdir(_fileManagerModel.currentDir!);
  //   _rightFileList = [];
  //   if (mounted) setState(() {});
  // }

  // Future<void> _clearAllSelected(BuildContext context) async {
  //   _globalModel.clearSelectedFiles();

  //   if (mounted) {
  //     setState(() {});
  //     // showText(AppLocalizations.of(context)!.cancelSelect);
  //     MixUtils.safePop(context);
  //     // Fluttertoast.showToast(msg: content);
  //   }
  // }

  // Future<bool> _willPopFileRoute(
  //     bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
  //   if (_popLocker) {
  //     return false;
  //   }

  //   if (pathLib.equals(
  //       _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')) {
  //     return false;
  //   }

  //   if (pathLib.equals(
  //       _fileManagerModel.currentDir!.parent.path, _rootDir?.path ?? '')) {
  //     _fileManagerModel.setCurrentDir(_rootDir!);
  //     _leftFileList = await readdir(_fileManagerModel.currentDir!);

  //     if (mounted) {
  //       setState(() {
  //         _rightFileList = [];
  //       });
  //     }
  //     return false;
  //   }

  //   ///[f]
  //   if (pathLib.isWithin(
  //       _rootDir?.path ?? '', _fileManagerModel.currentDir!.path)) {
  //     _fileManagerModel.setCurrentDir(_fileManagerModel.currentDir!.parent);
  //     _leftFileList = await readdir(_fileManagerModel.currentDir!.parent);
  //     _rightFileList = await readdir(_fileManagerModel.currentDir!);
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   }
  //   return false;
  // }

  // Future<void> updateAllFileWindows({updateView = true}) async {
  //   // 只有curentPath 存在的时候才读取
  //   if (pathLib.equals(
  //       _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')) {
  //     _leftFileList = await readdir(_fileManagerModel.currentDir!);
  //   } else {
  //     _leftFileList = await readdir(_fileManagerModel.currentDir!.parent);
  //     _rightFileList = await readdir(_fileManagerModel.currentDir!);
  //   }
  //   if (mounted) {
  //     if (updateView) {
  //       setState(() {});
  //       // await getValidAndTotalStorageSize();
  //     }
  //   }
  // }

  List<Widget> _createFileWindows() {
    return <Widget>[
      Expanded(
        flex: 1,
        child: FileList(
          left: true,
          selectLimit: widget.selectLimit,
          mode: widget.mode!,
          update2Side: () async {},
          onChangePopLocker: (val) {},
          // fileList: _leftFileList,
          onChangeCurrentDir: _fileManagerModel.setCurrentDir,
          onDirTileTap: (dir) async {
            // _fileManagerModel.setCurrentDir(dir.entity as Directory);
            // List<SelfFileEntity> list = await readdir(dir.entity as Directory);
            // if (mounted) {
            //   setState(() {
            //     _rightFileList = list;
            //   });
            // }
          },
        ),
      ),
      if (false) ...[
        if (getLayoutMode() == LayoutMode.vertical)
          Divider(color: Color(0xFF7BC4FF)),
        Expanded(
          flex: 1,
          child: FileList(
            left: false,
            selectLimit: widget.selectLimit,
            mode: widget.mode!,
            onChangeCurrentDir: _fileManagerModel.setCurrentDir,
            onChangePopLocker: (val) {},
            update2Side: () async {},
            // fileList: _rightFileList,
            onDirTileTap: (dir) async {
              // _fileManagerModel.setCurrentDir(dir.entity as Directory);
              // List<SelfFileEntity> list =
              //     await readdir(dir.entity as Directory);
              // if (mounted) {
              //   setState(() {
              //     _leftFileList = _rightFileList;
              //     _rightFileList = list;
              //   });
              // }
            },
          ),
        ),
      ]
    ];
  }

  // bool _getIsRootDir() {
  //   return _leftFileList.isEmpty
  //       ? true
  //       : pathLib.equals(
  //           _rootDir!.path, _fileManagerModel.currentDir?.path ?? '');
  // }

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
        onPressed: () async {},
        child: NoResizeText(
          'de',
          // pathLib.equals(
          //         _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')
          //     ? '/'
          //     : FsUtils.filename(_fileManagerModel.currentDir?.path ?? ''),
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

  FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    AquaTheme themeData = _themeModel.themeData;

    // if (widget.mode == FileManagerMode.normal) {
    //   if (_fileManagerModel.currentDir != null && _rootDir != null) {
    //     if (pathLib.equals(
    //         _fileManagerModel.currentDir!.path, _rootDir?.path ?? '')) {
    //       _globalModel.setCanPopToDesktop(true);
    //     } else {
    //       _globalModel.setCanPopToDesktop(false);
    //     }
    //   }
    // }

    return _fileManagerModel.currentDir == null
        ? Container(color: themeData.scaffoldBackgroundColor)
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: CupertinoPageScaffold(
              backgroundColor: themeData.scaffoldBackgroundColor.withOpacity(1),
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
                ),
              ),
            ),
          );
  }
}
