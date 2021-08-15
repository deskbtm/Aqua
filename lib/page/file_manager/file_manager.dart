import 'dart:io';
import 'dart:ui';
import 'package:aqua/page/file_manager/path_breadcrumb.dart';
import 'package:flutter/services.dart';
import 'package:unicons/unicons.dart';
import 'package:provider/provider.dart';
import 'package:aqua/model/model.dart';
import 'package:aqua/common/theme.dart';
import 'package:aqua/model/associate_view_model.dart';
import 'package:aqua/model/independent_view_model.dart';
import 'package:aqua/model/select_file_model.dart';
import 'package:aqua/page/file_manager/associate_view.dart';
import 'package:aqua/page/file_manager/independent_view.dart';
import 'package:aqua/page/file_manager/nav_bar.dart';
import 'package:aqua/external/menu/menu.dart';
import 'package:aqua/page/file_manager/search_bar.dart';
import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart' hide CupertinoNavigationBar;

class FileManager extends StatelessWidget {
  final String? appointPath;
  final Widget Function(BuildContext)? trailingBuilder;
  final int? selectLimit;
  final FileManagerMode? mode;
  final GlobalKey<InnerDrawerState>? innerDrawerKey;
  final bool displayLeading;

  const FileManager({
    Key? key,
    this.appointPath,
    this.selectLimit = 1,
    this.trailingBuilder,
    this.mode = FileManagerMode.normal,
    this.innerDrawerKey,
    this.displayLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FileManagerModel>(
          create: (_) => FileManagerModel(),
        ),
        ChangeNotifierProvider.value(
          value: selectFileModel,
        ),
      ],
      child: FileManagerPage(
        key: key,
        innerDrawerKey: innerDrawerKey,
        appointPath: appointPath,
        selectLimit: selectLimit,
        trailingBuilder: trailingBuilder,
        mode: mode,
        displayLeading: displayLeading,
      ),
    );
  }
}

class FileManagerPage extends StatefulWidget {
  ///   指定目录
  final String? appointPath;
  final Widget Function(BuildContext)? trailingBuilder;
  final int? selectLimit;
  final FileManagerMode? mode;
  final GlobalKey<InnerDrawerState>? innerDrawerKey;
  final bool displayLeading;

  const FileManagerPage({
    Key? key,
    this.appointPath,
    this.selectLimit = 1,
    this.trailingBuilder,
    this.mode = FileManagerMode.normal,
    this.innerDrawerKey,
    required this.displayLeading,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FileManagerPageState();
  }
}

class FileManagerPageState extends State<FileManagerPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ThemeModel _tm;
  late GlobalModel _gm;
  late FileManagerModel _fm;

  late bool _initMutex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _initMutex = true;

