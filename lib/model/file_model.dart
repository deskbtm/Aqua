import 'dart:io';

import 'package:aqua/page/file_manager/file_manager_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/utils/store.dart';

class FileModel extends ChangeNotifier {
  FileManagerMode _visitMode = FileManagerMode.normal;
  FileManagerMode get visitMode => _visitMode;

  void setVisitMode(FileManagerMode mode) {
    _visitMode = mode;
  }

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
    await Store.setBool(SHOW_FILE_HIDDEN, arg);
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

  // Future<void> setEnableClipboard(bool arg) async {
  //   await Store.setBool(ENABLE_CLIPBOARD, arg);
  //   notifyListeners();
  // }

  List<SelfFileEntity> _selectedFiles = [];
  List<SelfFileEntity> get selectedFiles => _selectedFiles;

  Future<void> addSelectedFile(SelfFileEntity value,
      {bool update = false}) async {
    if (!_selectedFiles.any((ele) => ele.entity.path == value.entity.path)) {
      _selectedFiles.add(value);
    }
    if (update) notifyListeners();
  }

  Future<void> removeSelectedFile(SelfFileEntity value,
      {bool update = false}) async {
    _selectedFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    if (update) notifyListeners();
  }

  bool? hasSelectedFile(String path) {
    return _selectedFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearSelectedFiles({bool update = false}) async {
    _selectedFiles = [];
    if (update) notifyListeners();
  }

  List<SelfFileEntity> _pickFiles = [];
  List<SelfFileEntity> get pickedFiles => _pickFiles;

  Future<void> addPickedFile(SelfFileEntity value,
      {bool update = false}) async {
    if (!_pickFiles.any((ele) => ele.entity.path == value.entity.path))
      _pickFiles.add(value);
    if (update) notifyListeners();
  }

  Future<void> removePickedFile(SelfFileEntity value,
      {bool update = false}) async {
    _pickFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    if (update) notifyListeners();
  }

  bool? hasPickFile(String path) {
    return _pickFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearPickedFiles({bool update = false}) async {
    _pickFiles = [];
    if (update) notifyListeners();
  }

  Future<void> init() async {
    _isDisplayHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    _sortType = (await Store.getString(FILE_SORT_TYPE)) ?? SORT_CASE;
    _sortReversed = (await Store.getBool(SORT_REVERSED)) ?? false;
  }
}

FileModel fileModel = FileModel();
