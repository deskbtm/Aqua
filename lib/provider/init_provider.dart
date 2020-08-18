import 'package:lan_express/provider/device.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/share.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:provider/provider.dart';

class InitProvider {
  static MultiProvider init({child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<NativeProvider>(
          create: (_) => NativeProvider(),
        ),
        ChangeNotifierProvider<CommonProvider>(
          create: (_) => CommonProvider(),
        ),
        ChangeNotifierProvider<ShareProvider>(
          create: (_) => ShareProvider(),
        ),
      ],
      child: child,
    );
  }
}
