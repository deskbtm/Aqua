import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/constant/constant.dart';
import 'package:lan_file_more/utils/store.dart';
import 'package:lan_file_more/utils/theme.dart';

class ThemeModel extends ChangeNotifier {
  String _theme;
  dynamic _themeData;

  bool _isDark = false;
  bool get isDark => _isDark;

  dynamic get themeData => _themeData;
  String get theme => _theme;

  Future<void> setTheme(String theme) async {
    _theme = theme;
    switch (theme) {
      case LIGHT_THEME:
        _isDark = false;
        _themeData = LightTheme();
        break;
      case DARK_THEME:
        _isDark = true;
        _themeData = DarkTheme();
        break;
      default:
        _isDark = false;
        _themeData = LightTheme();
        break;
    }
    await Store.setString(THEME_KEY, theme);
    notifyListeners();
  }
}
