import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/utils/store.dart';

// 文件管理器布局模式
enum LayoutMode { horizontal, vertical }

enum ViewMode {
  // 关联模式 ranger
  associate,
  // 每个分屏窗口独立运行
  independent
}

// 当前使用的列表  F 第一列表 S 第二个列表
enum ActiveList { F, S }

enum FileSortType {
  // 首字母
  capital,
  size,
  // 修改日期
  modified,
  type,
}

/// [FileManagerModel]
enum FileManagerMode {
  /// 普通文件访问
  normal,

  /// 文件选取
  pick,

  /// 文件搜索
  search
}

class FileManagerModel extends ChangeNotifier {
  Directory? _entryDir;

  Directory? get entryDir => _entryDir;
  void setEntryDir(Directory dir) {
    _entryDir = dir;
  }

  /// 用于处理路由退栈 [BackButtonInterceptor] 导致的文件列表返回
  bool _popLocker = false;
  bool get popLocker => _popLocker;

  void setPopLocker(bool val) {
    _popLocker = val;
  }

  FileManagerMode _visitMode = FileManagerMode.normal;

  /// 管理器的访问模式 [FileManagerMode]
  FileManagerMode get visitMode => _visitMode;

  void setVisitMode(FileManagerMode? mode) {
    if (mode != null) _visitMode = mode;
  }

  late FileSortType _sortType = FileSortType.capital;
  FileSortType get sortType => _sortType;

  Future<void> setSortType(FileSortType arg) async {
    _sortType = arg;
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

  ViewMode _viewMode = ViewMode.associate;
  ViewMode get viewMode => _viewMode;

  Future<void> setViewMode(ViewMode mode, {bool update = false}) async {
    _viewMode = mode;
    switch (mode) {
      case ViewMode.associate:
        await Store.setString(VIEW_MODE, 'associate');
        break;
      case ViewMode.independent:
        await Store.setString(VIEW_MODE, 'independent');
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

  Future<void> _initViewMode() async {
    String? mode = await Store.getString(VIEW_MODE);
    switch (mode) {
      case 'associate':
        _viewMode = ViewMode.associate;
        break;
      case 'independent':
        _viewMode = ViewMode.independent;
        break;
    }
  }

  Future<void> init() async {
    _isDisplayHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    await _initLayoutMode();
    await _initViewMode();
  }
}
