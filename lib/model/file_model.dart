import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/utils/store.dart';

class FileModel extends ChangeNotifier {
  late String _sortType = SORT_CASE;
  String get sortType => _sortType;

  Directory? _currentDir;
  Directory? get currentDir => _currentDir;

  void setCurrentDir(Directory dir) {
    _currentDir = dir;
  }

  Directory? _rootDir;
  Directory? get rootDir => _rootDir;

  void setRootDir(Directory dir) {
    _rootDir = dir;
  }

  Future<void> setSortType(String arg) async {
    _sortType = arg;
  }

  late bool _isDisplayHidden;
  bool get isDisplayHidden => _isDisplayHidden;

  Future<void> setDisplayHidden(bool arg) async {
    _isDisplayHidden = arg;
  }

  late bool _sortReversed;
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

  Future<void> init() async {
    _isDisplayHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    _sortType = (await Store.getString(FILE_SORT_TYPE)) ?? SORT_CASE;
    _sortReversed = (await Store.getBool(SORT_REVERSED)) ?? false;
  }
}
