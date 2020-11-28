import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/utils/store.dart';

class FileModel extends ChangeNotifier {
  String _sortType;
  String get sortType => _sortType;

  Future<void> setSortType(String arg) async {
    _sortType = arg;
  }

  bool _isDisplayHidden;
  bool get isDisplayHidden => _isDisplayHidden;

  Future<void> setDisplayHidden(bool arg) async {
    _isDisplayHidden = arg;
  }

  bool _sortReversed;
  bool get sortReversed => _sortReversed;

  Future<void> setSortReversed(bool arg) async {
    _sortReversed = arg;
  }

  /// 按类型显示
  ShowOnlyType _showOnlyType = ShowOnlyType.all;
  ShowOnlyType get showOnlyType => _showOnlyType;

  Future<void> setShowOnlyType(ShowOnlyType arg) async {
    _showOnlyType = arg;
  }

  update() {
    notifyListeners();
  }

  Future<void> init() async {
    _isDisplayHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    _sortType = (await Store.getString(FILE_SORT_TYPE)) ?? SORT_CASE;
    _sortReversed = (await Store.getBool(SORT_REVERSED)) ?? false;
  }
}
