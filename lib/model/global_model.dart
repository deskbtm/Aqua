import 'package:flutter/cupertino.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/utils/store.dart';
import 'package:lan_express/utils/theme.dart';

class GlobalModel extends ChangeNotifier {
  /// 被选择的文件
  List<SelfFileEntity> _selectedFiles = [];
  List<SelfFileEntity> get selectedFiles => _selectedFiles;

  Future<void> addSelectedFile(SelfFileEntity value) async {
    if (!_selectedFiles.any((ele) => ele.entity.path == value.entity.path))
      _selectedFiles.add(value);
    notifyListeners();
  }

  Future<void> removeSelectedFile(SelfFileEntity value) async {
    _selectedFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    notifyListeners();
  }

  bool hasSelectedFile(String path) {
    return _selectedFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearSelectedFiles() async {
    _selectedFiles = [];
    notifyListeners();
  }

  /// 主题
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
