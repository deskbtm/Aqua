import 'package:aqua/common/theme.dart';
import 'package:aqua/model/theme_model.dart';

import 'package:aqua/page/lan/share.dart';
import 'package:aqua/page/setting/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:aqua/model/file_model.dart';
import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/model/global_model.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ThemeModel _themeModel;
  // late CupertinoTabController _tabController;
  late GlobalModel _globalModel;
  late bool _mutex;

  // late StreamSubscription _storageSubscription;

  // Future<void> _preloadWebData() async {
  //   await req().get('/assets/ios_manager.json').then((receive) async {
  //     await _globalModel.setGobalWebData(receive.data);
  //   }).catchError((err) {});
  // }

  // Future<void> _forceReadTutorialModal() async {
  //   await showForceScopeModal(
  //     context,
  //     title: AppLocalizations.of(context)!.thankFollow,
  //     tip: AppLocalizations.of(context)!.followTip,
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
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);

    if (_mutex) {
      _mutex = false;

      // await _preloadWebData().catchError((err) {
      //   // FLog.error(text: '请求配置出错', methodName: '_preloadWebData');
      // });

      // _appIncoming = await _platform.invokeMethod('getIncomingFile');

      // setState(() {});

      // if (_globalModel.isAppNotInit) {
      //   await _forceReadTutorialModal();
      //   _globalModel.setAppInit(false);
      // }

      // Timer(Duration(seconds: 6), () async {
      //   await showRemoteMessageModal(
      //       context, _themeModel, _globalModel.gWebData);
      //   await showUpdateModal(context, _themeModel, _globalModel.gWebData);
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
  //           bottomNavColor: _themeModel.themeData.bottomNavColor,
  //           dialogBgColor: _themeModel.themeData.dialogBgColor,
  //           backgroundColor: _themeModel.themeData.scaffoldBackgroundColor,
  //           fontColor: _themeModel.themeData.itemFontColor,
  //           selectItemColor: _themeModel.themeData.itemColor,
  //           popMenuColor: _themeModel.themeData.menuItemColor,
  //           highlightTheme: setEditorTheme(
  //             _themeModel.isDark,
  //             TextStyle(
  //               color: _themeModel.themeData.itemFontColor,
  //               backgroundColor: _themeModel.themeData.scaffoldBackgroundColor,
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
  //           //   label: AppLocalizations.of(context)!.fileLabel,
  //           //   icon: Icon(OMIcons.folder),
  //           // ),
  //           BottomNavigationBarItem(
  //             label: AppLocalizations.of(context)!.lanLabel,
  //             icon: Icon(Icons.devices),
  //           ),
  //           // BottomNavigationBarItem(
  //           //   label: AppLocalizations.of(context)!.settingLabel,
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
  //         //         create: (_) => FileModel(),
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
    AquaTheme themeData = _themeModel.themeData;
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
      // innerDrawerCallback: (a) {
      //   setState(() {});
      // },
      leftChild: Container(),
      rightChild: ChangeNotifierProvider.value(
        value: fileModel,
        child: LanSharePage(),
      ),
      scaffold: ChangeNotifierProvider.value(
        value: fileModel,
        child: FileManagerPage(),
      ),
    );

    //  CupertinoTabScaffold(
    //   controller: _tabController,
    //   tabBar: CupertinoTabBar(
    //     backgroundColor: themeData.bottomNavColor,
    //     border: Border(),
    //     items: <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(
    //         label: AppLocalizations.of(context)!.fileLabel,
    //         icon: Icon(Icons.devices),
    //       ),
    //       BottomNavigationBarItem(
    //         label: AppLocalizations.of(context)!.lanLabel,
    //         icon: Icon(Icons.devices),
    //       ),
    //       BottomNavigationBarItem(
    //         label: AppLocalizations.of(context)!.settingLabel,
    //         icon: FaIcon(FontAwesomeIcons.adversal),
    //       )
    //     ],
    //   ),
    //   tabBuilder: (BuildContext context, int index) {
    //     switch (index) {
    //       case 0:
    //         return ChangeNotifierProvider(
    //           create: (BuildContext context) {
    //             return FileModel();
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
    //             create: (_) => FileModel(),
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
