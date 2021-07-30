import 'dart:io';
import 'package:aqua/page/file_manager/fs_ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/utils/store.dart';
import 'package:path/path.dart' as pathLib;

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

enum FileManagerMode {
  // 普通模式
  normal,
  pick,
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

  void settPopLocker(bool val) {
    _popLocker = val;
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

  // 当前目录
  Directory? _currentDir;
  Directory? get currentDir => _currentDir;

  void setCurrentDir(Directory? dir, {update: false}) {
    _currentDir = dir;
    if (update) notifyListeners();
  }

  List<SelfFileEntity>? _firstList;
  List<SelfFileEntity>? get firstList => _firstList;

  Future<void> setFirstList(context, Directory dir, {update = false}) async {
    await FsUIUtils.readdir(context, dir).then((list) {
      _firstList = list;
      if (update) notifyListeners();
    });
  }

  List<SelfFileEntity>? _secondList;
  List<SelfFileEntity>? get secondList => _secondList;

  Future<void> setSecondList(context, Directory? dir, {update = false}) async {
    await FsUIUtils.readdir(context, dir!).then((list) {
      _secondList = list;
      if (update) notifyListeners();
    }).catchError((err) {
      throw Exception(err);
    });
  }

  Future<void> setSecondListDirectly(context, List<SelfFileEntity>? list,
      {update = false}) async {
    _secondList = list;

    if (update) notifyListeners();
  }

  bool get isRelativeRoot => pathLib.equals(_entryDir!.path, _currentDir!.path);

  bool get isRelativeParentRoot =>
      pathLib.equals(_entryDir!.path, _currentDir!.parent.path);

  bool get isWithinLawPath =>
      pathLib.equals(_entryDir!.path, _currentDir!.path);

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

  Future<void> storageInit() async {
    _isDisplayHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    await _initLayoutMode();
    await _initViewMode();
  }

  /// 处理独立模式
  ///
  /// 第一个文件文件的当前目录
  Directory? _firstCurrentDir;
  Directory? get firstCurrentDir => _firstCurrentDir;

  void setFirstCurrentDir(Directory? dir, {update: false}) {
    _firstCurrentDir = dir;
    if (update) notifyListeners();
  }

  Directory? _secondCurrentDir;
  Directory? get secondCurrentDir => _secondCurrentDir;

  void setSecondCurrentDir(Directory? dir, {update: false}) {
    _secondCurrentDir = dir;
    if (update) notifyListeners();
  }
}
