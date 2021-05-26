import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/utils/store.dart';
import 'package:aqua/common/theme.dart';

class ThemeModel extends ChangeNotifier {
  late String _theme = LIGHT_THEME;
  AquaTheme _themeData = LightTheme();
  late bool _isDark = false;

  bool get isDark => _isDark;

  AquaTheme get themeData => _themeData;
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
