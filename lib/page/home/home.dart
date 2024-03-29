import 'package:aqua/model/select_file_model.dart';
import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/page/home/left_quick_board.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/common/theme.dart';
import 'package:aqua/page/home/right_quick_board.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ThemeModel _tm;
  // late CupertinoTabController _tabController;
  late GlobalModel _gm;
  late bool _mutex;

  // late StreamSubscription _storageSubscription;

  // Future<void> _preloadWebData() async {
  //   await req().get('/assets/ios_manager.json').then((receive) async {
  //     await _gm.setGobalWebData(receive.data);
  //   }).catchError((err) {});
  // }

  // Future<void> _forceReadTutorialModal() async {
  //   await showForceScopeModal(
  //     context,
  //     title: S.of(context)!.thankFollow,
  //     tip: S.of(context)!.followTip,
  //     defaultOkText: 'Github star',
  //     onOk: () async {
  //       if (await canLaunch(GITHUB)) {
  //         await launch(GITHUB);
  //       }
  //     },
  //     defaultCancelText: 'bilibili',
  //     onCancel: () async {
  //       if (await canLaunch(BILIBILI_SPACE)) {
  //         await launch(BILIBILI_SPACE);
  //       }
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();

    // _tabController = CupertinoTabController(initialIndex: 0);
    _mutex = true;

    // _storageSubscription = StorageMountListener.channel
    //     .receiveBroadcastStream()
    //     .listen((event) {});
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _gm = Provider.of<GlobalModel>(context);

    if (_mutex) {
      _mutex = false;

      // await _preloadWebData().catchError((err) {
      //   // FLog.error(text: '请求配置出错', methodName: '_preloadWebData');
      // });

      // _appIncoming = await _platform.invokeMethod('getIncomingFile');

      // setState(() {});

      // if (_gm.isAppNotInit) {
      //   await _forceReadTutorialModal();
      //   _gm.setAppInit(false);
      // }

      // Timer(Duration(seconds: 6), () async {
      //   await showRemoteMessageModal(
      //       context, _tm, _gm.gWebData);
      //   await showUpdateModal(context, _tm, _gm.gWebData);
      // });
    }
  }

  // Widget _switchEntryPage(Map _incomingFile, {AquaTheme? themeData}) {
  //   if (_incomingFile != null && _incomingFile['appMode'] == 'incoming') {
  //     String ext = pathLib.extension(_incomingFile['path']).toLowerCase();
  //     String filename = pathLib.basename(_incomingFile['path']);
  //     String path = _incomingFile['path'];

  //     return FsUtils.matchEntryByMimeType(
  //       _incomingFile['type'],
  //       caseImage: () {
  //         return PhotoViewerPage(
  //           imageRes: [path],
  //           index: 0,
  //         );
  //       },
  //       caseText: () {
  //         return FileEditorPage(
  //           path: path,
  //           language: ext.replaceFirst(RegExp(r'.'), ''),
  //           bottomNavColor: _tm.themeData.bottomNavColor,
  //           dialogBgColor: _tm.themeData.dialogBgColor,
  //           backgroundColor: _tm.themeData.scaffoldBackgroundColor,
  //           fontColor: _tm.themeData.itemFontColor,
  //           selectItemColor: _tm.themeData.itemColor,
  //           popMenuColor: _tm.themeData.menuItemColor,
  //           highlightTheme: setEditorTheme(
  //             _tm.isDark,
  //             TextStyle(
  //               color: _tm.themeData.itemFontColor,
  //               backgroundColor: _tm.themeData.scaffoldBackgroundColor,
  //             ),
  //           ),
  //         );
  //       },
  //       caseVideo: () {
  //         return VideoPage(
  //           info: MediaInfo(
  //             name: filename,
  //             path: path,
  //           ),
  //         );
  //       },
  //       caseDefault: () {
  //         return NotSupportPage(
  //           path: path,
  //         );
  //       },
  //     );
  //   } else {
  //     return CupertinoTabScaffold(
  //       controller: _tabController,
  //       tabBar: CupertinoTabBar(
  //         backgroundColor: themeData.bottomNavColor,
  //         border: Border(),
  //         items: <BottomNavigationBarItem>[
  //           // BottomNavigationBarItem(
  //           //   label: S.of(context)!.fileLabel,
  //           //   icon: Icon(OMIcons.folder),
  //           // ),
  //           BottomNavigationBarItem(
  //             label: S.of(context)!.lanLabel,
  //             icon: Icon(Icons.devices),
  //           ),
  //           // BottomNavigationBarItem(
  //           //   label: S.of(context)!.settingLabel,
  //           //   icon: Icon(OMIcons.settings),
  //           // )
  //         ],
  //       ),
  //       tabBuilder: (BuildContext context, int index) {
  //         return CupertinoTabView(
  //           builder: (context) => FileManagerPage(
  //             mode: FileManagerMode.surf,
  //           ),
  //         );
  //         // switch (index) {
  //         //   case 0:
  //         //     return CupertinoTabView(
  //         //       builder: (context) => FileManagerPage(
  //         //         mode: FileManagerMode.surf,
  //         //       ),
  //         //     );
  //         //   case 1:
  //         //     return CupertinoTabView(
  //         //       builder: (context) => LanPage(),
  //         //     );
  //         //   case 2:
  //         //     return CupertinoTabView(
  //         //       builder: (context) => ChangeNotifierProvider(
  //         //         create: (_) => FileManagerModel(),
  //         //         child: SettingPage(
  //         //           gTabController: _tabController,
  //         //         ),
  //         //       ),
  //         //     );
  //         //   default:
  //         //     assert(false, 'Unexpected tab');
  //         //     return null;
  //         // }
  //       },
  //     );
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
    // _storageSubscription.cancel();
  }

  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _tm.themeData;
    // themeData == null
    // ? Container(color: themeData.scaffoldBackgroundColor)
    // :
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      boxShadow: [],
      swipe: true,
      colorTransitionChild: Colors.transparent,
      colorTransitionScaffold: Colors.transparent,
      offset: IDOffset.only(top: 0.2, right: 0.4, left: 0.4),
      scale: IDOffset.horizontal(0.6),
      proportionalChildArea: true,
      borderRadius: 8,
      leftAnimationType: InnerDrawerAnimation.quadratic,
      rightAnimationType: InnerDrawerAnimation.quadratic,
      backgroundDecoration:
          BoxDecoration(color: themeData.scaffoldBackgroundColor),
      // innerDrawerCallback: _handleDrawCallback,
      leftChild: LeftQuickBoard(),
      rightChild: ChangeNotifierProvider.value(
        value: selectFileModel,
        child: RightQuickBoard(),
      ),
      scaffold: FileManager(
        innerDrawerKey: _innerDrawerKey,
      ),
    );

    //  CupertinoTabScaffold(
    //   controller: _tabController,
    //   tabBar: CupertinoTabBar(
    //     backgroundColor: themeData.bottomNavColor,
    //     border: Border(),
    //     items: <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(
    //         label: S.of(context)!.fileLabel,
    //         icon: Icon(Icons.devices),
    //       ),
    //       BottomNavigationBarItem(
    //         label: S.of(context)!.lanLabel,
    //         icon: Icon(Icons.devices),
    //       ),
    //       BottomNavigationBarItem(
    //         label: S.of(context)!.settingLabel,
    //         icon: Icon(FontAwesomeIcons.adversal),
    //       )
    //     ],
    //   ),
    //   tabBuilder: (BuildContext context, int index) {
    //     switch (index) {
    //       case 0:
    //         return ChangeNotifierProvider(
    //           create: (BuildContext context) {
    //             return FileManagerModel();
    //           },
    //           child: FileManagerPage(
    //             mode: FileManagerMode.surf,
    //           ),
    //         );
    //       case 1:
    //         return CupertinoTabView(
    //           builder: (context) => LanPage(),
    //         );
    //       case 2:
    //         return CupertinoTabView(
    //           builder: (context) => ChangeNotifierProvider(
    //             create: (_) => FileManagerModel(),
    //             child: SettingPage(
    //               gTabController: _tabController,
    //             ),
    //           ),
    //         );
    //       default:
    //         assert(false, 'Unexpected tab');
    //         return Container();
    //     }
    //   },
    // );
  }
}
