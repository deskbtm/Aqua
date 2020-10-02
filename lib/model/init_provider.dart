import 'package:lan_express/model/common.dart';
import 'package:lan_express/model/share.dart';
import 'package:lan_express/model/theme.dart';
import 'package:provider/provider.dart';

class InitProvider {
  static MultiProvider init({child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
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