    WidgetsBinding.instance?.addObserver(this);
    // _modalKey = GlobalKey<SplitSelectionModalState>();
  }

  // GlobalKey _associateKey = GlobalKey<AssociateViewState>();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _gm = Provider.of<GlobalModel>(context);
    _fm = Provider.of<FileManagerModel>(context);

    if (_initMutex) {
      _initMutex = false;

      // 初始化阻塞UI
      await _fm.init();

      // 设置访问模式
      _setVisitMode();

      String entryPath = getStorageEntryPath();
      _fm.setEntryDir(Directory(entryPath));
      _fm.notifyListeners();
      // setState(() {});
    }
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //从后台切回来刷新界面
    if (state == AppLifecycleState.resumed) {
      if (mounted) _fm.notifyListeners();
    }
  }

  // Future<void> _intiMangerDirectory(String initialPath) async {
  //   if (getViewMode == ViewMode.independent) {
  //     await _fm
  //         .setFirstList(context, Directory(initialPath))
  //         .then((value) {
  //       _fm.setFirstCurrentDir(Directory(initialPath));
  //     });
  //     await _fm
  //         .setSecondList(context, Directory(initialPath))
  //         .then((value) {
  //       _fm.setSecondCurrentDir(Directory(initialPath), update: true);
  //     });
  //   } else {
  //     await _fm
  //         .setFirstList(context, Directory(initialPath), update: true)
  //         .then((value) {
  //       _fm.setCurrentDir(Directory(initialPath));
  //     });
  //   }
  // }

  String getStorageEntryPath() {
    switch (widget.mode) {
      case FileManagerMode.normal:
        return _gm.storageRootPath;
      case FileManagerMode.pick:
        return widget.appointPath!;
      default:
        return _gm.storageRootPath;
    }
  }

  LayoutMode get getLayoutMode => _fm.layoutMode;

  ViewMode get getViewMode => _fm.viewMode;

  AquaTheme get getTheme => _tm.themeData;

  void _setVisitMode() {
    if (widget.appointPath == null && widget.mode == FileManagerMode.pick) {
      _fm.setVisitMode(FileManagerMode.normal);
    } else {
      _fm.setVisitMode(widget.mode);
    }
  }

  // /// 拦截返回
  // Future<bool> _willPopFileRoute(
  //     bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
  //   if (_fm.isRelativeParentRoot) {
  //     _fm.setSecondListDirectly(context, null, update: true);
  //     _fm.setCurrentDir(_fm.currentDir!.parent);
  //     return false;
  //   }

  //   if (_fm.isRelativeRoot) {
  //     return false;
  //   }

  //   if (!_fm.isRelativeRoot &&
  //       !pathLib.isWithin(_fm.entryDir!.path, _fm.currentDir!.path)) {
  //     await _fm.setFirstList(context, _fm.entryDir!, update: true);
  //     return false;
  //   }

  //   _fm.setCurrentDir(_fm.currentDir!.parent);
  //   await _fm.setFirstList(context, _fm.currentDir!.parent);
  //   await _fm.setSecondList(context, _fm.currentDir!, update: true);

  //   return false;
  // }

  // List<Widget> _createAssociateWindow() {
  //   return <Widget>[
  //     Expanded(
  //       flex: 1,
  //       child: FileList(
  //         first: true,
  //         selectLimit: widget.selectLimit,
  //         mode: widget.mode!,
  //         onChangePopLocker: (val) {},
  //         list: _fm.firstList,
  //
  //         onDirTileTap: (SelfFileEntity dir) async {
  //           await _fm
  //               .setSecondList(context, dir.entity as Directory, update: true)
  //               .then((value) {
  //             _fm.setCurrentDir(dir.entity as Directory);
  //           });
  //         },
  //       ),
  //     ),
  //     if (!_fm.isRelativeRoot && _fm.secondList != null) ...[
  //       if (getLayoutMode == LayoutMode.vertical)
  //         Divider(color: Color(0xFF7BC4FF)),
  //       Expanded(
  //         flex: 1,
  //         child: FileList(
  //           first: false,
  //           selectLimit: widget.selectLimit,
  //           mode: widget.mode!,
  //
  //           onChangePopLocker: (val) {},
  //           list: _fm.secondList,
  //           onDirTileTap: (dir) async {
  //             await _fm
  //                 .setSecondList(context, dir.entity as Directory)
  //                 .then((value) async {
  //               _fm.setCurrentDir(dir.entity as Directory);
  //               await _fm.setFirstList(context, dir.entity.parent,
  //                   update: true);
  //             });
  //           },
  //         ),
  //       ),
  //     ]
  //   ];
  // }

  Future<void> _handlePathNavigate(Directory dir) async {
    // if (pathLib.equals(dir.path, _fm.entryDir?.path ?? '')) {
    //   await _fm.setSecondListDirectly(context, null);
    //   await _fm.setFirstList(context, dir, update: true);
    // } else if (pathLib.isWithin(_fm.entryDir?.path ?? '', dir.path)) {
    //   _fm.setSecondList(context, dir).then((value) async {
    //     await _fm.setFirstList(context, dir.parent, update: true);
    //   });
    // }

    // _fm.setCurrentDir(dir);
  }

  // bool get isInitSuccess {
  //   bool condition = _fm.entryDir != null;

  //   if (getViewMode == ViewMode.independent) {
  //     return condition &&
  //         _fm.firstCurrentDir != null &&
  //         _fm.secondCurrentDir != null &&
  //         _fm.secondList != null;
  //   } else {
  //     return condition && _fm.currentDir != null;
  //   }
  // }

  Widget _createBarRightMenu() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setBuilderState) {
        bool isAssociate = getViewMode == ViewMode.associate;
        bool isHorizontal = getLayoutMode == LayoutMode.horizontal;

        return FocusedMenuHolder(
          menuWidth: MediaQuery.of(context).size.width * 0.37,
          menuItemExtent: 45,
          duration: Duration(milliseconds: 100),
          maskColor: Color(0x00FFFFFF),
          menuItems: <FocusedMenuItem>[
            FocusedMenuItem(
              trailingIcon: Icon(
                isHorizontal
                    ? UniconsLine.border_vertical
                    : UniconsLine.border_horizontal,
                color: Color(0xFF007AFF),
                size: 19,
              ),
              title: isHorizontal
                  ? ThemedText(S.of(context)!.vertical)
                  : ThemedText(S.of(context)!.hoz),
              onPressed: () {
                LayoutMode mode =
                    isHorizontal ? LayoutMode.vertical : LayoutMode.horizontal;
                _fm.setLayoutMode(mode, update: true);
              },
            ),
            FocusedMenuItem(
              trailingIcon: Icon(
                UniconsLine.dice_one,
                size: 18,
              ),
              title: isAssociate
                  ? ThemedText(S.of(context)!.independent)
                  : ThemedText(S.of(context)!.associate),
              onPressed: () {
                if (isAssociate) {
                  _fm.setViewMode(ViewMode.independent);
                } else {
                  _fm.setViewMode(ViewMode.associate);
                }

                setBuilderState(() {});

                if (mounted) _fm.notifyListeners();

                Fluttertoast.showToast(
                  msg: (isAssociate
                          ? S.of(context)!.independent
                          : S.of(context)!.associate) +
                      S.of(context)!.mode,
                );
              },
            ),
            FocusedMenuItem(
              // backgroundColor: ,
              trailingIcon: Icon(
                UniconsLine.check_circle,
                size: 19,
              ),
              title: ThemedText('全选'),
              onPressed: () async {
                await Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute<void>(
                    maintainState: false,
                    builder: (BuildContext context) {
                      return FileManager(
                        appointPath: _gm.storageRootPath,
                        selectLimit: 1,
                        mode: FileManagerMode.pick,
                        displayLeading: false,
                        // 这里是FileManager的context
                        trailingBuilder: (fileCtx) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                print(fileCtx);
                              },
                              child: NoResizeText(
                                S.of(context)!.sure,
                                style: TextStyle(
                                  color: Color(0xFF007AFF),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
                // setBuilderState(() {});
              },
            ),
            FocusedMenuItem(
              // backgroundColor: ,
              trailingIcon: Icon(
                UniconsLine.exit,
                size: 18,
              ),
              title: ThemedText('退出'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
          child: Icon(
            UniconsLine.ellipsis_v,
            size: 23,
          ),
        );
      },
    );
  }

  void showRightQuickBoard() {
    widget.innerDrawerKey?.currentState
        ?.open(direction: InnerDrawerDirection.end);
  }

  void showLeftQuickBoard() {
    widget.innerDrawerKey?.currentState
        ?.open(direction: InnerDrawerDirection.end);
  }

  ObstructingPreferredSizeWidget _createNavbar() {
    return CupertinoNavigationBar(
      backgroundColor: _tm.themeData.systemNavigationBarColor,
      trailing: widget.trailingBuilder != null
          ? widget.trailingBuilder!(context)
          : Wrap(
              children: [
                GestureDetector(
                  onTap: showRightQuickBoard,
                  child: Icon(
                    UniconsLine.location_arrow,
                    size: 22,
                  ),
                ),
                SizedBox(width: 20),
                _createBarRightMenu()
              ],
            ),
      leading: widget.displayLeading
          ? GestureDetector(
              onTap: () {},
              child: Icon(
                UniconsLine.bars,
                color: Color(0xFF007AFF),
                size: 26,
              ),
            )
          : Container(),
      border: null,
      middle: PathBreadCrumb(onTap: _handlePathNavigate),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _fm.entryDir != null
        ? GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<AssociateViewModel>(
                  create: (_) => AssociateViewModel(),
                ),
                ChangeNotifierProvider<IndependentViewModel>(
                  create: (_) => IndependentViewModel(),
                ),
              ],
              child: CupertinoPageScaffold(
                backgroundColor:
                    getTheme.scaffoldBackgroundColor.withOpacity(1),
                navigationBar: _createNavbar(),
                child: SafeArea(
                  child: Column(
                    children: [
                      SearchBar(),
                      getViewMode == ViewMode.independent
                          ? IndependentView()
                          : AssociateView(),
                    ],
                  ),
                ),
              ),
            ),
          )
        : CupertinoPageScaffold(
            child: Container(
              color: getTheme.scaffoldBackgroundColor,
            ),
          );
  }
}
