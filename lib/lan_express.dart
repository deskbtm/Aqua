import 'dart:async';

import 'package:android_mix/android_mix.dart';
import 'package:catcher/core/catcher.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:lcfarm_flutter_umeng/lcfarm_flutter_umeng.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'external/bot_toast/src/toast_navigator_observer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lan_express/provider/init_provider.dart';
import 'package:lan_express/constant/constant.dart';
import 'external/bot_toast/src/bot_toast_init.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/page/home/home.dart';
import 'package:lan_express/utils/notification.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/store.dart';
import 'package:lan_express/utils/req.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'common/socket/socket.dart';
import 'generated/l10n.dart';

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

  bool _mutex;
  bool _settingLocker;

  @override
  void initState() {
    super.initState();
    _mutex = true;
    _settingLocker = true;
    LocalNotification.initLocalNotification(onSelected: (String payload) {
      debugPrint(payload);
    });

    LcfarmFlutterUmeng.init(
      androidAppKey: UMENG_APP_KEY,
      channel: MixUtils.isDev ? 'development' : 'production',
      logEnable: MixUtils.isDev,
    );
  }

  Future<void> _preLoadMsg() async {
    String baseUrl = _commonProvider?.baseUrl;
    if (baseUrl != null) {
      await req().get(baseUrl + '/assets/index.json').then((receive) async {
        dynamic data = receive.data;
        if (data['baseUrl'] != null &&
            data['baseUrl'] != baseUrl &&
            MixUtils.isHttpUrl(data['baseUrl'])) {
          await _commonProvider.setBaseUrl(data['baseUrl']);
        }
        await _commonProvider.setGobalWebData(receive.data);
      }).catchError((err) {
        BotToast.showText(text: '首次请求出现错误, 导出日志与开发者联系');
        FLog.error(text: '$err', methodName: '_preLoadMsg');
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
    if (_settingLocker) {
      _settingLocker = false;
      String theme = (await Store.getString(THEME_KEY)) ?? LIGHT_THEME;
      await _themeProvider.setTheme(theme).catchError((err) {
        FLog.error(text: '$err', methodName: 'setTheme');
      });
      await _commonProvider.initCommon().catchError((err) {
        FLog.error(text: '$err', methodName: 'initCommon');
      });
      await _preLoadMsg();
    }

    if (_mutex && _commonProvider.enableConnect != null) {
      _mutex = false;
      String internalIp = await AndroidMix.wifi.ip;
      _commonProvider.setInternalIp(internalIp);
      if (_commonProvider.enableConnect) {
        await SocketConnecter(_commonProvider)
            .searchDeviceAndConnect(limit: 10);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider.themeData;
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
          );
  }
}
