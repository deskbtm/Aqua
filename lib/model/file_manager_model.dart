import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/utils/store.dart';

// 文件管理器布局模式
enum LayoutMode { horizontal, vertical }

enum RunningMode {
  // ranger 模式
  ranger,
  // 每个分屏窗口独立运行
  alone
}

enum FileSortType {
  // 首字母
  capital,
  size,
  // 修改日期
  modified,
  type,
}

enum FileManagerMode {
  // 普通模式
  normal,
  pick,
  search
}

class FileManagerModel extends ChangeNotifier {
  late Directory _entryDir;

  Directory? get entryDir => _entryDir;
  void setEntryDir(Directory dir) {
    _entryDir = dir;
  }

  FileManagerMode _visitMode = FileManagerMode.normal;
  FileManagerMode get visitMode => _visitMode;

  void setVisitMode(FileManagerMode? mode) {
    if (mode != null) _visitMode = mode;
  }

  late FileSortType _sortType = FileSortType.capital;
  FileSortType get sortType => _sortType;

  Future<void> setSortType(FileSortType arg) async {
    _sortType = arg;
  }

  Directory? _currentDir;
  Directory? get currentDir => _currentDir;

  void setCurrentDir(Directory dir) {
    _currentDir = dir;
  }

  late bool _isDisplayHidden;
  bool get isDisplayHidden => _isDisplayHidden;

  Future<void> setDisplayHidden(bool arg) async {
    await Store.setBool(SHOW_FILE_HIDDEN, arg);
    _isDisplayHidden = arg;
  }

  late bool _sortReversed = false;
  bool get sortReversed => _sortReversed;

  Future<void> setSortReversed(bool arg) async {
    _sortReversed = arg;
  }

  String _demo = '初始';

  String get demo => _demo;

  void setDemo(String val) {
    this._demo = val;
    notifyListeners();
  }

  /// 按类型显示
  ShowOnlyType _showOnlyType = ShowOnlyType.all;
  ShowOnlyType get showOnlyType => _showOnlyType;

  Future<void> setShowOnlyType(ShowOnlyType arg) async {
    _showOnlyType = arg;
  }

  LayoutMode _layoutMode = LayoutMode.horizontal;
  LayoutMode get layoutMode => _layoutMode;

  Future<void> setLayoutMode(LayoutMode mode, {bool update = false}) async {
    _layoutMode = mode;
    switch (mode) {
      case LayoutMode.horizontal:
        await Store.setString(LAYOUUT_MODE, 'horizontal');
        break;
      case LayoutMode.vertical:
        await Store.setString(LAYOUUT_MODE, 'vertical');
        break;
    }
    if (update) notifyListeners();
  }

  RunningMode _runningMode = RunningMode.ranger;
  RunningMode get runningMode => _runningMode;

  Future<void> setRunningMode(RunningMode mode, {bool update = false}) async {
    _runningMode = mode;
    switch (mode) {
      case RunningMode.alone:
        await Store.setString(RUNNING_MODE, 'alone');
        break;
      case RunningMode.ranger:
        await Store.setString(RUNNING_MODE, 'ranger');
        break;
    }
    if (update) notifyListeners();
  }

  Future<void> _initLayoutMode() async {
    String? mode = await Store.getString(LAYOUUT_MODE);
    switch (mode) {
      case 'vertical':
        _layoutMode = LayoutMode.vertical;
        break;
      case 'horizontal':
        _layoutMode = LayoutMode.horizontal;
        break;
    }
  }

  Future<void> _initRunningMode() async {
    String? mode = await Store.getString(LAYOUUT_MODE);
    switch (mode) {
      case 'vertical':
        _layoutMode = LayoutMode.vertical;
        break;
      case 'horizontal':
        _layoutMode = LayoutMode.horizontal;
        break;
    }
  }

  Future<void> storageInit() async {
    _isDisplayHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    await _initLayoutMode();
    await _initRunningMode();
  }
}

FileManagerModel fileManagerModel = FileManagerModel();
