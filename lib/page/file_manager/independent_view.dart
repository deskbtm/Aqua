// import 'dart:developer';
// import 'dart:io';
// import 'dart:ui';

// import 'package:fluttertoast/fluttertoast.dart';

// import 'fs_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:aqua/external/menu/menu.dart';
// import 'package:aqua/page/file_manager/search_bar.dart';
// import 'package:back_button_interceptor/back_button_interceptor.dart';
// import 'package:aqua/common/widget/inner_drawer.dart';
// import 'package:aqua/common/widget/no_resize_text.dart';
// import 'package:aqua/model/file_manager_model.dart';
// import 'package:aqua/page/file_manager/file_list.dart';
// import 'package:aqua/model/global_model.dart';
// import 'package:aqua/model/theme_model.dart';
// import 'package:aqua/common/theme.dart';
// import 'package:provider/provider.dart';
// import 'package:unicons/unicons.dart';
// import 'package:aqua/page/file_manager/path_breadcrumb.dart';
// import 'package:path/path.dart' as pathLib;
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class IndependentView extends StatefulWidget {
//   final String? appointPath;
//   final Widget Function(BuildContext)? trailingBuilder;
//   final int? selectLimit;
//   final FileManagerMode? mode;
//   final GlobalKey<InnerDrawerState>? innerDrawerKey;

//   ///  * [appointPath] 默认外存的根目录
//   const IndependentView({
//     Key? key,
//     this.appointPath,
//     this.selectLimit = 1,
//     this.trailingBuilder,
//     this.mode = FileManagerMode.normal,
//     this.innerDrawerKey,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return _IndependentViewState();
//   }
// }

// class _IndependentViewState extends State<IndependentView>
//     with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
//   late ThemeModel _themeModel;
//   late GlobalModel _globalModel;
//   late FileManagerModel _fmModel;

//   // late Directory? _rootDir;
//   late bool _initMutex;
//   // late

//   @override
//   bool get wantKeepAlive => true;

//   @override
//   void initState() {
//     super.initState();

//     _initMutex = true;

//     WidgetsBinding.instance?.addObserver(this);
//     BackButtonInterceptor.add(_willPopFileRoute);
//   }

//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//     _themeModel = Provider.of<ThemeModel>(context);
//     _globalModel = Provider.of<GlobalModel>(context);
//     _fmModel = Provider.of<FileManagerModel>(context);
//   }

//   Future<void> _intiMangerDirectory(String initialPath) async {
//     if (_fmModel.viewMode == ViewMode.independent) {
//       await _fmModel
//           .setFirstList(context, Directory(initialPath))
//           .then((value) {
//         _fmModel.setFirstCurrentDir(Directory(initialPath));
//       });
//       await _fmModel
//           .setSecondList(context, Directory(initialPath))
//           .then((value) {
//         _fmModel.setSecondCurrentDir(Directory(initialPath), update: true);
//       });
//     } else {
//       await _fmModel
//           .setFirstList(context, Directory(initialPath), update: true)
//           .then((value) {
//         _fmModel.setCurrentDir(Directory(initialPath));
//       });
//     }
//   }

//   /// 拦截返回
//   Future<bool> _willPopFileRoute(
//       bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
//     if (_fmModel.isRelativeParentRoot) {
//       _fmModel.setSecondListDirectly(context, null, update: true);
//       _fmModel.setCurrentDir(_fmModel.currentDir!.parent);
//       return false;
//     }

//     if (_fmModel.isRelativeRoot) {
//       return false;
//     }

//     if (!_fmModel.isRelativeRoot &&
//         !pathLib.isWithin(_fmModel.entryDir!.path, _fmModel.currentDir!.path)) {
//       await _fmModel.setFirstList(context, _fmModel.entryDir!, update: true);
//       return false;
//     }

//     _fmModel.setCurrentDir(_fmModel.currentDir!.parent);
//     await _fmModel.setFirstList(context, _fmModel.currentDir!.parent);
//     await _fmModel.setSecondList(context, _fmModel.currentDir!, update: true);

//     return false;
//   }

//   List<Widget> _createAssociateWindow() {
//     return <Widget>[
//       Expanded(
//         flex: 1,
//         child: FileList(
//           first: true,
//           selectLimit: widget.selectLimit,
//           mode: widget.mode!,
//           onChangePopLocker: (val) {},
//           list: _fmModel.firstList,
//           onChangeCurrentDir: (dynamic a) {},
//           onDirTileTap: (SelfFileEntity dir) async {
//             await _fmModel
//                 .setSecondList(context, dir.entity as Directory, update: true)
//                 .then((value) {
//               _fmModel.setCurrentDir(dir.entity as Directory);
//             });
//           },
//         ),
//       ),
//       if (!_fmModel.isRelativeRoot && _fmModel.secondList != null) ...[
//         if (getLayoutMode() == LayoutMode.vertical)
//           Divider(color: Color(0xFF7BC4FF)),
//         Expanded(
//           flex: 1,
//           child: FileList(
//             first: false,
//             selectLimit: widget.selectLimit,
//             mode: widget.mode!,
//             onChangeCurrentDir: (dynamic a) {},
//             onChangePopLocker: (val) {},
//             list: _fmModel.secondList,
//             onDirTileTap: (dir) async {
//               await _fmModel
//                   .setSecondList(context, dir.entity as Directory)
//                   .then((value) async {
//                 _fmModel.setCurrentDir(dir.entity as Directory);
//                 await _fmModel.setFirstList(context, dir.entity.parent,
//                     update: true);
//               });
//             },
//           ),
//         ),
//       ]
//     ];
//   }

//   Future<void> _handlePathNavigate(Directory dir) async {
//     if (pathLib.equals(dir.path, _fmModel.entryDir?.path ?? '')) {
//       await _fmModel.setSecondListDirectly(context, null);
//       await _fmModel.setFirstList(context, dir, update: true);
//     } else if (pathLib.isWithin(_fmModel.entryDir?.path ?? '', dir.path)) {
//       _fmModel.setSecondList(context, dir).then((value) async {
//         await _fmModel.setFirstList(context, dir.parent, update: true);
//       });
//     }

//     _fmModel.setCurrentDir(dir);
//   }

//   bool get initSuccess {
//     bool condition = _fmModel.firstList != null && _fmModel.entryDir != null;

//     if (_fmModel.viewMode == ViewMode.independent) {
//       return condition &&
//           _fmModel.firstCurrentDir != null &&
//           _fmModel.secondCurrentDir != null &&
//           _fmModel.secondList != null;
//     } else {
//       return condition && _fmModel.currentDir != null;
//     }
//   }

//   Widget _createBarRightMenu() {
//     return StatefulBuilder(
//         builder: (BuildContext context, StateSetter setBuilerState) {
//       bool isAssociate = _fmModel.viewMode == ViewMode.associate;
//       return FocusedMenuHolder(
//         menuWidth: MediaQuery.of(context).size.width * 0.37,
//         menuItemExtent: 45,
//         duration: Duration(milliseconds: 100),
//         maskColor: Color(0x00FFFFFF),
//         menuItems: <FocusedMenuItem>[
//           FocusedMenuItem(
//             trailingIcon: Icon(
//               UniconsLine.dice_one,
//               size: 18,
//             ),
//             title: isAssociate
//                 ? ThemedText(S.of(context)!.independent + S.of(context)!.mode)
//                 : ThemedText(S.of(context)!.associate + S.of(context)!.mode),
//             onPressed: () {
//               if (isAssociate) {
//                 _fmModel.setViewMode(ViewMode.independent);
//               } else {
//                 _fmModel.setViewMode(ViewMode.associate);
//               }

//               setBuilerState(() {});

//               Fluttertoast.showToast(
//                 msg: (isAssociate
//                         ? S.of(context)!.independent
//                         : S.of(context)!.associate) +
//                     S.of(context)!.mode,
//               );
//             },
//           ),
//           FocusedMenuItem(
//             // backgroundColor: ,
//             trailingIcon: Icon(
//               UniconsLine.location_arrow,
//               size: 18,
//             ),
//             title: ThemedText('网络'),
//             onPressed: () {
//               widget.innerDrawerKey?.currentState
//                   ?.open(direction: InnerDrawerDirection.end);
//             },
//           ),
//         ],
//         child: Icon(
//           UniconsLine.ellipsis_v,
//           size: 23,
//         ),
//       );
//     });
//   }

//   void _toggleSplitWindowMode() {
//     LayoutMode mode = _fmModel.layoutMode;
//     mode = mode == LayoutMode.horizontal
//         ? LayoutMode.vertical
//         : LayoutMode.horizontal;
//     _fmModel.setLayoutMode(mode, update: true);
//   }

//   ObstructingPreferredSizeWidget _createNavbar() {
//     return CupertinoNavigationBar(
//       backgroundColor: _themeModel.themeData.systemNavigationBarColor,
//       trailing: widget.trailingBuilder != null
//           ? widget.trailingBuilder!(context)
//           : Wrap(
//               children: [
//                 GestureDetector(
//                   onTap: _toggleSplitWindowMode,
//                   child: Icon(
//                     getLayoutMode() == LayoutMode.horizontal
//                         ? UniconsLine.border_vertical
//                         : UniconsLine.border_horizontal,
//                     color: Color(0xFF007AFF),
//                     size: 25,
//                   ),
//                 ),
//                 SizedBox(width: 20),
//                 _createBarRightMenu()
//               ],
//             ),
//       leading: GestureDetector(
//         onTap: () {},
//         child: Icon(
//           UniconsLine.bars,
//           color: Color(0xFF007AFF),
//           size: 26,
//         ),
//       ),
//       border: null,
//       middle: PathBreadCrumb(onTap: _handlePathNavigate),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     log(_fmModel.currentDir != null ? _fmModel.currentDir!.path : '',
//         name: 'current dir');

//     if (widget.mode == FileManagerMode.normal) {
//       if (_fmModel.currentDir != null && _fmModel.entryDir != null) {
//         if (_fmModel.isRelativeRoot) {
//           _globalModel.setCanPopToDesktop(true);
//         } else {
//           _globalModel.setCanPopToDesktop(false);
//         }
//       }
//     }

//     // bool shouldLoad = _fmModel.

//     return initSuccess
//         ? GestureDetector(
//             onTap: () {
//               FocusScope.of(context).requestFocus(FocusNode());
//             },
//             child: CupertinoPageScaffold(
//               backgroundColor:
//                   getTheme().scaffoldBackgroundColor.withOpacity(1),
//               navigationBar: _createNavbar(),
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     SearchBar(),
//                     Expanded(
//                       child: getLayoutMode() == LayoutMode.vertical
//                           ? Column(children: _createAssociateWindow())
//                           : Row(children: _createAssociateWindow()),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : CupertinoPageScaffold(
//             child: Container(
//               color: getTheme().scaffoldBackgroundColor,
//             ),
//           );
//   }
// }
