import 'dart:async';
import 'package:aqua/page/file_editor/editor_theme.dart';
import 'package:aqua/page/file_editor/file_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aqua/common/widget/modal/show_specific_modal.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/constant/constant_var.dart';

import 'package:aqua/model/file_model.dart';
import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/page/lan/lan.dart';
import 'package:aqua/page/not_support/not_support.dart';
import 'package:aqua/page/photo_viewer/photo_viewer.dart';
import 'package:aqua/page/setting/setting.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/video/meida_info.dart';
import 'package:aqua/page/video/video.dart';
import 'package:aqua/utils/req.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as pathLib;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MethodChannel _platform = const MethodChannel(SHARED_CHANNEL);
  late ThemeModel _themeModel;
  late CupertinoTabController _tabController;
  late CommonModel _commonModel;
  late bool _mutex;

  // late StreamSubscription _storageSubscription;

  Future<void> _preloadWebData() async {
    await req().get('/assets/ios_manager.json').then((receive) async {
      await _commonModel.setGobalWebData(receive.data);
    }).catchError((err) {});
  }

  Future<void> _forceReadTutorialModal() async {
    await showForceScopeModal(
      context,
      title: AppLocalizations.of(context)!.thankFollow,
      tip: AppLocalizations.of(context)!.followTip,
      defaultOkText: 'Github star',
      onOk: () async {
        if (await canLaunch(GITHUB)) {
          await launch(GITHUB);
        }
      },
      defaultCancelText: 'bilibili',
      onCancel: () async {
        if (await canLaunch(BILIBILI_SPACE)) {
          await launch(BILIBILI_SPACE);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 0);
    _mutex = true;

    // _storageSubscription = StorageMountListener.channel
    //     .receiveBroadcastStream()
    //     .listen((event) {});
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);

    if (_mutex) {
      _mutex = false;

      await _preloadWebData().catchError((err) {
        // FLog.error(text: '请求配置出错', methodName: '_preloadWebData');
      });

      // _appIncoming = await _platform.invokeMethod('getIncomingFile');

      setState(() {});

      if (_commonModel.isAppNotInit) {
        await _forceReadTutorialModal();
        _commonModel.setAppInit(false);
      }

      Timer(Duration(seconds: 6), () async {
        await showRemoteMessageModal(
            context, _themeModel, _commonModel.gWebData);
        await showUpdateModal(context, _themeModel, _commonModel.gWebData);
      });
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
  //           backgroundColor: _themeModel.themeData?.scaffoldBackgroundColor,
  //           fontColor: _themeModel.themeData?.itemFontColor,
  //           selectItemColor: _themeModel.themeData?.itemColor,
  //           popMenuColor: _themeModel.themeData?.menuItemColor,
  //           highlightTheme: setEditorTheme(
  //             _themeModel.isDark,
  //             TextStyle(
  //               color: _themeModel.themeData?.itemFontColor,
  //               backgroundColor: _themeModel.themeData?.scaffoldBackgroundColor,
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

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;
    // themeData == null
    // ? Container(color: themeData.scaffoldBackgroundColor)
    // :
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        backgroundColor: themeData.bottomNavColor,
        border: Border(),
        items: <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   label: AppLocalizations.of(context)!.fileLabel,
          //   icon: Icon(OMIcons.folder),
          // ),
          BottomNavigationBarItem(
            label: AppLocalizations.of(context)!.lanLabel,
            icon: Icon(Icons.devices),
          ),
          // BottomNavigationBarItem(
          //   label: AppLocalizations.of(context)!.settingLabel,
          //   icon: Icon(OMIcons.settings),
          // )
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) => FileManagerPage(
            mode: FileManagerMode.surf,
          ),
        );
        // switch (index) {
        //   case 0:
        //     return CupertinoTabView(
        //       builder: (context) => FileManagerPage(
        //         mode: FileManagerMode.surf,
        //       ),
        //     );
        //   case 1:
        //     return CupertinoTabView(
        //       builder: (context) => LanPage(),
        //     );
        //   case 2:
        //     return CupertinoTabView(
        //       builder: (context) => ChangeNotifierProvider(
        //         create: (_) => FileModel(),
        //         child: SettingPage(
        //           gTabController: _tabController,
        //         ),
        //       ),
        //     );
        //   default:
        //     assert(false, 'Unexpected tab');
        //     return null;
        // }
      },
    );
  }
}
