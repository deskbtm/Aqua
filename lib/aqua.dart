import 'dart:async';
import 'dart:developer';
import 'package:aqua/page/home/home.dart';
import 'package:aqua/third_party/connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:aqua/common/widget/double_pop.dart';
import 'package:aqua/common/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Aqua extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AquaState();
  }
}

class _AquaState extends State<Aqua> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeModel>(
          create: (_) => ThemeModel(),
        ),
        ChangeNotifierProvider<GlobalModel>(
          create: (_) => GlobalModel(),
        ),
      ],
      child: AquaWrapper(),
    );
  }
}

class AquaWrapper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AquaWrapperState();
  }
}

class _AquaWrapperState extends State<AquaWrapper> {
  late ThemeModel _tm;
  late GlobalModel _gm;
  late bool _envPrepared;

  late StreamSubscription<ConnectivityResult> _connectSubscription;

  @override
  void initState() {
    super.initState();
    _envPrepared = false;

    LocalNotification.initLocalNotification(
        onSelected: (String? payload) async {
      debugPrint(payload);
    });

    // _connectSubscription =
    //     Connectivity().onConnectivityChanged.listen(_setInternalIp);
  }

  // Future<void> _setInternalIp(ConnectivityResult? result) async {
  //   try {
  //     if (_gm.enableConnect != null) {
  //       String internalIp = await Connectivity().getWifiIP() ?? LOOPBACK_ADDR;
  //       await _gm.setInternalIp(internalIp);
  //     }
  //   } catch (e) {}
  // }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _gm = Provider.of<GlobalModel>(context);
    await _preparedAppEnv().then((value) {
      if (!_envPrepared) {
        setState(() {
          _envPrepared = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectSubscription.cancel();
    _gm.setAppInit(false);
  }

  Future<void> _preparedAppEnv() async {
    bool hasError = false;
    await _gm.init().catchError((e, s) async {
      hasError = true;
      await Sentry.captureException(
        e,
        stackTrace: s,
      );
    });
    await _tm.init().catchError((e, s) async {
      hasError = true;
      await Sentry.captureException(
        e,
        stackTrace: s,
      );
    });

    if (hasError) {
      throw Exception('prepared app env fail');
    }
  }

  @override
  Widget build(BuildContext context) {
    log("root render ======");
    AquaTheme themeData = _tm.themeData;

    return _envPrepared
        ? AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarIconBrightness:
                  themeData.systemNavigationBarIconBrightness,
              systemNavigationBarColor: themeData.systemNavigationBarColor,
            ),
            child: CupertinoApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                S.delegate
              ],
              supportedLocales: [
                const Locale('zh'),
                const Locale('en'),
              ],
              locale: Locale(_gm.language ?? 'zh'),
              navigatorObservers: [
                SentryNavigatorObserver(),
              ],
              title: 'aqua',
              theme: CupertinoThemeData(
                scaffoldBackgroundColor: themeData.scaffoldBackgroundColor,
                textTheme: CupertinoTextThemeData(
                  textStyle: TextStyle(
                    color: themeData.itemFontColor,
                  ),
                ),
              ),
              // home: HomePage(),
              home: DoublePop(
                globalModel: _gm,
                child: HomePage(),
              ),
            ),
          )
        : Container(color: themeData.scaffoldBackgroundColor);
  }
}
