import 'dart:async';

import 'package:catcher/core/catcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/page/home/home.dart';
import 'package:lan_express/provider/device.dart';
import 'package:lan_express/provider/init_provider.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/store.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
// import 'package:sqflite_sqlcipher/sqflite.dart';
import 'common/socket/socket.dart';
import 'external/bot_toast/src/bot_toast_init.dart';
import 'external/bot_toast/src/toast_navigator_observer.dart';
import 'generated/l10n.dart';
import 'package:path/path.dart' as pathLib;

class LanExpress extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanExpressState();
  }
}

class _LanExpressState extends State<LanExpress> {
  @override
  Widget build(BuildContext context) {
    return InitProvider.init(
      child: LanExpressWrapper(),
    );
  }
}

class LanExpressWrapper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanExpressWrapperState();
  }
}

class _LanExpressWrapperState extends State {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;
  Timer _timer;
  bool _locker;

  Future<void> _preLoadTheme() async {
    ThemeProvider tp = Provider.of<ThemeProvider>(context, listen: false);
    String theme = (await Store.getString(THEME_KEY)) ?? DARK_THEME;
    tp.setTheme(theme);
  }

  Future<void> _preLoadDeviceInfo() async {
    NativeProvider dp = Provider.of<NativeProvider>(context, listen: false);
    await dp.initNative();
  }

  Future<void> _preLoadSettings() async {
    CommonProvider dp = Provider.of<CommonProvider>(context, listen: false);
    await dp.initCommon();
  }

  @override
  void initState() {
    super.initState();
    _preLoadTheme();
    _preLoadDeviceInfo();
    _preLoadSettings();
    _locker = true;
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> _clipboardListener() async {
    ClipboardData content = await Clipboard.getData(Clipboard.kTextPlain);
    _commonProvider.socket?.emit(CLIPBOARD_TO_SERVER, content.text);
  }

  void createSocketIOClient() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_commonProvider.aliveIps.isNotEmpty) {
        _timer?.cancel();
        String port = _commonProvider.expressPort;
        String ip = _commonProvider.aliveIps.first;
        String internalIp = _commonProvider.internalIp;

        createMySocketClient(
          internalIp: internalIp,
          ip: ip,
          port: port,
          isInit: true,
          onInitSocket: (socket) {
            _commonProvider.setSocket(socket);
          },
          onConnect: (socket) {
            _commonProvider.setSocket(socket);
            ClipboardListener.addListener(_clipboardListener);
          },
          onDisconnect: (_) {
            ClipboardListener.removeListener(_clipboardListener);
          },
        );
      }
    });
  }

  // void connectSqlite() async {
  //   String path = pathLib.join(await getDatabasesPath(), 'lan_express.db');
  //   Database db = await openDatabase(path, password: SQL_PWD);
  //   var res = await db.rawQuery(
  //       "select * from Sqlite_master where type = 'table' and name = 'lan_express'");
  //   print(res);
  // }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
    String internalIp = _commonProvider?.internalIp;
    if (_locker) {
      if (internalIp != null) {
        _locker = false;
        MixUtils.scanSubnet(_commonProvider);

        debugPrint('aliveIps: ' + _commonProvider.aliveIps.toString());
        createSocketIOClient();
        // connectSqlite();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_commonProvider?.internalIp);
    dynamic themeData = _themeProvider?.themeData;
    return themeData == null
        ? Container()
        : CupertinoApp(
            navigatorKey: Catcher.navigatorKey,
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            builder: BotToastInit(),
            navigatorObservers: [BotToastNavigatorObserver()],

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
                BotToast.showText(
                    text: '请从后台退出',
                    contentColor: _themeProvider.themeData?.toastColor);
                return false;
              },
            ),
          );
  }
}

// IO.Socket socket = IO.io(url, {
//           'transports': ['websocket'],
//           'autoConnect': true
//         });

//         _commonProvider.setSocket(socket);

//         socket.on('connect', (_) {
//           BotToast.showSimpleNotification(
//             title: '已自动连接至',
//             subTitle: url,
//             closeIcon: Icon(Icons.close),
//             duration: Duration(seconds: 8),
//           );
//           _commonProvider.setSocket(socket);
//           socket.emit(
//               CONNECTED_ADDRESS, '${_commonProvider.internalIp}:$port');
//         });

//         socket.on('disconnect', (_) {
//           BotToast.showSimpleNotification(
//             title: '$url已断开连接',
//             closeIcon: Icon(Icons.close),
//           );
//         });

//         socket.on('connect_error', (error) {
//           FLog.error(
//               text: error.toString(), methodName: 'createSocketIOClient');
//         });
