import 'dart:async';
import 'dart:developer';

// import 'package:android_tile_service/android_tile_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/model/file_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/theme.dart';

import 'generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'external/bot_toast/src/toast_navigator_observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'external/bot_toast/src/bot_toast_init.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/page/home/home.dart';
import 'package:lan_file_more/utils/notification.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/store.dart';
import 'package:provider/provider.dart';

class LanFileMore extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanFileMoreState();
  }
}

class _LanFileMoreState extends State<LanFileMore> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(),
        ),
        ChangeNotifierProvider<CommonModel>(
          create: (_) => CommonModel(),
        ),
        ChangeNotifierProvider<FileModel>(
          create: (_) => FileModel(),
        ),
      ],
      child: LanFileMoreWrapper(),
    );
  }
}

class LanFileMoreWrapper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanFileMoreWrapperState();
  }
}

class _LanFileMoreWrapperState extends State {
  ThemeModel _themeModel;
  CommonModel _commonModel;

  bool _prepared;
  bool _settingMutex;

  StreamSubscription<ConnectivityResult> _connectSubscription;

  @override
  void initState() {
    super.initState();
    _prepared = false;
    _settingMutex = true;

    // AndroidTileService.init(tileIcon: 'vscode', label: 'vscode');
    // AndroidTileService.listen(onClick: () async {
    //   print("demo ===============================");
    // });

    LocalNotification.initLocalNotification(onSelected: (String payload) {
      debugPrint(payload);
    });

    _connectSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      String internalIp = await Connectivity().getWifiIP();
      await _commonModel.setInternalIp(internalIp);
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);

    if (_settingMutex) {
      _settingMutex = false;
      String theme = (await Store.getString(THEME_KEY)) ?? LIGHT_THEME;
      await _themeModel.setTheme(theme).catchError((err) {
        recordError(text: '', exception: err, methodName: 'setTheme');
      });
      await _commonModel.initCommon().catchError((err) {
        recordError(text: '', exception: err, methodName: 'initCommon');
      });

      if (_commonModel.enableConnect != null) {
        String internalIp = await Connectivity().getWifiIP();
        await _commonModel.setInternalIp(internalIp);
      }
      setState(() {
        _prepared = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connectSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    log("root render ====== (prepared = $_prepared)");
    LanFileMoreTheme themeData = _themeModel.themeData;

    return _prepared
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            /// 系统虚拟按键主题
            value: SystemUiOverlayStyle(
              systemNavigationBarIconBrightness:
                  themeData.systemNavigationBarIconBrightness,
              systemNavigationBarColor: themeData.systemNavigationBarColor,
            ),
            child: CupertinoApp(
              // navigatorKey: Catcher.navigatorKey,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              builder: BotToastInit(),
              navigatorObservers: [
                BotToastNavigatorObserver(),
              ],

              /// 灵感来自爱死亡机器人
              title: '局域网.文件.更多',
              theme: CupertinoThemeData(
                scaffoldBackgroundColor: themeData.scaffoldBackgroundColor,
                textTheme: CupertinoTextThemeData(
                  textStyle: TextStyle(
                    color: themeData.itemFontColor,
                  ),
                ),
              ),
              home: WillPopScope(
                child: HomePage(),
                onWillPop: () async {
                  return false;
                },
              ),
            ),
          )
        : Container();
  }
}
